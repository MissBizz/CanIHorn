local addon = {
    name = "CanIHorn",
    version = "0.2.1",
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
-- Major Force Functions  --
----------------------------------------------------------

--this sets horn to false, so that if a horn hasn't sounded - major force will be ignored.
local WarhornActive = false

local function WatchForce(_, changeType, _, effectName, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    --if Warhorn hasn't sounded yet, WarhornActive will be false and therefore nothing will happen, lua assumes you mean you want the variable true
    if WarhornActive then

        --d(string.format("Passed warhorn true check"))

        if changeType == EFFECT_RESULT_FADED then
            CanIHornIndicatorText:SetColor(1, 1, 0, 1)
            --this changed the text colour to yellow when major force fades
            WarhornActive = false
            --sets warhornActive back to false so other major forces don't change the colour
        end
   end
end

----------------------------------------------------------
-- Main Horn Functions  --
----------------------------------------------------------

-- (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityId, sourceUnitType)
--This is our main function to change text when a warhorn fires or fades.
local function IsHornOn(_, changeType, _, effectName, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)

    if changeType == EFFECT_RESULT_GAINED then
        --d(string.format("IsHornOn() gained effectName: %s, abilityId %s, unitTag %s", effectName, abilityId, unitTag))
        CanIHornIndicatorText:SetText("Warhorn is Active")
        CanIHornIndicatorText:SetColor(1, 0, 0, 1)
            --checks only for aggressive horn, as that is the only time we care about major force
            if abilityId == 40224 then
                WarhornActive = true
        --d(string.format("WarhornActive set to true"))
                --sets WarhornActive to true to it will pass the check in the WatchForce function
            end
        return
    end

    --d(string.format("IsHornOn() effectName: %s, abilityId %s, unitTag %s", effectName, abilityId, unitTag))
    CanIHornIndicatorText:SetText("Warhorn not Active")
    CanIHornIndicatorText:SetColor(0, 1, 0, 1)

    --d(string.format("IsHornOn() other effectName %s, abilityId %s, unitTag %s, changeType $s", effectName, abilityId, unitTag, changeType))
end
--------------------------------------------------
-- Warhorn ID's  --
----------------------------------------------------------
local hornID  = { [38564] = true, [40224] = true, [40221] = true }
--38564 is warhorn, 40224 aggressive, 40221 sturdy

--------------------------------------------------
-- Ability Event Registrations  --
----------------------------------------------------------
-- This makes sure we only run our IsHornOn function when it has to do with a warhorn ability ID (which we grab from the table above). That way IsHornOn doesn't run for every buff and ability ever
local function RegisterFilterAbilities()
    local eventCounter = 0
    for abilityId,_ in pairs(hornID) do
        eventCounter = eventCounter + 1
        local eventName = addon.name .. eventCounter
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, IsHornOn)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

--registers the Major Force buff specifically
local function RegisterForce()
    EVENT_MANAGER:RegisterForEvent(forceevent, EVENT_EFFECT_CHANGED, WatchForce)
    EVENT_MANAGER:AddFilterForEvent(forceevent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 40225, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

--------------------------------------------------
-- Initial Horn Check  --
----------------------------------------------------------

--intial check for horn upon login
local function CheckForHorn()
    local isActiveHorn = false

    for i=1,GetNumBuffs("player") do
        local abilityId = select(11, GetUnitBuffInfo("player", i))
            if hornID[abilityID] then
                isActiveHorn = true
                    break
            end
    end
    if isActiveHorn then
        CanIHornIndicatorText:SetText("Warhorn is Active")
        CanIHornIndicatorText:SetColor(1, 0, 0, 1)
        --d(string.format("CheckForHorn() It is it buffName: %s, abilityId %s, buffSlot %s", buffName, abilityID, buffSlot))
    else
        CanIHornIndicatorText:SetText("Warhorn not Active")
        CanIHornIndicatorText:SetColor(0, 1, 0, 1)
    end
end

--waits until the player is activated to check for horn
local function OnPlayerActivated()
    --d("it worked!")
    CheckForHorn()

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
    RegisterForce()


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