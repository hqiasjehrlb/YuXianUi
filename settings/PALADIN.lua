xianPALADIN = { -- 聖騎
  SEND = {
    [7328] = xianCOMMON["ZANKI"],
  },
  SUCCESS = {
    [7328] = xianCOMMON["ZANKI_SUCCESS"],
    [642] = { -- 聖盾
      {
        ["ch"] = "YELL",
        ["int"] = 1,
        ["text"] = "%player 開啟無敵蛋殼!! %skill !"
      },
      {
        ["int"] = 1,
        ["ch"] = "EMOTE",
        ["text"] = "不想被你們碰肩膀!!"
      }
    },
    [1022] = { -- 保護
      {
        ["int"] = 1,
        ["ch"] = "EMOTE",
        ["text"] = "為 %target 施放 %skill 物理免傷撐10秒!"
      },
      {
        ["int"] = 1,
        ["ch"] = "YELL",
        ["text"] = "%target 趕快使出c8763啊!",
      },
    },
    [96231] = { -- 責難
      {
        ["int"] = 1,
        ["text"] = "%player 對 %target 施放 %skill 斷法",
      },
    },
    [86659] = { -- 遠古諸王
      {
        ["ch"] = "EMOTE",
        ["int"] = 1,
        ["text"] = "已施放 %skill 硬邦邦撐8秒!"
      },
    },
  },
};