import 'dart:math';

class SlotGameConfig {
  static const barCount = 3;

  static const barItemCount = 3;

  /// 未中獎分數 (10種未中獎盤面)
  static const List<int> lotteryPointList = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ];

  /// 中獎分數 (16種中獎盤面)
  static const List<int> lotteryWinPointList = [
    20,
    40,
    60,
    100,
    140,
    200,
    500,
    400,
    600,
    800,
    1000,
    20*2,
    40*2,
    60*2,
    100*2,
    140*2,
  ];
  /// 未中獎設計模式開獎盤面列表(10種未中獎盤面, 用於設計盤面，相對直覺化、視覺化)
  static const List<List<List<int>>> designModeLotteryList = [
    [
      [0, 1, 6],
      [5, 5, 8],
      [7, 6, 2],
    ],
    [
      [8, 1, 4],
      [10, 4, 3],
      [7, 6, 10],
    ],
    [
      [3, 2, 3],
      [4, 3, 2],
      [1, 7, 0],
    ],
    [
      [6, 9, 0],
      [1, 5, 5],
      [0, 10, 6],
    ],
    [
      [10, 6, 0],
      [4, 5, 10],
      [5, 10, 6],
    ],
    [
      [1, 2, 3],
      [5, 5, 2],
      [7, 8, 9],
    ],
    [
      [7, 8, 3],
      [8, 10, 5],
      [2, 6, 9],
    ],
    [
      [4, 1, 0],
      [8, 6, 7],
      [1, 8, 4],
    ],
    [
      [0, 5, 0],
      [8, 9, 3],
      [10, 7, 6],
    ],
    [
      [5, 5, 2],
      [9, 1, 6],
      [0, 6, 8],
    ],
  ];

  /// 中獎設計模式開獎盤面列表(16種中獎盤面, 用於設計盤面，相對直覺化、視覺化)
  static const List<List<List<int>>> designModeLotteryWinList = [
    [
      [3, 8, 4],
      [0, 0, 0],
      [5, 6, 9],
    ],
    [
      [9, 0, 6],
      [1, 1, 1],
      [0, 8, 2],
    ],
    [
      [9, 4, 7],
      [2, 2, 2],
      [1, 1, 2],
    ],
    [
      [5, 6, 0],
      [3, 3, 3],
      [4, 1, 5],
    ],
    [
      [5, 5, 1],
      [4, 4, 4],
      [10, 6, 3],
    ],
    [
      [6, 9, 1],
      [5, 5, 5],
      [0, 8, 4],
    ],
    [
      [3, 4, 5],
      [6, 6, 6],
      [0, 1, 2],
    ],
    [
      [7, 6, 4],
      [0, 7, 8],
      [2, 3, 7],
    ],
    [
      [5, 9, 8],
      [0, 8, 4],
      [8, 0, 10],
    ],
    [
      [9, 10, 5],
      [2, 9, 1],
      [6, 5, 9],
    ],
    [
      [6, 4, 2],
      [10, 10, 10],
      [1, 3, 5],
    ],
    [
      [0, 9, 5],
      [5, 0, 8],
      [0, 0, 0],
    ],
    [
      [1, 1, 1],
      [4, 1, 2],
      [3, 9, 1],
    ],
    [
      [4, 5, 2],
      [6, 2, 3],
      [2, 2, 2],
    ],
    [
      [3, 8, 6],
      [1, 3, 5],
      [3, 3, 3],
    ],
    [
      [4, 4, 4],
      [0, 4, 1],
      [9, 6, 4],
    ],
  ];

  /// 取得符合RTP中獎機率的分數列表(包含中獎、未中獎)
  static List<int> getAllLotteryPointList({required double gameRTP}) {
    // 中獎盤面數量
    int lotteryWinCount = lotteryWinPointList.length;
    // 換算出所需的未中獎盤面數量(以符合RTP機率，[中獎盤面數量]/[中獎盤面數量 + 未中獎盤面數量])
    int lotteryCount = 0;
    if (gameRTP > 0 && gameRTP < 1) {
      lotteryCount = lotteryWinCount ~/ gameRTP;
    } else if (gameRTP <= 0) {
      lotteryCount = designModeLotteryList.length;
      lotteryWinCount = 0;
    } else {
      lotteryCount = 0;
    }
    print("SlotGameConfig >> getAllLotteryPointList gameRTP: $gameRTP >> lotteryWinCount: $lotteryWinCount, lotteryCount: $lotteryCount");

    // 符合RTP中獎機率的盤面陣列
    List<int> allLotteryPointList = [];

    // 加入未中獎盤面的分數
    for (int i = 0; i < lotteryCount; i++) {
      final index = Random().nextInt(lotteryPointList.length);
      allLotteryPointList.add(lotteryPointList[index]);
    }

    if (lotteryWinCount > 0) {
      // 加入中獎盤面的分數
      allLotteryPointList.addAll(lotteryWinPointList);
    }

    return allLotteryPointList;
  }

  /// 取得符合RTP中獎機率的設計模式開獎盤面列表(包含中獎、未中獎)
  static List<List<List<int>>> getDesignModeAllLotteryList({required double gameRTP}) {
    // 中獎盤面數量
    int lotteryWinCount = designModeLotteryWinList.length;
    // 換算出所需的未中獎盤面數量(以符合RTP機率，[中獎盤面數量]/[中獎盤面數量 + 未中獎盤面數量])
    int lotteryCount = 0;
    if (gameRTP > 0 && gameRTP < 1) {
      lotteryCount = lotteryWinCount ~/ gameRTP;
    } else if (gameRTP <= 0) {
      lotteryCount = designModeLotteryList.length;
      lotteryWinCount = 0;
    } else {
      lotteryCount = 0;
    }
    print("SlotGameConfig >> getDesignModeAllLotteryList gameRTP: $gameRTP >> lotteryWinCount: $lotteryWinCount, lotteryCount: $lotteryCount");

    // 符合RTP中獎機率的盤面陣列
    List<List<List<int>>> designModeAllLotteryList = [];

    // 加入未中獎的盤面
    for (int i = 0; i < lotteryCount; i++) {
      final index = Random().nextInt(designModeLotteryList.length);
      designModeAllLotteryList.add(designModeLotteryList[index]);
    }

    if (lotteryWinCount > 0) {
      // 加入中獎的盤面
      designModeAllLotteryList.addAll(designModeLotteryWinList);
    }

    return designModeAllLotteryList;
  }

  /// 取得遊戲模式開獎盤面(用於運作程式邏輯)
  static List<List<int>> getGameModeLottery({required List<List<List<int>>> designModeAllLotteryList, required index}) {
    final designModeLottery = designModeAllLotteryList[index];
    // 將設計模式開獎盤面轉換為遊戲運作用的盤面
    List<List<int>> gameModeLottery = [];
    for (int i = 0; i < barCount; i++) {
      List<int> barItemList = [];
      for (int j = 0; j < barItemCount; j++) {
        barItemList.add(designModeLottery[j][i]);
      }
      gameModeLottery.add(barItemList);
    }

    return gameModeLottery;
  }
}
