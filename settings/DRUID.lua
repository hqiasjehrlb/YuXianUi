xianDRUID = { -- 小D
  SEND = {
    [50769] = xianCOMMON["ZANKI"], -- 復活
  },
  SUCCESS = {
    [50769] = xianCOMMON["ZANKI_SUCCES"],
    [22812] = {
      {
        ["int"] = 1,
        ["text"] = "%player 已開啟 %skill 硬梆梆12秒!"
      },
    },
    [61336] = {
      {
        ["int"] = 1,
        ["text"] = "%player 已開啟 %skill 硬梆梆6秒!",
      },
    },
    [20484] = { -- 戰復
      {
        ["int"] = 1,
        ["text"] = "%target 起來吧, 我的勇士!",
      },
    },
  },
};