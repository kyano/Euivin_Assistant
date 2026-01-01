local _, ns = ...

-- Local shortcuts for global functions
local _G = _G
local floor = math.floor
local ipairs = ipairs
local next = next

-- Wow APIs
local C_MythicPlus = C_MythicPlus -- luacheck: globals C_MythicPlus
local C_WeeklyRewards = C_WeeklyRewards -- luacheck: globals C_WeeklyRewards
local CreateColorFromHexString = CreateColorFromHexString -- luacheck: globals CreateColorFromHexString
local CreateFrame = CreateFrame -- luacheck: globals CreateFrame

-- Libraries
local LibStub = LibStub -- luacheck: globals LibStub

-- Local/session variables
local data = ns.data
local util = ns.util
local rewardsFrame
local startColor = CreateColorFromHexString("ff5433ff")
local endColor = CreateColorFromHexString("ffb3a7ff")

local function EuivinDelveHandler()
    local runs = _G.EuivinDelveCache.runs
    rewardsFrame.label:SetFormattedText("보상 [%d/3]", runs)

    local width
    width = floor((runs / 3) * 176)
    if width == 0 then
        rewardsFrame.bar:Hide()
    else
        rewardsFrame.bar:Show()
        rewardsFrame.bar:SetWidth(width)
    end

    local rewardsText = ""
    if C_WeeklyRewards.CanClaimRewards() then
        rewardsFrame.value:SetText(rewardsText)
    end
    for i, ilvl in ipairs(_G.EuivinDelveCache.rewards) do
        if ilvl == 0 then
            break
        end
        if i == 1 then
            rewardsText = ilvl
        else
            rewardsText = rewardsText .. " || " .. ilvl
        end
    end
    rewardsFrame.value:SetText(rewardsText)
end

local function EuivinInitDelve()
    if _G.EuivinDelveCache == nil or next(_G.EuivinDelveCache) == nil then
        _G.EuivinDelveCache = {
            ["rewards"] = { 0, 0, 0 },
            ["runs"] = 0,
            ["init"] = false,
        }
    end

    if _G.EuivinDelve == nil then
        _G.EuivinDelve = {}
    end
    if _G.EuivinDelve.callbacks == nil then
        _G.EuivinDelve.callbacks = LibStub("CallbackHandler-1.0"):New(_G.EuivinDelve)
    end

    _G.EuivinDelve:RegisterCallback("EUIVIN_DELVE_REWARDS", EuivinDelveHandler)
end

local function EuivinGetDelveRewards()
    local updated = false

    C_MythicPlus.RequestRewards()

    local rewards = C_WeeklyRewards.GetActivities(6)
    if rewards == nil then
        _G.EuivinDelveCache.rewards = { 0, 0, 0 }
        _G.EuivinDelve.callbacks:Fire("EUIVIN_DELVE_REWARDS")
        return
    end

    for i, r in ipairs(rewards) do
        if r.threshold > r.progress then
            break
        end

        if r.level > 8 then
            if _G.EuivinDelveCache.rewards[i] ~= data.DelveRewards[8] then
                _G.EuivinDelveCache.rewards[i] = data.DelveRewards[8]
                updated = true
            end
        else
            if _G.EuivinDelveCache.rewards[i] ~= data.DelveRewards[r.level] then
                _G.EuivinDelveCache.rewards[i] = data.DelveRewards[r.level]
                updated = true
            end
        end
    end

    local runs = 0
    for _, r in ipairs(_G.EuivinDelveCache.rewards) do
        if r == data.DelveRewards[#data.DelveRewards] then
            runs = runs + 1
        end
    end
    if _G.EuivinDelveCache.runs ~= runs then
        _G.EuivinDelveCache.runs = runs
        updated = true
    end

    if updated or not _G.EuivinDelveCache.init then
        _G.EuivinDelveCache.init = true
        _G.EuivinDelve.callbacks:Fire("EUIVIN_DELVE_REWARDS")
    end
end

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:RegisterEvent("ADDON_LOADED")
hiddenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hiddenFrame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
hiddenFrame:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED")
hiddenFrame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
hiddenFrame:SetScript(
    "OnEvent",
    function(_, event)
        if event == "ADDON_LOADED" then
            EuivinInitDelve()
            return
        end
        -- event == all others...
        EuivinGetDelveRewards()
    end)

-- XXX: Is it better to move these to a separated XML file?
-- TODO: Localize strings
local delveFrame = util.CreateCategoryFrame("구렁", "EuivinDelveFrame", "EuivinMythicFrame")
rewardsFrame = util.ProgressBar(delveFrame, startColor, endColor)
rewardsFrame:Show()
util.ExpandFrame(delveFrame)
