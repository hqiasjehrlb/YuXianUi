xianPALADIN = { -- 聖騎
  SEND = {
    [7328] = xianCOMMON["ZANKI"],
  },
  SUCCESS = {
    [7328] = xianCOMMON["ZANKI_SUCCESS"],
    [642] = { -- 聖盾
      {
        ["int"] = 1,
        ["text"] = "%player 開啟無敵蛋殼!! %skill"
      }
    },
    [1022] = { -- 保護
      {
        ["int"] = 1,
        ["text"] = "為 %target 施放 %skill 物理免傷幫你撐10秒!"
      },
      {
        ["int"] = 1,
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
        ["int"] = 1,
        ["text"] = "%player 已施放 %skill 硬邦邦撐8秒!"
      },
    },
  },
};