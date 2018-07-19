xianCore = {};

local stillList = {
  [64843] = 8,
  [64844] = 8,
};
local stillSpelling = false;

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
  print(ch);
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
  else
    stillSpelling = false;
  end
end

local function setStillSpelling(t)
  stillSpelling = true;
  C_Timer.After(t, function()
    stillSpelling = false;
  end);
end

local function unitSpellCastS(...)
  local status, caster, _, spellId = ...;
  local spellName = GetSpellInfo(spellId);
  if testMode == true then
    print(caster, spellId, spellName);
  end
  local target = UnitName("target") or "";
  local player = UnitName("player");
  local linkStr = "|cff71d5ff|Hspell:"..spellId.."|h["..spellName.."]|h|r";
  if caster == "player" then
    if status == "SUCCEEDED" then
      local talks = xianSetting.SUCCESS[spellName];
      if talks == nil then
        talks = xianSetting.SUCCESS[spellId];
      end
      if talks ~= nil and talks[1] ~= nil then
        if stillList[spellId] == nil or stillSpelling ~= true then
          if stillList[spellId] ~= nil then
            setStillSpelling(stillList[spellId]);
          end
          say(talks, 1, player, linkStr, target);
        end
      end
    elseif status == "START" then
      local talks = xianSetting.SEND[spellName];
      if talks == nil then
        talks = xianSetting.SEND[spellId];
      end
      if talks ~= nil and talks[1] ~= nil then
        if stillList[spellId] == nil or stillSpelling ~= true then
          if stillList[spellId] ~= nil then
            setStillSpelling(stillList[spellId]);
          end
          say(talks, 1, player, linkStr, target);
        end
      end
    end
  end
end

function xianCore.create(theFrame)
  xianCore.frame = theFrame or CreateFrame("FRAME");
  -- register events
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_START");
  xianCore.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  xianCore.frame:RegisterEvent("COMBAT_LOG_EVENT");

  xianCore.frame:SetScript("OnEvent", function(...)
    local _, event = ...;
    if testMode then
      print(...); -- test mode
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      unitSpellCastS("SUCCEEDED", select(3, ...));
    elseif event == "UNIT_SPELLCAST_START" then
      -- unitSpellCastS("START", select(3, ...));
    elseif event == "COMBAT_LOG_EVENT" and testMode then
      local _, _, _, event, _, _, _, _, _, _, _, _, auraType, _, skill = ...;
      if skill == "惡魔炸彈" then
        -- print(skill); -- test mode
      end
      -- SendChatMessage("來玩吧", "yell");
    end
  end);
end

xianCore.create();
