local SamyTotemTimerButtonWrapper = {}
local _config = SamyTotemTimersConfig:Instance()

function SamyTotemTimerButtonWrapper:New(buttonFrame)
    local _instance = {}

    _instance.buttonFrame = buttonFrame
    _instance.mouseUpRightButton = nil
    _instance.mouseUpLeftButton = nil
    _instance.buttonFrame:SetScript("OnMouseUp", function(self, buttonPressed) 
        if (buttonPressed == "LeftButton" and _instance.mouseUpLeftButton) then
            _instance.mouseUpLeftButton(self)
        elseif (buttonPressed == "RightButton" and _instance.mouseUpRightButton) then
            _instance.mouseUpRightButton(self)
        end
    end)

    function _instance:UpdateCooldown()
        if (_instance.spell and _instance.buttonFrame.cooldown) then
            CooldownFrame_Set(_instance.buttonFrame.cooldown,  GetSpellCooldown(_instance.spell))
        end
    end

    return _instance
end

SamyTotemTimerTotemButton = {}
function SamyTotemTimerTotemButton:Create(parentFrame, buttonSize, realtiveX, buttonName)
    local button = CreateFrame("Button", parentFrame:GetName() .. buttonName, parentFrame, "ActionButtonTemplate, SecureActionButtonTemplate")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    button:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", realtiveX, 0);
    button:SetScript("OnDragStart", function (self)
        self:GetParent():SetMovable(true)
        self:GetParent():StartMoving()
    end)

    button:SetScript("OnDragStop", function (self) 
        self:GetParent():StopMovingOrSizing()
        self:GetParent():SetMovable(false)
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()

        local db = SamyTotemTimersConfig:Instance().db
        db.position.x = xOfs
        db.position.y = yOfs
        db.position.relativePoint = relativePoint
    end)

    button:SetScript("OnAttributeChanged",function(self, attribType, attribDetail)
        if attribType=="spell" then
            local spellId = (select(3,GetSpellInfo(attribDetail)))
            self.icon:SetTexture(spellId)
        end
    end)

    local buttonWrapper = SamyTotemTimerButtonWrapper:New(button)
    function buttonWrapper:SetSpell(spell, isSave) 
        button:SetAttribute("type", "spell");
        button:SetAttribute("spell", spell);

        buttonWrapper.spell = spell
        if (isSave) then
            _config.db.lastUsedSpells[button:GetName()] = spell
        end
    end

    function buttonWrapper:UpdateSpellUsable()
        if (buttonWrapper.spell) then 
            local isUsable, noMana = IsUsableSpell(buttonWrapper.spell)
            if (not isUsable or noMana) then
               button:SetAlpha(0.4)
            else
                button:SetAlpha(1)
            end
        end
    end

    function buttonWrapper:SetDraggable(isDraggable)
        if (isDraggable) then
            button:RegisterForDrag('LeftButton')
            ActionButton_ShowOverlayGlow(button)
        else
            button:RegisterForDrag(nil)
            ActionButton_HideOverlayGlow(button)
        end
    end

    return buttonWrapper
end

SamyTotemTimerSelectTotemButton = {}
function SamyTotemTimerSelectTotemButton:Create(samyTotemTimerTotemButton, buttonSize, spell)
    local parentFrame = samyTotemTimerTotemButton.buttonFrame
    local button = CreateFrame("Button", parentFrame:GetName() .. spell, parentFrame, "ActionButtonTemplate, SecureActionButtonTemplate")
    button:SetFrameStrata("TOOLTIP")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)

    RegisterStateDriver(button, 'visibility', '[combat]hide')

    local buttonWrapper = SamyTotemTimerButtonWrapper:New(button)
    buttonWrapper.spell = spell

    function buttonWrapper:ADDON_LOADED()
        local spellId = select(3, GetSpellInfo(spell))
        button.icon:SetTexture(spellId)
    end

    return buttonWrapper
end

SamyTotemTimerActiveTotemButton = {}
function SamyTotemTimerActiveTotemButton:Create(samyTotemTimerTotemButton, buttonSize, buttonName)
    local parentFrame = samyTotemTimerTotemButton.buttonFrame
    local name = parentFrame:GetName() .. buttonName .. "Active"
    local button = CreateFrame("Frame", name, parentFrame, "ActionButtonTemplate", "Background")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    
    local tY = buttonSize * _config.buttonSpacingMultiplier
    button:SetPoint("BOTTOMLEFT", parentFrame, "TOPLEFT", 0, tY);
    button:Hide()

    local buttonWrapper = SamyTotemTimerButtonWrapper:New(button)

    local lastActiveTotem = nil
    function buttonWrapper:Update(totemIndex)
        local function setTimerText()
            local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndex)
            local timeLeft = duration + startTime - GetTime()

            CooldownFrame_Set(button.cooldown, startTime, duration, haveTotem, true)

            if (haveTotem and timeLeft > 0) then
                if (lastActiveTotem ~= totemName) then
                    button.icon:SetTexture(icon)
                    lastActiveTotem = totemName
                end

                local d, h, m, s = ChatFrame_TimeBreakDown(timeLeft)
                button.Count:SetFormattedText("%01d:%02d", m, s)
                
                if (not button:IsVisible()) then
                    button:Show()
                end

                C_Timer.NewTimer(0.2, function() setTimerText() end)
            else
                button:Hide()
            end
        end

        setTimerText()
    end

    return buttonWrapper
end
