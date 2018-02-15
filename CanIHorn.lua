CanIHorn = {}

----------------------------------------------------------
--  Initialize Variables  --
----------------------------------------------------------
CanIHorn.name = "CanIHorn"
CanIHorn.version = "0.1.1"

----------------------------------------------------------
-- Graphic Stuff  --
----------------------------------------------------------
function CanIHorn.OnIndicatorMoveStop()
    CanIHorn.savedVariables.left = CanIHornIndicator:GetLeft()
    CanIHorn.savedVariables.top = CanIHornIndicator:GetTop()
end

function CanIHorn:RestorePosition()
    local left = self.savedVariables.left
    local top = self.savedVariables.top

    CanIHornIndicator:ClearAnchors()
    CanIHornIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
----------------------------------------------------------
--  OnAddOnLoaded  --
----------------------------------------------------------
--Whenever our registered event EVENT_ADD_ON_LOADED fire, this runs
local function OnAddOnLoaded(event, addonName)

    -- Checks to see if it's out add on that loaded, if not - return to keep checking whenever any addon loads.
    if addonName ~= CanIHorn.name then return end

    --If we got past that, it means our addon loaded. Initliaze will do all the stuff to set out addon up
    CanIHorn:Initialize()

end

----------------------------------------------------------
-- Main Functions  --
----------------------------------------------------------
local function IsHornOn(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityId, sourceUnitType)

    if changeType == EFFECT_RESULT_GAINED then
        d("YAY Warhorn ID is", effectName, abilityId, unitTag)
        CanIHornIndicatorText:SetText("Warhorn is Active")
        CanIHornIndicatorText:SetColor(1, 0, 0, 1)
    end
    if changeType == EFFECT_RESULT_FADED then
        d("warhorn expired", effectName, abilityId, unitTag)
        CanIHornIndicatorText:SetText("Warhorn not Active")
        CanIHornIndicatorText:SetColor(0, 1, 0, 1)
    end
end

-- This makes sure we only run our IsHornOn function when it has to do with a warhorn ability ID (which we grab from the table above). That way IsHornOn doesn't run for every buff and ability ever
function CanIHorn:RegisterFilterAbilities()
	--------------------------------------------------
	-- Warhorn ID's  --
	----------------------------------------------------------
	local hornID  = { 38564, 46526, 46528, 46530, 40224, 46532, 46535, 46538, 40221, 46541, 46544, 46547 }

    for i=1, #hornID do
        local eventName = self.name .. i
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, IsHornOn)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, hornID[i], REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

function PlayerInWorld()
    d("it worked!")
end
----------------------------------------------------------
-- Initialize Function  --
----------------------------------------------------------
--The EVENT_ADD_ON_LOADED event fired, we made it past the check that it is indeed out addon on, so let's run this
function CanIHorn:Initialize()

    --register event to watch for when player loads
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, PlayerInWorld)

    self.savedVariables = ZO_SavedVars:New("CanIHornSavedVariables", 1, nil, {})

    self:RestorePosition()

    -- unregister our EVENT_ADD_ON_LOADED event because now that we know our addon loaded and initliazed... we don't care when any more addons load.
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

	self:RegisterFilterAbilities()
end


--------




----------------------------------------------------------
--  Register Events  --
----------------------------------------------------------
--This registers our event, so whenever EVENT_ADD_ON_LOADED fires, it runs our OnAddOnLoaded function
EVENT_MANAGER:RegisterForEvent(CanIHorn.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)