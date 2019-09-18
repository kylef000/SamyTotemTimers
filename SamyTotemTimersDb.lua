SamyTotemTimersDb = {}

if not SaveBindings then
    function SaveBindings(p)
        AttemptToSaveBindings(p)
    end
end

local _db = nil
local _samyTotemTimers = nil

local function EnsureSavedVariablesExists(isReset)
    local function SetDefault(ref, default, isOverride)
        if (ref == nil or isOverride) then
            return default
        end

        return ref
    end

    if (SamyTotemTimersDB and (not SamyTotemTimersDB.version or SamyTotemTimersDB.version < 2)) then
        isReset = true
        SamyTotemTimersUtils:Print("Current version incompatible with old saved variables, reseting all configuration")
    end
        

    SamyTotemTimersDB = SetDefault(SamyTotemTimersDB, {}, isReset)
    SamyTotemTimersDB.lastUsedTotems = SetDefault(SamyTotemTimersDB.lastUsedTotems, {}, isReset)
    SamyTotemTimersDB.scale = SetDefault(SamyTotemTimersDB.scale, 1, isReset)
    SamyTotemTimersDB.position = SetDefault(SamyTotemTimersDB.position, {}, isReset)
    SamyTotemTimersDB.position.hasChanged = SetDefault(SamyTotemTimersDB.position.hasChanged, false, isReset)
    SamyTotemTimersDB.position.x = SetDefault(SamyTotemTimersDB.position.x, 0, isReset)
    SamyTotemTimersDB.position.y = SetDefault(SamyTotemTimersDB.position.y, 0, isReset)
    SamyTotemTimersDB.position.relativePoint = SetDefault(SamyTotemTimersDB.position.relativePoint, "CENTER", isReset)
    SamyTotemTimersDB.totemLists = SetDefault(SamyTotemTimersDB.totemLists, SamyTotemTimersConfig.defaultTotemLists, isReset)
    SamyTotemTimersDB.version = 2

    return SamyTotemTimersDB
end

function SamyTotemTimersDb:OnInitialize(samyTotemTimers)
    _samyTotemTimers = samyTotemTimers
    _db = EnsureSavedVariablesExists()

    local options = {
        name = 'SamyTotemTimersV2', 
        type = "group",
        handler = self,
        args = {
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

            totems = {
                order = 3,
                type = 'group',
                name = 'Totems',
                args = {}
            }
        }
    }

    for k, v in pairs(_db.totemLists) do
        local key = tostring(k)
        options.args.totems.args[key] = {
            order = k,
            type = "group",
            name = v.name,
            args = {
                isEnabled = {
                    order = 1,
                    name = "Enabled",
                    desc = "Enable/Disable totem list",
                    type = "toggle",
                    set = function(info, newValue) SamyTotemTimersDb:SetTotemListEnabled(k, newValue) end,
                    get = function() return SamyTotemTimersDb:GetTotemListEnabled(k) end,
                },
                keybind = {
                    order = 2,
                    type = "keybinding",
                    name = "Keybinding",
                    desc = "Keybinding for " .. v.name,
                    set = function (info, newValue) SamyTotemTimersDb:SetKeybinding(k, newValue) end,
                    get = function () return SamyTotemTimersDb:GetKeybinding(k) end,
                }
            }
        }
    end

    local ACD3 = LibStub("AceConfigDialog-3.0")
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SamyTotemTimers", options, {"stt", "samytotemtimers"})
    local optFrame = ACD3:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")
end

function SamyTotemTimersDb:SelectedSpellChanged(listName, spellName)
    SamyTotemTimersUtils:Debug("Totem changed for " .. listName .. ": " .. tostring(spellName))
    _db.lastUsedTotems[listName] = spellName
end

function SamyTotemTimersDb:PositionChanged()
    local point, relativeTo, relativePoint, x, y = _samyTotemTimers.frame:GetPoint()
    _db.position.x = x
    _db.position.y = y
    _db.position.relativePoint = relativePoint
    _db.position.hasChanged = true
end

function SamyTotemTimersDb:RestoreScaleAndPosition()
    if (_db.position.hasChanged) then
        _samyTotemTimers.frame:SetPoint(_db.position.relativePoint, UIParent, _db.position.x, _db.position.y)
    else
        _samyTotemTimers.frame:SetPoint("CENTER", _samyTotemTimers.frame:GetWidth() / 2.0, 0)
    end

    _samyTotemTimers.frame:SetScale(_db.scale)
end

function SamyTotemTimersDb:GetLastUsedTotem(totemListId)
    return _db.lastUsedTotems[totemListId]
end

function SamyTotemTimersDb:GetTotemLists()
    return _db.totemLists
end

function SamyTotemTimersDb:SetTotemListEnabled(totemListId, isEnabled)
    _db.totemLists[totemListId].isEnabled = isEnabled
    _samyTotemTimers:SetListEnabled(totemListId, isEnabled)
end

function SamyTotemTimersDb:GetTotemListEnabled(totemListId)
    return _db.totemLists[totemListId].isEnabled
end

function SamyTotemTimersDb:GetKeybinding(totemListId)
    local bindingName = format('CLICK %s:%s', SamyTotemTimersConfig:GetCastTotemButtonName(totemListId), GetCurrentBindingSet())
    return GetBindingKey(bindingName)
end

function SamyTotemTimersDb:SetKeybinding(totemListId, newValue)
    local currentBindingInfo = self:GetKeybinding(totemListId)
    if (currentBindingInfo) then
        SetBinding(currentBindingInfo, nil)
    end

    SetBindingClick(newValue, SamyTotemTimersConfig:GetCastTotemButtonName(totemListId), GetCurrentBindingSet())
    SaveBindings(GetCurrentBindingSet())
end

function SamyTotemTimersDb:SetScale(info, newValue)
    _db.scale = newValue
    _samyTotemTimers.frame:SetScale(newValue)
end

function SamyTotemTimersDb:GetScale(info) 
    return _db.scale
end

function SamyTotemTimersDb:ToggleLock()
    _isLocked = not _isLocked
    _samyTotemTimers:SetDraggable(_isLocked)
    if (_isLocked) then
        SamyTotemTimersUtils:Print("Frame locked")
    else
        SamyTotemTimersUtils:Print("Frame unlocked")
    end
end

function SamyTotemTimersDb:ResetConfig()
    EnsureSavedVariablesExists(true)
    ReloadUI()
end