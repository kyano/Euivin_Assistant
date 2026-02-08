local addonName = ...

-- Wow APIs
local CreateFrame = CreateFrame -- luacheck: globals CreateFrame
local UIParent = UIParent -- luacheck: globals UIParent

-- `EuivinConfig' is from SavedVariables
-- luacheck: globals EuivinConfig

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:RegisterEvent("ADDON_LOADED")
hiddenFrame:SetScript(
  "OnEvent",
  function(_, event, ...)
    if event == "ADDON_LOADED" then
      local loadedAddon = ...
      if loadedAddon == addonName then
        hiddenFrame:UnregisterEvent("ADDON_LOADED")
        hiddenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        hiddenFrame:RegisterEvent("UI_SCALE_CHANGED")
        hiddenFrame:RegisterEvent("GX_RESTARTED")
      end
      return
    end
    -- event == all others
    if EuivinConfig.UIScale.enable then
      UIParent:SetScale(EuivinConfig.UIScale.factor)
    else
      hiddenFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
      hiddenFrame:UnregisterEvent("UI_SCALE_CHANGED")
      hiddenFrame:UnregisterEvent("GX_RESTARTED")
    end
end)
