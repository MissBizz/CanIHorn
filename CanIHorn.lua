local addon = {
    name = "CanIHorn",
    version = "0.1.2",
}

local savedVariables

----------------------------------------------------------
--  GLOBALS / GUI  --
----------------------------------------------------------
function addon.OnIndicatorMoveStop()
    savedVariables.left = CanIHornIndicator:GetLeft()
    savedVariables.top = CanIHornIndicator:GetTop()
end

function addon.RestorePosition()
    CanIHornIndicator:ClearAnchors()
    CanIHornIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.left, savedVariables.top)
end

CAN_I_HORN = addon

----------------------------------------------------------
-- Main Functions  --
----------------------------------------------------------
-- (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityId, sourceUnitType)
local function IsHornOn(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)

    if changeType == EFFECT_RESULT_GAINED then
        d(string.format("IsHornOn() effectName: %s, abilityId %s, unitTag %s", effectName, abilityId, unitTag))
        CanIHornIndicatorText:SetText("Warhorn is Active")
        CanIHornIndicatorText:SetColor(1, 0, 0, 1)
        return
    end

    d(string.format("IsHornOn() effectName: %s, abilityId %s, unitTag %s", effectName, abilityId, unitTag))
    CanIHornIndicatorText:SetText("Warhorn not Active")
    CanIHornIndicatorText:SetColor(0, 1, 0, 1)
end

-- This makes sure we only run our IsHornOn function when it has to do with a warhorn ability ID (which we grab from the table above). That way IsHornOn doesn't run for every buff and ability ever
local function RegisterFilterAbilities()
    --------------------------------------------------
    -- Warhorn ID's  --
    ----------------------------------------------------------
    local hornID  = { 38564, 46526, 46528, 46530, 40224, 46532, 46535, 46538, 40221, 46541, 46544, 46547 }

    for i=1, #hornID do
        local eventName = addon.name .. i
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, IsHornOn)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, hornID[i], REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

local function OnPlayerActivated()
    --d("it worked!")
end

----------------------------------------------------------
-- Initialize Function  --
----------------------------------------------------------
--The EVENT_ADD_ON_LOADED event fired, we made it past the check that it is indeed out addon on, so let's run this
local function Initialize()

    --register event to watch for when player loads
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    savedVariables = ZO_SavedVars:New("CanIHornSavedVariables", 1, nil, {})

    addon.RestorePosition()

    RegisterFilterAbilities()
end

local function OnAddOnLoaded(_, addonName)

    -- Checks to see if it's out add on that loaded, if not - return to keep checking whenever any addon loads.
    if addonName ~= addon.name then return end

    -- unregister our EVENT_ADD_ON_LOADED event because now that we know our addon loaded and initliazed... we don't care when any more addons load.
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    --If we got past that, it means our addon loaded. Initliaze will do all the stuff to set out addon up
    Initialize()

end

----------------------------------------------------------
--  Register Events  --
----------------------------------------------------------
--This registers our event, so whenever EVENT_ADD_ON_LOADED fires, it runs our OnAddOnLoaded function
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)