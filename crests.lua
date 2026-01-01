local _, ns = ...

-- Local shortcuts for global functions
local _G = _G
local floor = math.floor
local ipairs = ipairs
local max = math.max

-- Wow APIs
local C_CurrencyInfo = C_CurrencyInfo -- luacheck: globals C_CurrencyInfo
local CreateColorFromHexString = CreateColorFromHexString -- luacheck: globals CreateColorFromHexString
local CreateFrame = CreateFrame -- luacheck: globals CreateFrame
local strlenutf8 = strlenutf8 -- luacheck: globals strlenutf8

-- Libraries
local LibStub = LibStub -- luacheck: globals LibStub

-- Local/session variables
local data = ns.data
local util = ns.util
local childrenFrames = {}
local startColor = CreateColorFromHexString("ffff4d96")
local endColor = CreateColorFromHexString("fffcb6ff")
local noLimitColor = CreateColorFromHexString("ffaeff69")
local maxColor = CreateColorFromHexString("ffff0058")

local function EuivinCrestsHandler()
    for i = 1, #data.Crests, 1 do
        local labelText, valueText
        local r = nil
        local g = nil
        local b = nil

        local fullName = _G.EuivinCrestsCache[i].name
        local current = _G.EuivinCrestsCache[i].current
        local maxQuantity = _G.EuivinCrestsCache[i].max

        if maxQuantity == 0 then
            childrenFrames[i].bar:Hide()

            labelText = fullName
            valueText = current

            r, g, b = noLimitColor:GetRGB()
        else
            local width
            width = floor((current / maxQuantity) * 176)
            childrenFrames[i].bar:SetWidth(width)

            if strlenutf8(fullName) > 8 then
                labelText = util.WA_Utf8Sub(fullName, 8) .. "..."
            else
                labelText = fullName
            end
            valueText = current .. "/" .. maxQuantity

            if current == maxQuantity then
                r, g, b = maxColor:GetRGB()
            end
        end

        childrenFrames[i].label:SetText(labelText)
        childrenFrames[i].value:SetText(valueText)

        if r ~= nil and g ~= nil and b ~= nil then
            childrenFrames[i].value:SetTextColor(r, g, b)
        end
    end
end

local function EuivinInitCrests()
    if _G.EuivinCrestsCache == nil or next(_G.EuivinCrestsCache) == nil then
        _G.EuivinCrestsCache = {
            ["init"] = false,
        }
        for i = 1, #data.Crests, 1 do
            _G.EuivinCrestsCache[i] = {
                ["name"] = "",
                ["current"] = 0,
                ["max"] = 0,
            }
        end
    end

    if _G.EuivinCrests == nil then
        _G.EuivinCrests = {}
    end
    if _G.EuivinCrests.callbacks == nil then
        _G.EuivinCrests.callbacks = LibStub("CallbackHandler-1.0"):New(_G.EuivinCrests)
    end

    _G.EuivinCrests:RegisterCallback("EUIVIN_CRESTS", EuivinCrestsHandler)
end

local function EuivinGetCrests()
    local updated = false

    for i, c in ipairs(data.Crests) do
        local info = C_CurrencyInfo.GetCurrencyInfo(c)

        if _G.EuivinCrestsCache[i].name ~= info.name then
            _G.EuivinCrestsCache[i].name = info.name
            updated = true
        end

        local quantity = info.quantity
        if _G.EuivinCrestsCache[i].current ~= quantity then
            _G.EuivinCrestsCache[i].current = quantity
            updated = true
        end

        local maxQuantity = max(0, quantity + (info.maxQuantity - info.totalEarned))
        if _G.EuivinCrestsCache[i].max ~= maxQuantity then
            _G.EuivinCrestsCache[i].max = maxQuantity
            updated = true
        end
    end

    if updated or not _G.EuivinCrestsCache.init then
        _G.EuivinCrestsCache.init = true
        _G.EuivinCrests.callbacks:Fire("EUIVIN_CRESTS")
    end
end

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:RegisterEvent("ADDON_LOADED")
hiddenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hiddenFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
-- XXX: There may be a better way to check whether the weekly reset is done.
hiddenFrame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
hiddenFrame:SetScript(
    "OnEvent",
    function(_, event, ...)
        if event == "ADDON_LOADED" then
            EuivinInitCrests()
            return
        end
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyType = ...
            local isCrests = false
            for _, c in ipairs(data.Crests) do
                if currencyType == c then
                    isCrests = true
                    break
                end
            end
            if not isCrests then
                return
            end
        end
        -- event == all others incl. valid `CURRENCY_DISPLAY_UPDATE'.
        EuivinGetCrests()
    end)

-- XXX: Is it better to move these to a separated XML file?
-- TODO: Localize strings
local crestsFrame = util.CreateCategoryFrame("아이템 강화", "EuivinCrestsFrame", "EuivinDelveFrame")
for i = 1, #data.Crests, 1 do
    childrenFrames[i] = util.ProgressBar(crestsFrame, startColor, endColor)
    childrenFrames[i]:SetPointsOffset(0, -15 * i)
    childrenFrames[i]:Show()
end
util.ExpandFrame(crestsFrame)
