local _, ns = ...

-- Local shortcuts for global functions
local ceil = math.ceil
local ipairs = ipairs
local tostring = tostring
local type = type

-- Wow APIs
local CreateFrame = CreateFrame -- luacheck: globals CreateFrame
local UIParent = UIParent -- luacheck: globals UIParent

-- Libraries
local LibStub = LibStub -- luacheck: globals LibStub
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

if ns.util == nil then
    ns.util = {}
end

-- Borrowed from WeakAuras
-- WeakAuras is licensed under GPLv2
ns.util.WA_Utf8Sub = function(input, size)
    local output = ""
    input = tostring(input)
    if type(input) ~= "string" then
        return output
    end
    local i = 1
    while (size > 0) do
        local byte = input:byte(i)
        if not byte then
            return output
        end
        if byte < 128 then
            -- ASCII byte
            output = output .. input:sub(i, i)
            size = size - 1
        elseif byte < 192 then
            -- Continuation bytes
            output = output .. input:sub(i, i)
        elseif byte < 244 then
            -- Start bytes
            output = output .. input:sub(i, i)
            size = size - 1
        end
        i = i + 1
    end

    -- Add any bytes that are part of the sequence
    while (true) do
        local byte = input:byte(i)
        if byte and byte >= 128 and byte < 192 then
            output = output .. input:sub(i, i)
        else
            break
        end
        i = i + 1
    end

    return output
end

ns.util.CreateCategoryFrame = function(title)
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -3)
    f:SetSize(176, 0)
    f:SetFrameStrata("BACKGROUND")

    local titleFrame = CreateFrame("Frame", nil, f)
    titleFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleFrame.text = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleFrame.text:SetPoint("LEFT")
    titleFrame.text:SetFontHeight(12)
    titleFrame.text:SetText(title)
    titleFrame:SetSize(ceil(titleFrame.text:GetWidth()), 14)

    return f
end

ns.util.ExpandFrame = function(f)
    local children = { f:GetChildren() }

    local shown = 0
    for _, child in ipairs(children) do
        if child:IsShown() then
            shown = shown + 1
        end
    end

    f:SetHeight(14 * shown)
end

ns.util.ProgressBar = function(parent, startColor, endColor)
    if endColor == nil then
        endColor = startColor
    end

    local f = CreateFrame("Frame", nil, parent)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -15)
    f:SetSize(176, 14)

    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.label:SetPoint("LEFT")
    f.label:SetPointsOffset(3, 0)
    f.label:SetFontHeight(12)
    f.label:SetTextColor(1, 1, 1)

    f.value = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.value:SetPoint("RIGHT")
    f.value:SetPointsOffset(-3, 0)
    f.value:SetFontHeight(12)
    f.value:SetTextColor(1, 1, 1)

    local background = f:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetSize(176, 14)
    background:SetColorTexture(0, 0, 0, 0.12)

    f.bar = f:CreateTexture(nil, "ARTWORK")
    f.bar:SetPoint("LEFT")
    f.bar:SetSize(176, 14)
    f.bar:SetTexture(LibSharedMedia:Fetch("statusbar", "Skyline"))
    f.bar:SetGradient("HORIZONTAL", startColor, endColor)

    f:Hide()

    return f
end
