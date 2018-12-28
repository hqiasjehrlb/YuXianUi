xianPALADIN = { -- 聖騎
  SEND = {},
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
    [86659] = { -- 遠古諸王
      {
        ["ch"] = "EMOTE",
        ["int"] = 1,
        ["text"] = "已施放 %skill 硬邦邦撐8秒!"
      },
    },
  },
  CHANNEL = {
    [7328] = xianCOMMON["ZANKI"],
  },
  INTERRUPT = {
    [96231] = { -- 責難
      {
        ["int"] = 1,
        ["ch"] = "YELL",
        ["text"] = "%player 用 %skill 打斷了 %target 的 %tskill",
      },
    },
    [31935] = { -- 復仇之盾
      {
        ["int"] = 1,
        ["ch"] = "EMOTE",
        ["text"] = "%player 對 %target 扔了一個 %skill 打斷了 %target 的 %tskill"
      },
      {
        ["int"] = 1,
        ["ch"] = "YELL",
        ["text"] = "%target 已經被我打到暫時說不出話了!"
      }
    }
  }
};