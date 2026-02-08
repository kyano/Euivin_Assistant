-- Wow APIs
local CreateFrame = CreateFrame -- luacheck: globals CreateFrame
local C_CVar = C_CVar -- luacheck: globals C_CVar

-- Libraries
local LibStub = LibStub -- luacheck: globals LibStub
local LibSharedMedia = LibStub("LibSharedMedia-3.0")
LibSharedMedia:Register("statusbar", "Clean", "Interface\\AddOns\\EuivinChan_Assistant\\Textures\\Statusbar_Clean.blp")

if _G.Euivin == nil then
  _G.Euivin = {}
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript(
  "OnEvent",
  function()
    C_CVar.SetCVar("nameplateOverlapV", "1.5")
    C_CVar.SetCVar("nameplateLargerScale", "1")
    C_CVar.SetCVar("nameplateSelectedScale", "1")
    C_CVar.SetCVar("nameplateMinScale", "1")
    C_CVar.SetCVar("nameplateMinAlpha", "1")
end)
