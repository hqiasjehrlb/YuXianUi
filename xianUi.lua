local xianUi = nil;

local locales = {
  ["zh"] = xianLocales_zh
};

xianUi = {};

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

local mainFrame;
local addSkillFrame;
local spellIDEditBox;

local TypeDropDown; -- listen type dropdown list
local SelectedType;
local SkillDropDown; -- skill list dropdown list
local SelectedSkill;
local CHDropDowns; -- channel list dropdown list array
local SelectedCHs; -- array


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

local function YuXianUiCHDropDown (parentF)

end

local function YuXianUiSkillDropDown (parentF, monitType)
  SkillDropDown = SkillDropDown or CreateFrame("Frame", "$parentSkillDropDown", parentF, "UIDropDownMenuTemplate");
  SkillDropDown:SetPoint("TOPLEFT", "$parentTypeDropDown", "BOTTOMLEFT", 0, 0);
  SelectedSkill = nil;
  UIDropDownMenu_SetWidth(SkillDropDown, 150);
  UIDropDownMenu_SetText(SkillDropDown, YuXianUi_ChooseSkill);
  UIDropDownMenu_Initialize(SkillDropDown, function (...)
    local settings = xianCore.getSettings(monitType);
    if settings ~= nil then
      local info = UIDropDownMenu_CreateInfo();
      local setVal = function (newVal)
        SelectedSkill = newVal.arg1;
        UIDropDownMenu_SetText(SkillDropDown, newVal.value);
        CloseDropDownMenus();
      end
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

local function YuXianUiTypeDropDown (parentF)
  addSkillFrame:Hide();
  TypeDropDown = TypeDropDown or CreateFrame("Frame", "$parentTypeDropDown", parentF, "UIDropDownMenuTemplate");
  TypeDropDown:SetPoint("TOPLEFT", "$parentSubText", "BOTTOMLEFT", -16, 0);
  SelectedType = nil;
  UIDropDownMenu_SetWidth(TypeDropDown, 150);
  UIDropDownMenu_SetText(TypeDropDown, YuXianUi_ChooseMonitType);
  UIDropDownMenu_Initialize(TypeDropDown, function (...)
    local info = UIDropDownMenu_CreateInfo();
    local setVal = function (newVal)
      SelectedType = newVal.arg1;
      UIDropDownMenu_SetText(TypeDropDown, newVal.value);
      YuXianUiSkillDropDown(parentF, SelectedType);
      addSkillFrame:Show();
      CloseDropDownMenus();
    end
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
end

local function init ()
  print("init");
  spellIDEditBox:SetText("");
  YuXianUiTypeDropDown(mainFrame);
  YuXianUiSkillDropDown(mainFrame);
end

function xianUi_cancel ()
  print("cancel");
  init();
end

function xianUi_ok ()
  print("ok");
  init();
end

function xianUiSearchSkill ()
  local v = spellIDEditBox:GetText();
  print(v);
  local _, _, _, _, _, _, id = GetSpellInfo(v);
  spellIDEditBox:SetText(id or "");
end

function xianUiAddSkill ()
  local v = spellIDEditBox:GetText();
  if v ~= "" and SelectedType then
    xianDB[SelectedType][v] = {};
    spellIDEditBox:SetText("");
    spellIDEditBox:ClearFocus();
    YuXianUiSkillDropDown(mainFrame, SelectedType);
  end
end

function xianUiSpellIDOnload (f)
  spellIDTextFrame = spellIDTextFrame or f;
end

function xianUiOnload (panel)
  xianCore.create();

  mainFrame = mainFrame or panel;
  addSkillFrame = mainFrame:GetChildren();
  spellIDEditBox = addSkillFrame:GetChildren();
  InterfaceOptions_AddCategory(mainFrame);
  init();
end



function xianUiTest()
  local child1 = mainFrame:GetChildren();
  child1:Show();
  print(child1:GetName());
end