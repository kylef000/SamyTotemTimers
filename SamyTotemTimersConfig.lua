SamyTotemTimersConfig = LibStub("AceAddon-3.0"):NewAddon("SamyTotemTimers", "AceConfigDialog-3.0", "AceConfig-3.0", "AceEvent-3.0")

SamyTotemTimersConfig.buttonSize = 36
SamyTotemTimersConfig.buttonSpacingMultiplier = 0.15
SamyTotemTimersConfig.totems = { 
    ["EarthIndex"] = 2,
    ["Earth"] = {
        8071, --"Stoneskin Totem",
        2484, --"Earthbind Totem",
        5730, --"Stoneclaw Totem",
        8075, --"Strength of Earth Totem",
        8143, --"Tremor Totem"
    }, 

    ["FireIndex"] = 1,
    ["Fire"] = {
        3599, --"Searing Totem",
        1535, --"Fire Nova Totem",
        8181, --"Frost Resistance Totem",
        8190, --"Magma Totem",
        8227, --"Flametongue Totem"
    },

    ["WaterIndex"] = 3,
    ["Water"] = {
        5394, --"Healing Stream Totem",
        5675, --"Mana Spring Totem",
        8184, --"Fire Resistance Totem",
        16190, --"Mana Tide Totem",
        8170, --"Disease Cleansing Totem",
        8166, --"Poison Cleansing Totem",
    },

    ["AirIndex"] = 4,
    ["Air"] = {
        8835, --"Grace of Air Totem",
        10595, --"Nature Resistance Totem",
        15107, --"Windwall Totem",
        8512, --"Windfury Totem",
        8177, --"Grounding Totem",
        6495, --"Sentry Totem",
        25908, --"Tranquil Air Totem"
    },

    ["TwistIndex"] = 5,
    ["Twist"] = {
        8071, --"Stoneskin Totem",
        2484, --"Earthbind Totem",
        5730, --"Stoneclaw Totem",
        8075, --"Strength of Earth Totem",
        8143, --"Tremor Totem"
        3599, --"Searing Totem",
        1535, --"Fire Nova Totem",
        8181, --"Frost Resistance Totem",
        8190, --"Magma Totem",
        8227, --"Flametongue Totem"
        5394, --"Healing Stream Totem",
        5675, --"Mana Spring Totem",
        8184, --"Fire Resistance Totem",
        16190, --"Mana Tide Totem",
        8170, --"Disease Cleansing Totem",
        8166, --"Poison Cleansing Totem",
        8835, --"Grace of Air Totem",
        10595, --"Nature Resistance Totem",
        15107, --"Windwall Totem",
        8512, --"Windfury Totem",
        8177, --"Grounding Totem",
        6495, --"Sentry Totem",
        25908, --"Tranquil Air Totem"
    }
}

function SamyTotemTimersConfig:Initialize()
    local options = {
        name = 'SamyTotemTimers',
        type = 'group',
        handler = _instance,
        args = {
            twist = {
                order = 11,
                type = 'toggle',
                name = "Show twist totem",
                set = 'SetTwist',
                get = 'GetTwist'
            },

            reset = {
                order = 10,
                type = 'execute',
                name = "Reset",
                func = 'ResetConfig'
            },

            scale = {
                order = 1,
                type = 'range',
                name = "Scale",
                min = 0.1,
                max = 5.0,
                step = 0.05,
                bigStep = 0.1,
                set = 'SetScale',
                get = 'GetScale'
            },

            lock = {
                order = 2,
                type = 'execute',
                name = "Lock/Unlock",
                func = 'ToggleLock',
            },

            keybinds = {
                order = 3,
                type = 'group',
                name = 'Keybindings',
                args = {
                    earth = {
                        order = 1,
                        type = 'keybinding',
                        name = 'Earth',
                        desc = 'Keybinding for earth totem',
                        set = 'SetKeybinding',
                        get = 'GetKeybinding',
                    },
    
                    fire = {
                        order = 2,
                        type = 'keybinding',
                        name = 'Fire',
                        desc = 'Keybinding for fire totem',
                        set = 'SetKeybinding',
                        get = 'GetKeybinding',
                    },
    
                    water = {
                        order = 3,
                        type = 'keybinding',
                        name = 'Water',
                        desc = 'Keybinding for water totem',
                        set = 'SetKeybinding',
                        get = 'GetKeybinding',
                    },
    
                    air = {
                        order = 4,
                        type = 'keybinding',
                        name = 'Air',
                        desc = 'Keybinding for air totem',
                        set = 'SetKeybinding',
                        get = 'GetKeybinding',
                    },

                    twist = {
                        order = 5,
                        type = 'keybinding',
                        name = 'Twist',
                        desc = 'Keybinding for twist totem',
                        set = 'SetKeybinding',
                        get = 'GetKeybinding',
                    },
                }
                
            }
        },
    }

    self:RegisterOptionsTable("SamyTotemTimers", options, {"stt", "samytotemtimers"})
    local optFrame = self:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")
end

function SamyTotemTimersConfig:OnEnable()
    self:CheckDatabase()
end

local function SetDefault(ref, default, isOverride)
    if (ref == nil or isOverride) then
        return default
    end

    return ref
end

function SamyTotemTimersConfig:CheckDatabase(isOverride)
    SamyTotemTimersDB = SetDefault(SamyTotemTimersDB, {}, isOverride)
    SamyTotemTimersDB.isFirstLoad  = SetDefault(SamyTotemTimersDB.isFirstLoad, true, isOverride)
    SamyTotemTimersDB.scale = SetDefault(SamyTotemTimersDB.scale, 1, isOverride)
    SamyTotemTimersDB.lastUsedSpells = SetDefault(SamyTotemTimersDB.lastUsedSpells, {}, isOverride)
    SamyTotemTimersDB.position = SetDefault(SamyTotemTimersDB.position, {}, isOverride)
    SamyTotemTimersDB.position.x = SetDefault(SamyTotemTimersDB.position.x, 0, isOverride)
    SamyTotemTimersDB.position.y = SetDefault(SamyTotemTimersDB.position.y, 0, isOverride)
    SamyTotemTimersDB.position.relativePoint = SetDefault(SamyTotemTimersDB.position.relativePoint, "CENTER", isOverride)
    SamyTotemTimersDB.isTwist = SetDefault(SamyTotemTimersDB.isTwist, false, isOverride)

    self.db = SamyTotemTimersDB
end

function SamyTotemTimersConfig:GetTwist(info)
    return self.db.isTwist
end

function SamyTotemTimersConfig:SetTwist(into, value)
    self.db.isTwist = value
    self:SendMessage(IS_TWIST_CHANGED_MESSAGE, value)

    -- if (_totemLists["Twist"]) then
    --     _totemLists["Twist"]:UpdateVisibility(value)
    -- end
end

function SamyTotemTimersConfig:GetKeybinding(info)
        --TODO Change to new totemlist
    local bindingName = format('CLICK %s:%s', _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
    return GetBindingKey(bindingName)
end
    
function SamyTotemTimersConfig:SetKeybinding(info, newValue)
    local currentBindingInfo = _instance:GetKeybinding(info)
    if (currentBindingInfo) then
        SetBinding(currentBindingInfo, nil)
    end
    
    --TODO Change to new totemlist
    SetBindingClick(newValue, _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
    SaveBindings(GetCurrentBindingSet())
end

function SamyTotemTimersConfig:SetScale(info, newValue)
    self.db.scale = newValue
    self:SendMessage(SCALE_CHANGED_MESSAGE, newValue)

    -- _mainFrame:SetScale(newValue)
end

function SamyTotemTimersConfig:GetScale(info) 
    if (not self.db.scale) then
        self.db.scale = 1
    end

    return self.db.scale
end

function SamyTotemTimersConfig:ToggleLock()
    _isLocked = not _isLocked
    if (_isLocked) then
        print('Frame locked')
    else
        print('Frame unlocked')
    end

    self:SendMessage(IS_LOCKED_CHANGED_MESSAGE, _isLocked)
    
    -- for k, v in pairs(_totemLists) do
    --     v:SetDraggable(_isLocked)
    -- end

end

function SamyTotemTimersConfig:ResetConfig()
    self:CheckDatabase(true)

    self:SendMessage(CONFIG_RESET_MESSAGE)
    --_samyTotemTimers:LoadSavedVariables(_mainFrame, _totemLists)
end
