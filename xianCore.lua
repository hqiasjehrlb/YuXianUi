xianCore = {};

local skillList = {
  ["WARRIOR"] = xianWARRIOR,
  ["MAGE"] = xianMAGE,
  ["WARLOCK"] = xianWARLOCK,
  ["DRUID"] = xianDRUID,
  ["DEATHKNIGHT"] = xianDEATHKNIGHT,
  ["PALADIN"] = xianPALADIN,
  ["MONK"] = xianMONK,
  ["DEMONHUNTER"] = xianDEMONHUNTER,
  ["SHAMAN"] = xianSHAMAN,
  ["PRIEST"] = xianPRIEST,
  ["HUNTER"] = xianHUNTER,
  ["ROGUE"] = xianROGUE,
};
local xianSetting = nil;

local spellTarget = {};

local function say(talks, idx, player, linkStr, target)
  local ch = "YELL";
  if IsInInstance() then
    if HasLFGRestrictions() then
      ch = "INSTANCE_CHAT";
    elseif IsInRaid() then
      if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
        ch = "RAID_WARNING";
      else
        ch = "RAID";
      end
    elseif UnitInParty("player") then
      ch = "PARTY";
    end
  end
  if talks["ch"] ~= nil then
    ch = talks["ch"];
  end
  local text = talks[idx]["text"];
  local t = talks[idx]["int"];
  text = string.gsub(text, "%%player", player);
  text = string.gsub(text, "%%skill", linkStr);
  text = string.gsub(text, "%%target", target);

  SendChatMessage(text, ch);
  idx = idx + 1;
  if idx <= table.getn(talks) then
    C_Timer.After(t, function()
      say(talks, idx, player, linkStr, target);
    end);
  end
end

local function unitSpellCastS(...)
  local status, caster, _, spellId = ...;
  local spellName = GetSpellInfo(spellId);
  if testMode == true then
    print(caster, spellId, spellName);
  end
  local target = spellTarget[spellId] or "";
  local player = UnitName(caster);
  local linkStr = GetSpellLink(spellId);
  if caster == "player" or caster == "pet" then
    if status == "SUCCEEDED" then
      local talks = xianSetting.SUCCESS[spellName];
      if talks == nil then
        talks = xianSetting.SUCCESS[spellId];
      end
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    elseif status == "START" then
      local talks = xianSetting.SEND[spellName];
      if talks == nil then
        talks = xianSetting.SEND[spellId];
      end
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    end
  end
end

local function mergeSetting(playerSet)
  if playerSet ~= nil then
    if playerSet["SEND"] ~= nil then
      for k, v in pairs(playerSet["SEND"]) do
        xianCOMMON["SEND"][k] = v;
      end
    end
    if playerSet["SUCCESS"] ~= nil then
      for k, v in pairs(playerSet["SUCCESS"]) do
        xianCOMMON["SUCCESS"][k] = v;
      end
    end
  end

  return xianCOMMON;
end

function xianCore.create(theFrame)
  local _, playerClass = UnitClass("player");
  xianSetting = mergeSetting(skillList[playerClass]);

  if xianSetting == nil then
    return ;
  end

  xianCore.frame = theFrame or CreateFrame("FRAME");

  -- register events
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SENT");

  xianCore.frame:SetScript("OnEvent", function(...)
    local table1, event = ...;
    if testMode then
      print(...); -- test mode
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      unitSpellCastS("SUCCEEDED", select(3, ...));
    elseif event == "UNIT_SPELLCAST_SENT" then
      local c, t, _, s = select(3, ...);
      spellTarget[s] = t;
      unitSpellCastS("START", c, _, s);
    end
  end);
end

xianCore.create();
