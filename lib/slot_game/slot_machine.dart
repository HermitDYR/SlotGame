import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar.dart';
import 'package:hawaiian_game_slot/slot_game_config.dart';
import 'package:spine_flutter/spine_flutter.dart';

enum SlotMachineState {
  /// 待機
  idle,
  /// 轉動
  spin,
  /// 停止
  stop,
}

class SlotMachine extends PositionComponent with Tappable, HasGameRef<SlotGame> {

  SlotMachineState state = SlotMachineState.idle;

  /// 老虎機目前的時間計數
  double currentDuration = 0.0;

  /// 老虎機的按鈕按下時間點
  double buttonTimePoint = 0.0;

  /// 老虎機各Bar的滾動延遲秒數
  double slotBarSpinDelay = 0.2;

  /// 老虎機各Bar的假滾動Box新增延遲秒數
  double fakeSlotBarBoxAddDelay = 0.2;

  /// 老虎機各Bar的停止延遲秒數
  double slotBarStopDelay = 0.2;

  /// 老虎機各Bar的假滾動Box移除延遲秒數
  double fakeSlotBarBoxRemoveDelay = 0.2;

  /// 老虎機各Bar的停止間隔時間點
  double nextStopTimePoint = 1.0;

  /// 是否自動停止
  bool isAutoStop = true;

  /// 老虎機各Bar的自動停止延遲秒數
  double slotBarAutoStopDelay = 3.0;

  /// 符合RTP中獎機率的設計模式開獎盤面列表(包含中獎、未中獎)
  List<List<List<int>>> designModeAllLotteryList = [];

  /// 符合RTP中獎機率的分數列表(包含中獎、未中獎)
  List<int> allLotteryPointList = [];

  /// 滾輪寬度
  double barWidth;

  /// 滾輪數量
  int barCount;

  /// 滾輪內的滾輪物件數量
  int barItemCount;

  /// 是否為首次設定
  bool isFirstSetting = true;

  /// 是否滾動
  bool _isSpin = false;

  /// 是否滾動 (唯讀取)
  bool get isSpin => _isSpin;

  /// 停止音效撥放器
  AudioPlayer? _stopPlayer;

  /// 滾動音效撥放器
  AudioPlayer? _spinPlayer;

  /// 得分音效撥放器
  AudioPlayer? _winPlayer;

  /// Bonus音效撥放器
  AudioPlayer? _bonusPlayer;

  /// 老虎機滾輪物件的精靈數量
  final rollItemSpritesCount = 11;

  /// 老虎機滾輪物件的精靈列表
  final List<Sprite> rollItemSprites = [];

  /// 老虎機滾輪組箱
  SlotMachineBarsBox? slotMachineBarsBox;

  /// 老虎機滾輪滾動延遲時間(毫秒)
  final int slotBarDelayMilliseconds = 300;

  /// 老虎機滾輪箱移動速度
  final double slotBarBoxMoveSpeed = 2;

  /// 開獎索引
  int lotteryIndex = 0;

  /// 取得遊戲模式開獎盤面
  List<List<int>> lottery = [];

  /// 最大回合數
  // int maxGameRound = 6;

  /// 回合數
  int gameRound = 0;

  /// 是否為免費回合
  bool isFreeGameRound = false;

  /// 免費回合數
  int freeGameRound = 0;

  /// 得分
  int win = 0;

  /// 餘額
  // int balance = 10000;

  /// 下注額度
  int bet = 100;

  /// 是否準備進入Bonus遊戲模式
  bool isReadyBonusGame = false;

  /// 最大Bonus遊戲模式充能數
  int maxBonusGameRecharge = 3;

  /// Bonus遊戲模式充能數
  int bonusGameRecharge = 0;

  /// 老虎機
  SlotMachine({
    required this.barWidth,
    required this.barCount,
    required this.barItemCount,
    required Vector2? position,
    required Vector2? size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    // TODO: implement onLoad

    // 取得符合RTP中獎機率的設計模式開獎盤面列表(包含中獎、未中獎)
    designModeAllLotteryList = SlotGameConfig.getDesignModeAllLotteryList(gameRTP: gameRef.gameRTP);

    // 取得符合RTP中獎機率的分數列表(包含中獎、未中獎)
    allLotteryPointList = SlotGameConfig.getAllLotteryPointList(gameRTP: gameRef.gameRTP);

    // 設置音效
    await _setupAudios();

    // 設定老虎機滾輪物件的精靈列表
    await _setupSlotItemSprites();

    // 設置老虎機滾輪組箱
    _setupSlotMachineBarsBox();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    if (state == SlotMachineState.idle) {
      if (currentDuration != 0.0) {
        currentDuration = 0.0;
        // print("currentDuration: $currentDuration");
      } else {
        return;
      }
    }

    if (gameRef.paused == false) {
      currentDuration += dt;
    }

    if (state == SlotMachineState.spin) {
      _checkSlotBarToSpin(currentDuration);

      if (isAutoStop) {
        if (currentDuration > buttonTimePoint + slotBarAutoStopDelay) {
          stop();
        }
      }
    }

    if (state == SlotMachineState.stop) {
      _checkSlotBarToStop(currentDuration);
    }

    super.update(dt);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    return true;
  }

  void _checkSlotBarToSpin(double time) {

    var list = [];
    for (int i = 0; i < barCount; i++) {
      list.add(buttonTimePoint + (i * slotBarSpinDelay));
    }

    if (slotMachineBarsBox != null) {
      for (int i = 0; i < barCount; i++) {
        SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
        if (slotBar != null) {

          if (time > list[i] && time < (slotBarSpinDelay + list[i])) {
            // 寫法一，同步滾動
            slotBar.spin();
          }

          if (time > (list[i] + fakeSlotBarBoxAddDelay) && time < (slotBarSpinDelay + list[i] + fakeSlotBarBoxAddDelay)) {
            // 設置假的老虎機滾輪物件箱
            slotBar.addFakeSlotBarBox();
          }
        }
      }
    }
  }

  void _checkSlotBarToStop(double time) {
    // print("_checkSlotBarToStop currentDuration: $currentDuration, buttonTimePoint: $buttonTimePoint");
    // 設置盤面內容
    var timeList = [];
    for (int i = 0; i < barCount; i++) {
      timeList.add(buttonTimePoint + (i * slotBarStopDelay) + nextStopTimePoint);
      SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
      if (slotBar != null) {
        // 設置老虎機滾輪物件內容編號陣列
        slotBar.setupItemIdList(itemIdList: lottery[i]);
        // 取得當前Bar有中獎的索引陣列
        final lotteryIndexList = getLotteryIndexOnBar(lotteryNumbers: lottery, barIndex: i);
        slotBar.setupItemLotteryIndexList(itemLotteryIndexList: lotteryIndexList);

        if (time > timeList[i] && time < (slotBarStopDelay + timeList[i])) {
          // print("SlotBar $i to Stop Do!!!");
          // 將老虎機滾輪物件箱子新增到上方外部錨點上
          slotBar.addSlotBarBoxAtTopOutside();
        }

        if (time > timeList[i] + fakeSlotBarBoxRemoveDelay && time < (slotBarStopDelay + timeList[i] + fakeSlotBarBoxRemoveDelay)) {
          // print("SlotBar $i to Stop Do Delay!!!");
          // 將假的老虎機滾輪物件箱移除
          if (slotBar.fakeSlotBarBox != null) {
            slotBar.fakeSlotBarBox!.removeFromParent();
            slotBar.fakeSlotBarBox = null;
          }

          if (i == barCount - 1) {
            state = SlotMachineState.idle;
          }
        }
      }
    }
  }

  /// 設置音效
  Future<void> _setupAudios() async {
    _stopPlayer = AudioPlayer();
    await _stopPlayer!.audioCache.load('audio/stop.mp3');
    // await _stopPlayer!.setSource(AssetSource('audio/stop.mp3'));
    await _stopPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _stopPlayer!.setVolume(0.4);

    _spinPlayer = AudioPlayer();
    await _spinPlayer!.audioCache.load('audio/spin.mp3');
    // await _spinPlayer!.setSource(AssetSource('audio/spin.mp3'));
    await _spinPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _spinPlayer!.setVolume(0.4);

    _winPlayer = AudioPlayer();
    await _winPlayer!.setSource(AssetSource('audio/win.mp3'));
    await _winPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _winPlayer!.setVolume(0.4);

    _bonusPlayer = AudioPlayer();
    await _bonusPlayer!.setSource(AssetSource('audio/bonus.mp3'));
    await _bonusPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _bonusPlayer!.setVolume(0.4);
    return;
  }

  /// 播放背景音樂
  void audioPlayBGM() {
    if (gameRef.bgmAudioPlayer == null) return;
    if (gameRef.bgmAudioPlayer!.state == PlayerState.completed || gameRef.bgmAudioPlayer!.state == PlayerState.stopped || gameRef.bgmAudioPlayer!.state == PlayerState.paused) {
      gameRef.bgmAudioPlayer!.play(AssetSource('audio/bgm.mp3'));
    }
  }

  /// 暫停背景應岳
  void audioPauseBGM() {
    if (gameRef.bgmAudioPlayer == null) return;
    if (gameRef.bgmAudioPlayer!.state == PlayerState.playing) {
      gameRef.bgmAudioPlayer!.pause();
    }
  }

  /// 播放停止音效
  void _audioPlayStop({required int delayMilliseconds}) {
    if (_stopPlayer == null) return;
    if (delayMilliseconds > 0) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (_stopPlayer!.state != PlayerState.playing) {
          _stopPlayer!.play(AssetSource('audio/stop.mp3'));
        }
      });
    } else {
      if (_stopPlayer!.state != PlayerState.playing) {
        _stopPlayer!.play(AssetSource('audio/stop.mp3'));
      }
    }
  }

  /// 播放滾動音效
  void _audioPlaySpin({required int delayMilliseconds}) {
    if (_spinPlayer == null) return;
    if (delayMilliseconds > 0) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (_spinPlayer!.state != PlayerState.playing) {
          _spinPlayer!.play(AssetSource('audio/spin.mp3'));
        }
      });
    } else {
      if (_spinPlayer!.state != PlayerState.playing) {
        _spinPlayer!.play(AssetSource('audio/spin.mp3'));
      }
    }
  }

  /// 播放得分音效
  void _audioPlayWin({required int delayMilliseconds}) {
    if (_winPlayer == null) return;
    if (delayMilliseconds > 0) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (_winPlayer!.state != PlayerState.playing) {
          _winPlayer!.play(AssetSource('audio/win.mp3'));
        }
      });
    } else {
      if (_winPlayer!.state != PlayerState.playing) {
        _winPlayer!.play(AssetSource('audio/win.mp3'));
      }
    }
  }

  /// 播放Bonus音效
  void _audioPlayBonus({required int delayMilliseconds}) {
    if (_bonusPlayer == null) return;
    if (delayMilliseconds > 0) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (_bonusPlayer!.state != PlayerState.playing) {
          _bonusPlayer!.play(AssetSource('audio/bonus.mp3'));
        }
      });
    } else {
      if (_bonusPlayer!.state != PlayerState.playing) {
        _bonusPlayer!.play(AssetSource('audio/bonus.mp3'));
      }
    }
  }

  /// 停止滾動
  void stop() async {
    if (state == SlotMachineState.stop) {
      return;
    }
    print("SlotMachine >> stop!!!");

    buttonTimePoint = currentDuration;
    state = SlotMachineState.stop;
    print("buttonTimePoint(currentDuration): $buttonTimePoint");

    // 設置是否滾動
    setIsSpin(false);

    // 播放停止音效
    _audioPlayStop(delayMilliseconds: 0);

    // 設置下一輪滾輪組的盤面內容
    if (slotMachineBarsBox != null) {
      lotteryIndex = 0;
      if (isFirstSetting) {
        isFirstSetting = false;
      } else {
        lotteryIndex = Random().nextInt(designModeAllLotteryList.length);
      }

      // 取得遊戲模式開獎盤面(用於運作程式邏輯)
      lottery = SlotGameConfig.getGameModeLottery(designModeAllLotteryList: designModeAllLotteryList, index: lotteryIndex);

      // // 設置盤面內容
      // for (int i = 0; i < barCount; i++) {
      //   SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
      //   // if (slotBar != null) {
      //   //   // 設置老虎機滾輪物件內容編號陣列
      //   //   slotBar.setupItemIdList(itemIdList: lottery[i]);
      //   //   // 取得當前Bar有中獎的索引陣列
      //   //   final lotteryIndexList = getLotteryIndexOnBar(lotteryNumbers: lottery, barIndex: i);
      //   //   slotBar.setupItemLotteryIndexList(itemLotteryIndexList: lotteryIndexList);
      //   //
      //   //   // 寫法一
      //   //   // // 將老虎機滾輪物件箱子新增到上方外部錨點上
      //   //   // slotBar.addSlotBarBoxAtTopOutside();
      //   //   // Future.delayed(const Duration(milliseconds: 200), () {
      //   //   //   // 將假的老虎機滾輪物件箱移除
      //   //   //   if (slotBar.fakeSlotBarBox != null) {
      //   //   //     slotBar.fakeSlotBarBox!.removeFromParent();
      //   //   //   }
      //   //   // });
      //   //   // 寫法二，異步滾動 (不建議)
      //   //   Future.delayed(Duration(milliseconds: i * slotBarDelayMilliseconds), () {
      //   //     print("Delay to Stop SlotBar $i !!!");
      //   //     // 將老虎機滾輪物件箱子新增到上方外部錨點上
      //   //     slotBar.addSlotBarBoxAtTopOutside();
      //   //   }).then((value) {
      //   //     // 將假的老虎機滾輪物件箱移除
      //   //     Future.delayed(Duration(milliseconds: (slotBarBoxMoveSpeed * slotBar.targetSlotBarBox!.size.x) ~/ 2), () {
      //   //       // 將假的老虎機滾輪物件箱移除
      //   //       if (slotBar.fakeSlotBarBox != null) {
      //   //         slotBar.fakeSlotBarBox!.removeFromParent();
      //   //         slotBar.fakeSlotBarBox = null;
      //   //       }
      //   //     });
      //   //   });
      //   // }
      // }

      // 更新得分
      win = allLotteryPointList[lotteryIndex];

      // 更新餘額
      gameRef.gameBalance += win;

      // 判斷是否進入Bonus遊戲模式準備階段
      _checkBonusGame();
    }
  }

  /// 確認遊戲回合
  void _checkGameRound() {
    // 是否為免費回合
    if (isFreeGameRound) {
      if (freeGameRound > 0) {
        // 免費回合倒數
        freeGameRound--;
      } else {
        // 免費回合結束
        isFreeGameRound = false;
      }
    } else {
      // 回合數正數累加
      gameRound++;
    }
    print("SlotMachine >> _checkGameRound gameRound: $gameRound");
  }

  /// 確認是否為最大回合數
  bool _checkIsMaxGameRound() {
    print("SlotMachine >> _checkIsMaxGameRound gameRound: $gameRound, gameMaxRound: ${gameRef.gameMaxRound}");
    // 限制回合數
    if (!(gameRound < gameRef.gameMaxRound)) {
      // TODO: 彈窗點擊導入外部網頁
      if (gameRef.slotGameControlMenu.linkTipsDialog == null) {
        // 進行外連提示彈窗
        // gameRef.slotGameControlMenu.showLinkTipsDialog(text: "繼續遊戲?", linkUrl: gameRef.gameLinkUrl);
        gameRef.slotGameControlMenu.showLinkTipsDialog(text: "Continue Play?", linkUrl: gameRef.gameLinkUrl);
      }
    }
    return !(gameRound < gameRef.gameMaxRound);
  }

  /// 開始滾動
  void spin() async {
    print("SlotMachine >> spin~~~");

    buttonTimePoint = currentDuration;
    state = SlotMachineState.spin;
    print("buttonTimePoint(currentDuration): $buttonTimePoint");

    // 設置是否滾動
    // setIsSpin((gameRef.gameBalance > 0));

    // 確認餘額是否足夠
    if (!(gameRef.gameBalance > bet)) {
      setIsSpin((gameRef.gameBalance > bet));
      return;
    }

    // 確認是否為最大回合數
    if (_checkIsMaxGameRound()) return;

    // 確認遊戲回合
    _checkGameRound();

    // 播放背景音樂
    audioPlayBGM();

    // 播放滾動音效
    _audioPlaySpin(delayMilliseconds: 0);

    // if (slotMachineBarsBox != null) {
    //   for (int i = 0; i < barCount; i++) {
    //     SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
    //     if (slotBar != null) {
    //       // 寫法一，同步滾動
    //       // slotBar.spin();
    //       // 寫法二，異步滾動 (不建議)
    //       Future.delayed(Duration(milliseconds: i * slotBarDelayMilliseconds), () {
    //         print("Delay to Spin SlotBar $i !!!");
    //         slotBar.spin();
    //       }).then((value) {
    //         // 設置假的老虎機滾輪物件箱
    //         slotBar.addFakeSlotBarBox();
    //       });
    //     }
    //   }
    // }

    // 更新得分
    win = 0;

    // 更新下注
    bet = 100;

    // 更新餘額
    gameRef.gameBalance -= bet;

    // 進行得分動畫
    gameRef.slotGameControlMenu.showWin(win: win);

    // 進行下注動畫
    gameRef.slotGameControlMenu.showBet(bet: bet);

    // 進行餘額動畫
    gameRef.slotGameControlMenu.showBalance(balance: gameRef.gameBalance);

    // // 指定時間後停止
    // int delayStopMilliseconds = (barCount * slotBarDelayMilliseconds) * 2;
    // Future.delayed(Duration(milliseconds: delayStopMilliseconds), () {
    //   print("Delay to Stop!!!");
    //   stop();
    // });
  }

  /// 設置是否滾動
  void setIsSpin(bool spin) {
    _isSpin = spin;
    if (gameRef.slotGameControlMenu.slotGameSpinButton != null) {
      gameRef.slotGameControlMenu.slotGameSpinButton!.setIsSpin(_isSpin);
    }
  }

  /// 判斷是否進入Bonus遊戲模式準備階段
  /// - 依賴win、isReadyBonusGame
  void _checkBonusGame() async {
    if (win == 0 && !isReadyBonusGame) {
      if (bonusGameRecharge < maxBonusGameRecharge) {
        bonusGameRecharge++;
        // print("Bonus遊戲模式充能數: $bonusGameRecharge!!! 在${maxBonusGameRecharge - bonusGameRecharge}次，進入Bonus遊戲模式準備階段~~~");
      } else {
        // print("Bonus女郎來拉~~~");
        isReadyBonusGame = true;
        if (slotMachineBarsBox != null) {
          // 新增老虎機Bonus遊戲模式物件
          await slotMachineBarsBox!.addBonusGameItem();

          // 播放Bonus音效
          _audioPlayBonus(delayMilliseconds: 500);
        }
      }
    }
  }

  /// 取得當前Bar有中獎的索引陣列
  /// - 判斷橫向直線開獎，確認每個Bar裡相同的Index下LotteryNumber是否一致
  /// - 判斷左上到右下斜線開獎
  /// - 判斷左下到右上斜線開獎
  List<int>? getLotteryIndexOnBar({required List<List<int>> lotteryNumbers, required int barIndex}) {
    if (lotteryNumbers.length != barCount || lotteryNumbers.first.length != barItemCount) {
      // print("數量有誤");
      return null;
    }

    // 中獎陣列
    List<int> lotteryIndexList = [];

    // 判斷橫向直線開獎，確認每個Bar裡相同的Index下LotteryNumber是否一致
    for (int j = 0; j < barItemCount; j++) {
      List<int> horizontalCheckList = [];
      for (int i = 0; i < barCount; i++) {
        horizontalCheckList.add(lotteryNumbers[i][j]);
      }
      // print("SlotMachine >> barItemCount Index $j BarsRowList $horizontalCheckList");
      final horizontalFind = horizontalCheckList.where((element) {
        return (element == horizontalCheckList.first);
      });
      if (horizontalFind.length == barCount) {
        lotteryIndexList.add(j);
      }
    }

    // 判斷左上到右下斜線開獎
    int leftTopToRightBottomTargetIndex = barIndex;
    List<int> leftTopToRightBottomCheckList = [];
    for (int i = 0; i < barCount; i++) {
      leftTopToRightBottomCheckList.add(lotteryNumbers[i][i]);
    }
    final leftTopToRightBottomFind = leftTopToRightBottomCheckList.where((element) {
      return (element == leftTopToRightBottomCheckList.first);
    });
    if (leftTopToRightBottomFind.length == barCount) {
      lotteryIndexList.add(leftTopToRightBottomTargetIndex);
    }

    // 判斷左下到右上斜線開獎
    List<int> leftBottomToRightTopCheckList = [];
    int leftBottomToRightTopTargetIndex = (barCount - 1) - barIndex;
    for (int i = 0; i < barCount; i++) {
      leftBottomToRightTopCheckList.add(lotteryNumbers[i][(barCount - 1) - i]);
    }
    final find = leftBottomToRightTopCheckList.where((element) {
      return (element == leftBottomToRightTopCheckList.first);
    });
    if (find.length == barCount) {
      lotteryIndexList.add(leftBottomToRightTopTargetIndex);
    }

    // print("SlotMachine >> lotteryIndexList: $lotteryIndexList");

    // 去除重複內容(索引)
    lotteryIndexList = lotteryIndexList.toSet().toList();
    // print("SlotMachine >> lotteryIndexList(After to Set): $lotteryIndexList");

    return lotteryIndexList;
  }

  /// 設定老虎機滾輪物件的精靈列表
  Future<void> _setupSlotItemSprites() async {
    for (int i = 0; i < rollItemSpritesCount; i++) {
      final sprite = await Sprite.load('game/slot_item_normal_$i.png');
      rollItemSprites.add(sprite);
    }
    return;
  }

  /// 設置老虎機滾輪組箱
  void _setupSlotMachineBarsBox() {
    var position = Vector2(this.size.x / 2, this.size.y / 2);
    var size = Vector2(barWidth * SlotGameConfig.barCount, barWidth * SlotGameConfig.barItemCount);
    slotMachineBarsBox =
        SlotMachineBarsBox(barWidth: barWidth, barCount: barCount, barItemCount: barItemCount, position: position, size: size, onAllBarStay: _onAllBarStayFromSlotMachineBarsBox);
    add(slotMachineBarsBox!);
  }

  /// 所有的滾輪皆進入停留狀態
  void _onAllBarStayFromSlotMachineBarsBox() {
    if (win > 0) {
      if (slotMachineBarsBox != null) {
        for (int i = 0; i < barCount; i++) {
          SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
          if (slotBar != null && slotBar.targetSlotBarBox != null) {
            // 展示中獎效果
            slotBar.targetSlotBarBox!.showLottery();
          }
        }
      }

      // 2秒後進行得分音效與動畫
      int milliseconds = 500;

      // 播放得分音效
      _audioPlayWin(delayMilliseconds: milliseconds);

      // 播放得分動畫
      Future.delayed(Duration(milliseconds: milliseconds * 2), () {
        // 進行得分動畫
        gameRef.slotGameControlMenu.showWin(win: win);

        // 進行餘額動畫
        gameRef.slotGameControlMenu.showBalance(balance: gameRef.gameBalance);
      });
    }
  }
}
