require("xianSetting");
json = require("json");
inspect = require("inspect");

function convTableToJStr (t)
  return json.encode(t);
end

function convJStrToTStr (js)
  return inspect(json.decode(js));
end
