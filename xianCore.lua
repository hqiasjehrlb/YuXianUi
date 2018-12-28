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
local channelList = {};
local spellingList = {};
local spellTarget = {};

local function debugPrint (...)
  if testMode then
    print(...);
  end
end

local function say(talks, idx, player, linkStr, target, spellId, extSpell)
  local origIdx = idx;
  local ch = "YELL";
  if IsInInstance() then
    local instanceName, instanceType = GetInstanceInfo();
    if HasLFGRestrictions() then
      ch = "INSTANCE_CHAT";
    elseif instanceType == "raid" then
      if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
        ch = "RAID_WARNING";
      elseif IsInRaid() then
        ch = "RAID";
      end
    elseif instanceType == "party" then
      ch = "PARTY";
    end
  end
  if talks[idx]["ch"] ~= nil then
    ch = talks[idx]["ch"];
  end
  if talks[1]["random"] == true then
    idx = math.random(table.getn(talks));
  end
  if spellId then
    idx = origIdx;
  end
  local talk = talks[idx];
  local text = talk["text"];
  if spellId and channelList[spellId] == nil and talk["end"] then
    text = talk["end"];
  end
  local t = talk["int"];
  text = string.gsub(text, "%%player", player);
  text = string.gsub(text, "%%skill", linkStr);
  text = string.gsub(text, "%%target", target);
  if extSpell then
    text = string.gsub(text, "%%tskill", extSpell);
  end

  if spellId and channelList[spellId] == nil and spellingList[spellId] == nil then
    if talk["end"] then
      SendChatMessage(text, ch);
    end
    return ;
  end

  SendChatMessage(text, ch);
  if talks[1]["random"] ~= true or spellId then
    if spellId then
      if channelList[spellId] ~= nil then
        C_Timer.After(t, function()
          say(talks, idx, player, linkStr, target, spellId);
        end);
      elseif spellingList[spellId] ~= nil then
        idx = idx + 1;
        if idx <= table.getn(talks) then
          C_Timer.After(t, function()
            say(talks, idx, player, linkStr, target, spellId);
          end);
        end
      end
    else
      idx = idx + 1;
      if idx <= table.getn(talks) then
        C_Timer.After(t, function()
          say(talks, idx, player, linkStr, target);
        end);
      end
    end
  end
end

local function unitSpellCastS(...)
  local status, caster, _, spellId, extSpellId = ...;
  local spellName = GetSpellInfo(spellId);
  local target = spellTarget[spellId] or "";
  local player = UnitName(caster);
  local linkStr = GetSpellLink(spellId);
  local extSpell = GetSpellLink(extSpellId);
  debugPrint(caster, player, spellId, spellName);
  if caster == "player" or caster == player or caster == "pet" then
    if status == "SUCCEEDED" then
      local talks = xianDB.SUCCESS[spellName] or xianDB.SUCCESS[spellId];
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    elseif status == "START" then
      local talks = xianDB.SEND[spellName] or xianDB.SEND[spellId];
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    elseif status == "CHANNEL" then
      local talks = xianDB.CHANNEL[spellName] or xianDB.CHANNEL[spellId];
      if talks ~= nil and talks[1] ~= nil then
        local idx = 1;
        if talks[1]["random"] then
          idx = math.random(table.getn(talks));
        end
        channelList[spellId] = idx;
        say(talks, idx, player, linkStr, target, spellId);
      end
    elseif status == "SPELLSTART" then
      local talks = xianDB.CHANNEL[spellName] or xianDB.CHANNEL[spellId];
      if talks ~= nil and talks[1] ~= nil then
        local idx = 1;
        if talks[1]["random"] then
          idx = math.random(table.getn(talks));
        end
        spellingList[spellId] = idx;
        say(talks, idx, player, linkStr, target, spellId);
      end
    elseif status == "INTERRUPT" then
      debugPrint("before say");
      local talks = xianDB.INTERRUPT[spellName] or xianDB.INTERRUPT[spellId];
      if talks ~= nil and talks[1] ~= nil then
        debugPrint("get talk");
        say(talks, 1, player, linkStr, target, nil, extSpell);
      end
    end
  end
end

local function mergeSetting(playerSet)
  if xianCOMMON["INTERRUPT"] == nil then
    xianCOMMON["INTERRUPT"] = {};
  end
  if xianCOMMON["SEND"] == nil then
    xianCOMMON["SEND"] = {};
  end
  if xianCOMMON["CHANNEL"] == nil then
    xianCOMMON["CHANNEL"] = {};
  end
  if xianCOMMON["SUCCESS"] == nil then
    xianCOMMON["SUCCESS"] = {};
  end

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
    if playerSet["CHANNEL"] ~= nil then
      for k, v in pairs(playerSet["CHANNEL"]) do
        xianCOMMON["CHANNEL"][k] = v;
      end
    end
    if playerSet["INTERRUPT"] ~= nil then
      for k, v in pairs(playerSet["INTERRUPT"]) do
        xianCOMMON["INTERRUPT"][k] = v;
      end
    end
  end

  return xianCOMMON;
end

function xianCore.create(theFrame)
  local _, playerClass = UnitClass("player");
  mergeSetting(skillList[playerClass]);
  xianDB = mergeSetting(xianDB);

  xianCore.frame = theFrame or CreateFrame("FRAME");

  -- register events 
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SENT");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_START");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
  xianCore.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  xianCore.frame:SetScript("OnEvent", function(...)
    local _, event = ...;
    debugPrint(...);
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      unitSpellCastS("SUCCEEDED", select(3, ...));
    elseif event == "UNIT_SPELLCAST_SENT" then
      local c, t, _, s = select(3, ...);
      spellTarget[s] = t;
      unitSpellCastS("START", c, _, s);
    elseif event == "UNIT_SPELLCAST_START" then
      local c, _, s = select(3, ...);
      unitSpellCastS("SPELLSTART", c, _, s);
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
      unitSpellCastS("CHANNEL", select(3, ...));
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
      local _, _, s = select(3, ...);
      channelList[s] = nil;
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
      local _, _, s = select(3, ...);
      spellingList[s] = nil;
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
      local _, e, _, _, c, _, _, _, t, _, _, s, _, _, extS = CombatLogGetCurrentEventInfo();
      if (e == "SPELL_INTERRUPT") then
        debugPrint(e, c, t, s, extS);
        spellTarget[s] = t;
        unitSpellCastS("INTERRUPT", c, _, s, extS);
      end
    end
  end);
end

function xianCore.getSettings (typeName)
  if xianDB == nil or typeName == nil then
    return nil;
  else
    return xianDB[typeName];
  end
end

function xianCore.setDB (typeName, spell, sets)
  if type(xianDB[typeName]) ~= "table" then
    xianDB[typeName] = {};
  end
  xianDB[typeName][spell] = sets;
end