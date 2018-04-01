xianCore = {};

local function say(talks, idx, player, linkStr, target)
  local ch = "YELL";
  if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
    ch = "RAID_WARNING";
  elseif UnitInRaid("player") then
    ch = "RAID";
  elseif UnitInParty("player") then
    ch = "PARTY"
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
  local status, caster, spellName, spellRank, spellIdCounter, spellId = ...;
  local target = UnitName("target");
  local player = UnitName("player");
  local linkStr = "|cff71d5ff|Hspell:"..spellId.."|h["..spellName.."]|h|r";
  if caster == "player" then
    if status == "SUCCEEDED" then
      local talks = xianSetting.defaultSet.SUCCESS[spellName];
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    elseif status == "START" then
      local talks = xianSetting.defaultSet.SEND[spellName];
      if talks ~= nil and talks[1] ~= nil then
        say(talks, 1, player, linkStr, target);
      end
    end
  end
end

function xianCore.create(theFrame)
  xianSetting.setVar();
  xianCore.frame = theFrame or CreateFrame("xianCoreFrame");
  -- register events
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_START");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  --xianCore.frame:RegisterEvent("COMBAT_LOG_EVENT");

  xianCore.frame:SetScript("OnEvent", function(...)
    local arg1, event = ...;
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      unitSpellCastS("SUCCEEDED", select(3, ...));
    elseif event == "UNIT_SPELLCAST_START" then
      unitSpellCastS("START", select(3, ...));
    elseif event == "COMBAT_LOG_EVENT" then
      SendChatMessage("來玩吧", "yell");
    end
  end);
end