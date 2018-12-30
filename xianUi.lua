xianUi = {};

local locales = {
  ["zh"] = xianLocales_zh
};

YuXianUi_VERSION = "1.0.0";
YuXianUi_UIPANEL_SUBTEXT = "ui 喊話設定";
YuXianUi_ADD_LISTEN_SKILL = "增加監控技能";
YuXianUi_SEARCH_SKILL_ID = "查ID";
YuXianUi_SKILLID = "spellID";
YuXianUi_ChooseMonitType = "選擇監控事件類型";
YuXianUi_ChooseSkill = "選擇監控技能";
YuXianUi_Type_INTERRUPT = "斷法技能";
YuXianUi_Type_CHANNEL = "施法/引導";
YuXianUi_Type_SEND = "開始施法";
YuXianUi_Type_SUCCESS = "法術施放成功";
YuXianUi_Select_Talk = "選擇要編輯的喊話"
YuXianUi_WaitText = "等待";
YuXianUi_WaitSecondsText = "秒";
YuXianUi_TalkContentText = "喊話內容";
YuXianUi_Select_CH = "選擇喊話頻道";
YuXianUi_CH_AUTO = "自動";
YuXianUi_CH_YELL = "大喊";
YuXianUi_CH_EMOTE = "表情/e";
YuXianUi_Random_Tooltip = "啟動隨機喊話";
YuXianUi_Remove_Skill = "移除此技能喊話";

-- local vars
-- frames
local mainFrame;
local addSkillFrame;
local setTalkFrame;
local endTalkFrame;
local spellIDEditBox;
local intEditBox;
local talkEditBox;
local endTalkEditBox;
local TypeDropDown; -- listen type dropdown list
local SkillDropDown; -- skill list dropdown list
local SelectTalkDropDown; -- talk select dropdown list
local SelectCHDropDown; -- ch select dropdown list
local CheckRandomCheckButton;
-- selected vals
local SelectedType;
local SelectedSkill;
local SelectedTalk;
local SelectedCH;

local CHLocaleMap = {
  ["AUTO"] = YuXianUi_CH_AUTO,
  ["EMOTE"] = YuXianUi_CH_EMOTE,
  ["YELL"] = YuXianUi_CH_YELL
};

-- local funcs

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '}';
  else
    return tostring(o);
  end
end

local function YuXianUiSelCHDropDown ()
  SelectedCH = nil;
  UIDropDownMenu_SetText(SelectCHDropDown, YuXianUi_Select_CH);
end

local function YuXianUiSelTalkDropDown ()
  local setVal = function (newVal)
    SelectedTalk = newVal.value;
    UIDropDownMenu_SetText(SelectTalkDropDown, SelectedTalk);
    if xianDB
      and xianDB[SelectedType]
      and xianDB[SelectedType][SelectedSkill]
      and type(xianDB[SelectedType][SelectedSkill][SelectedTalk]) == "table"
    then
      local talk = xianDB[SelectedType][SelectedSkill][SelectedTalk];
      intEditBox:SetText(talk.int or 1);
      talkEditBox:SetText(talk.text or "");
      endTalkEditBox:SetText(talk["end"] or "");
      SelectedCH = talk.ch or "AUTO";
      UIDropDownMenu_SetText(SelectCHDropDown, CHLocaleMap[SelectedCH]);
    end
    CloseDropDownMenus();
  end

  UIDropDownMenu_Initialize(SelectTalkDropDown, function ()
    SelectedTalk = nil;
    UIDropDownMenu_SetText(SelectTalkDropDown, YuXianUi_Select_Talk);

    if xianDB[SelectedType] and type(xianDB[SelectedType][SelectedSkill]) == "table" then
      local talks = xianDB[SelectedType][SelectedSkill];
      
      if type(talks[1]) == "table" then
        local isRandom = talks[1]["random"];
        CheckRandomCheckButton:SetChecked(isRandom);
      end

      local info = UIDropDownMenu_CreateInfo();
      for k, v in pairs(talks) do
        info.func = setVal;
        info.text = k;
        info.arg1 = v;
        info.checked = SelectedTalk == k;
        UIDropDownMenu_AddButton(info);
      end
    end
  end);
end

local function YuXianUiInitSetTalkFrame ()
  YuXianUiSelTalkDropDown();
  YuXianUiSelCHDropDown();
  intEditBox:SetText("");
  talkEditBox:SetText("");
  endTalkEditBox:SetText("");
  setTalkFrame:Show();
  if SelectedType == "CHANNEL" then
    endTalkFrame:Show();
  else
    endTalkFrame:Hide();
  end
end

local function YuXianUiSkillDropDown ()
  local setVal = function (newVal)
    SelectedSkill = newVal.arg1;
    UIDropDownMenu_SetText(SkillDropDown, newVal.value);
    YuXianUiInitSetTalkFrame();
    CloseDropDownMenus();
  end

  UIDropDownMenu_Initialize(SkillDropDown, function ()
    SelectedSkill = nil;
    UIDropDownMenu_SetText(SkillDropDown, YuXianUi_ChooseSkill);
    
    local settings = xianDB[SelectedType];
    if type(settings) == "table" then
      local info = UIDropDownMenu_CreateInfo();

      for k, _ in pairs(settings) do
        local spellName = GetSpellInfo(k);
        local presentVal = k;
        if spellName and k ~= spellName then
          presentVal = k .. "-" .. spellName;
        end
        info.func = setVal;
        info.text = presentVal;
        info.arg1 = k;
        info.checked = SelectedSkill == k;
        UIDropDownMenu_AddButton(info);
      end
    end
  end);
end

local function YuXianUiInitAddSkillFrame ()
  spellIDEditBox:SetText("");
  addSkillFrame:Show();
end

local function YuXianUiTypeDropDown ()
  SelectedType = nil;
  UIDropDownMenu_SetText(TypeDropDown, YuXianUi_ChooseMonitType);
end

local function init ()
  YuXianUiTypeDropDown();
  YuXianUiSkillDropDown();
  YuXianUiSelTalkDropDown();
  addSkillFrame:Hide();
  setTalkFrame:Hide();
end

function xianUi_cancel ()
  init();
end

function xianUi_ok ()
  init();
end

-- OK
function xianUiSearchSkill ()
  local v = spellIDEditBox:GetText();
  local _, _, _, _, _, _, id = GetSpellInfo(v);
  spellIDEditBox:SetText(id or "");
end

-- OK
function xianUiAddSkill ()
  local v = spellIDEditBox:GetText();
  if v ~= "" and SelectedType then
    xianDB[SelectedType][v] = {};
    spellIDEditBox:SetText("");
    spellIDEditBox:ClearFocus();
    YuXianUiSkillDropDown();
  end
end

-- OK
function xianUiAddTalk ()
  if xianDB
    and xianDB[SelectedType]
    and type(xianDB[SelectedType][SelectedSkill]) == "table"
  then
    table.insert(xianDB[SelectedType][SelectedSkill], {
      ["text"] = "";
      ["int"] = 1;
      ["ch"] = nil;
      ["end"] = nil;
    });
  end
  YuXianUiInitSetTalkFrame();
end

-- OK
function xianUiRemTalk ()
  if xianDB
    and xianDB[SelectedType]
    and type(xianDB[SelectedType][SelectedSkill]) == "table"
  then
    table.remove(xianDB[SelectedType][SelectedSkill]);
  end
  YuXianUiInitSetTalkFrame();
end

-- OK
function xianUiSaveTalk ()
  local t = SelectedType;
  local s = SelectedSkill;
  local i = SelectedTalk;
  print(t, s, i);
  if type(xianDB) == "table"
    and type(xianDB[t]) == "table"
    and type(xianDB[t][s]) == "table"
    and type(xianDB[t][s][i]) == "table"
  then
    local text = talkEditBox:GetText();
    local talk = {
      ["text"] = text,
      ["int"] = tonumber(intEditBox:GetText()) or 0,
    };
    if SelectedCH ~= nil and SelectedCH ~= "AUTO" then
      talk["ch"] = SelectedCH;
    end
    local endText = endTalkEditBox:GetText();
    if endText ~= "" and t == "CHANNEL" then
      talk["end"] = endText;
    end
    if i == 1 then
      local isRandom = CheckRandomCheckButton:GetChecked();
      if isRandom then
        talk["random"] = true;
      else
        talk["random"] = false;
      end
    end
    xianDB[t][s][i] = talk;
    local isRandom = CheckRandomCheckButton:GetChecked();
    if type(xianDB) == "table"
      and type(xianDB[t]) == "table"
      and type(xianDB[t][s]) == "table"
      and type(xianDB[t][s][1]) == "table"
    then
      xianDB[t][s][1]["random"] = isRandom;
    end
  end
end

-- OK
function xianUiRemSkill ()
  local t = SelectedType;
  local s = SelectedSkill;
  if type(xianDB) == "table"
    and type(xianDB[t]) == "table"
  then
    xianDB[t][s] = nil;
  end
  YuXianUiSkillDropDown();
  setTalkFrame:Hide();
end

function xianUiOnload (panel)
  xianCore.create();

  mainFrame = mainFrame or panel;
  addSkillFrame, setTalkFrame = mainFrame:GetChildren();
  spellIDEditBox = addSkillFrame:GetChildren();
  intEditBox = setTalkFrame:GetChildren();

  -- type dropdown (static)
  TypeDropDown = CreateFrame("Frame", "$parentTypeDropDown", mainFrame, "UIDropDownMenuTemplate");
  TypeDropDown:SetPoint("TOPLEFT", "$parentSubText", "BOTTOMLEFT", -16, 0);
  UIDropDownMenu_SetWidth(TypeDropDown, 150);
  UIDropDownMenu_Initialize(TypeDropDown, function ()
    local setVal = function (newVal)
      SelectedType = newVal.arg1;
      UIDropDownMenu_SetText(TypeDropDown, newVal.value);
      YuXianUiSkillDropDown();
      YuXianUiInitAddSkillFrame();
      setTalkFrame:Hide();
      CloseDropDownMenus();
    end;
     -- add selection
    local info = UIDropDownMenu_CreateInfo();
    info.func = setVal;
    info.text = YuXianUi_Type_INTERRUPT;
    info.checked = SelectedType == "INTERRUPT";
    info.arg1 = "INTERRUPT"
    UIDropDownMenu_AddButton(info);
    info.func = setVal;
    info.text = YuXianUi_Type_SEND;
    info.checked = SelectedType == "SEND";
    info.arg1 = "SEND";
    UIDropDownMenu_AddButton(info);
    info.func = setVal;
    info.text = YuXianUi_Type_CHANNEL;
    info.checked = SelectedType == "CHANNEL";
    info.arg1 = "CHANNEL"
    UIDropDownMenu_AddButton(info);
    info.func = setVal;
    info.text = YuXianUi_Type_SUCCESS;
    info.checked = SelectedType == "SUCCESS";
    info.arg1 = "SUCCESS"
    UIDropDownMenu_AddButton(info);  
  end);

  -- skill dropdown (dynamic)
  SkillDropDown = CreateFrame ("Frame", "$parentSkillDropDown", mainFrame, "UIDropDownMenuTemplate");
  SkillDropDown:SetPoint("TOPLEFT", "$parentTypeDropDown", "BOTTOMLEFT", 0, 0);
  UIDropDownMenu_SetWidth(SkillDropDown, 150);

  -- selectTalk dropdown (dynamic)
  SelectTalkDropDown = CreateFrame("Frame", "$parentSelTalkDropDown", setTalkFrame, "UIDropDownMenuTemplate");
  SelectTalkDropDown:SetPoint("TOPLEFT", "$parent", "TOPLEFT", 0, -52);
  UIDropDownMenu_SetWidth(SelectTalkDropDown, 150);

  -- selectCH dropdown (static)
  SelectCHDropDown = CreateFrame("Frame", "$parentSelCHDropDown", setTalkFrame, "UIDropDownMenuTemplate");
  SelectCHDropDown:SetPoint("TOPLEFT", "$parent", "TOPLEFT", 150, -87);
  UIDropDownMenu_SetWidth(SelectCHDropDown, 100);
  UIDropDownMenu_Initialize(SelectCHDropDown, function ()
    local setVal = function (newVal)
      SelectedCH = newVal.arg1;
      UIDropDownMenu_SetText(SelectCHDropDown, newVal.value);
    end;
    local info = UIDropDownMenu_CreateInfo();
    info.func = setVal;
    info.text = YuXianUi_CH_AUTO;
    info.checked = SelectedCH == "AUTO";
    info.arg1 = "AUTO"
    UIDropDownMenu_AddButton(info);
    info.func = setVal;
    info.text = YuXianUi_CH_YELL;
    info.checked = SelectedCH == "YELL";
    info.arg1 = "YELL"
    UIDropDownMenu_AddButton(info);
    info.func = setVal;
    info.text = YuXianUi_CH_EMOTE;
    info.checked = SelectedCH == "EMOTE";
    info.arg1 = "EMOTE"
    UIDropDownMenu_AddButton(info);
  end);

  -- talk ScrollFrame EditBox (static)
  local ebFrame = CreateFrame("ScrollFrame", "$parentText", setTalkFrame, "InputScrollFrameTemplate");
  ebFrame:SetSize(300, 150);
  ebFrame:SetPoint("TOPLEFT", 30, -170);
  talkEditBox = ebFrame.EditBox;
  talkEditBox:SetMaxLetters(255);
  talkEditBox:SetWidth(300);

  -- endTalk ScrollFrame EditBox (static)
  endTalkFrame = CreateFrame("ScrollFrame", "$parentTextEnd", setTalkFrame, "InputScrollFrameTemplate");
  endTalkFrame:SetSize(300, 150);
  endTalkFrame:SetPoint("TOPLEFT", 30, -380);
  endTalkEditBox = endTalkFrame.EditBox;
  endTalkEditBox:SetMaxLetters(255);
  endTalkEditBox:SetWidth(300);
  endTalkFrame:Hide();

  -- check random checkbutton (static)
  CheckRandomCheckButton = CreateFrame("CheckButton", "$parentCheckRandom", setTalkFrame, "ChatConfigCheckButtonTemplate");
  CheckRandomCheckButton:SetPoint("TOPLEFT", 300, -50);
  CheckRandomCheckButton.tooltip = YuXianUi_Random_Tooltip;


  InterfaceOptions_AddCategory(mainFrame);
  init();
end

function xianTest()
  print(dump(xianDB));
end
