local opt = PIBuddyConfig

-- toggles for logging
local ENABLE_OUTPUT=true
local ENABLE_DIAG=false
local ENABLE_DUMPING=false

-- LOGGING
function pbPrintf(...)
 if (not ENABLE_OUTPUT) then return end
 local status, res = pcall(format, ...)
 if status then
    if DLAPI then 
		DLAPI.DebugLog("KUI TargetHelper", res) 
	else
		print(res)
	end
  end
end

-- DIAG
function pbDiagf(...)
	if (not ENABLE_DIAG) then return end
	local status, res = pcall(format, ...)
	if status then
	   if DLAPI then 
		   DLAPI.DebugLog("KUI TargetHelper", res) 
	   else
		   print(res)
	   end
	 end
   end

-- DUMP
function pbDump(data)
 if (not ENABLE_DUMPING) then return end
 DevTools_Dump(data)
end

function opt:pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
	i = i + 1
	if a[i] == nil then return nil
	else return a[i], t[a[i]]
	end
  end
  return iter
end

-- Panels

function opt:CreatePanel(parent, name, width, height)
	local panel = CreateFrame("Frame", name, parent)
	panel:SetSize(width, height)
	
	local bg = CreateFrame('Frame', nil, panel, "BackdropTemplate")
	bg:SetBackdrop({
        bgFile = 'interface/buttons/white8x8',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	
	bg:SetBackdropColor(.1,.1,.1,.3)
	bg:SetBackdropBorderColor(1, 1, 1)
	bg:SetPoint('TOPLEFT', panel, -10, 10)
	bg:SetPoint('BOTTOMRIGHT', panel, 30, -10)
	bg:SetFrameStrata("MEDIUM")
	bg:SetFrameLevel(0)
	
	return panel
end

-- Tooltips

function opt:OnTooltipEnter(self)
	
	if not self.tooltipText then
		return
	end
	
	GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
	
	if self.tooltipTitle then
		GameTooltip:AddLine(self.tooltipTitle)
	end
	
	GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
	
	if self.tooltipText2 then
		GameTooltip:AddLine(self.tooltipText2, 1, 1, 1, true)
	end
	
	GameTooltip:Show()
end

function opt:OnTooltipLeave(self)
	if not self.tooltipText then
		return
	end
	
    GameTooltip:Hide()
end

function opt:AddTooltip2(frame, title, text, text2)
	frame:EnableMouse(true)
	frame.tooltipTitle = title
	frame.tooltipText = text
	frame.tooltipText2 = text2
	frame:SetScript('OnEnter',function(self)
			opt:OnTooltipEnter(self)
		end)
    frame:SetScript('OnLeave',function(self)
			opt:OnTooltipLeave(self)
		end)
		
	if (frame.label) then
		opt:AddTooltip2(frame.label, title, text, text2)
	end
end

function opt:AddTooltip(frame, title, text)
	opt:AddTooltip2(frame, title, text, nil)
end

function opt:ReplaceTooltip(frame, title, text)
	frame.tooltipTitle = title
	frame.tooltipText = text
end

-- Checkbox

function opt:CheckBoxOnClick(self)
	opt.env[self:GetName()] = self:GetChecked()
		
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) 
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

function opt:CreateCheckBox(parent, name)
	local check = CreateFrame('CheckButton', name, parent, 'OptionsBaseCheckButtonTemplate')
	check:Raise()
	
	check.label = check:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	check.label:SetText(opt.titles[name] or name or '!MissingTitle')
	check.label:SetPoint('LEFT', check, 'RIGHT', 4, 0)
	check.label.check = check
	check:SetChecked(opt.env[name])

	check.label:SetScript('OnMouseDown', function(self, button, ...)
		if (button == 'LeftButton' and self.check:IsEnabled()) then
			self.check:Click()
		end
	end)
	
	return check
end

-- Slider

function opt:OnSliderValueChanged(self, value)
	local strval = string.format("%.2f", value)
	opt.env[self:GetName()] = value
	self.label:SetText(strval)
end

function opt:CreateSlider(parent, name, minval, maxval, stepvalue, width)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
	slider:SetMinMaxValues(minval, maxval)
	slider:SetWidth(width)
	slider:SetHeight(16)
	slider:SetValueStep(stepvalue)
	slider:SetObeyStepOnDrag(true)
	slider.title = opt.titles[name]
	
	getglobal(name .. 'Low'):SetText(tostring(minval)); --Sets the left-side slider text (default is "Low").
	getglobal(name .. 'High'):SetText(tostring(maxval)); --Sets the right-side slider text (default is "High").
	getglobal(name .. 'Text'):SetText(opt.titles[name] or name or '!MissingTitle'); --Sets the "title" text (top-centre of slider).
 
 	slider:SetValue(opt.env[name])
	
	local strval = string.format("%.2f", opt.env[name])
	slider.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	slider.label:SetText(strval)
	slider.label:SetPoint('BOTTOM', slider, 0, -10)
	return slider;
end

-- Edit Box

function opt:CreateEditBox(parent, name, maxLetters, width, height)
	local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	box:SetAutoFocus(false)
	box:ClearFocus()
	box:SetAutoFocus(false)
	box:EnableMouse(true)
	box:SetMultiLine(false)
	box:SetMaxLetters(maxLetters)
	box:SetSize(width, height)
	return box
end

-- Is Player a Party Member

function opt:IsPartyMember(n)

	n = strlower(n)

	if (IsInRaid()) then
		for i = 1, MAX_RAID_MEMBERS do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
			if (name) then
				name = strlower(name)
				local unitId = "raid" .. i
				if (name == n) then
					return true
				end
			end
		end
	elseif (IsInGroup()) then
		for i = 1, 4 do
			local unitId = "party" .. i
			local name = UnitName(unitId)
			if (name) then
				if (strlower(name) == n) then
					return true
				end
			end
		end
	end

	return false

end

-- Talents

local LibTalentTree = nil
function opt:GetTalentNodeForSpell(spell_id)
	if (LibTalentTree == nil) then
		LibTalentTree = LibStub("LibTalentTree-1.0")
	end	

	if (LibTalentTree) then		
		local treeId = LibTalentTree:GetClassTreeId('PRIEST');
		local nodes = C_Traits.GetTreeNodes(treeId);
		local configId = C_ClassTalents.GetActiveConfigID();
		for _, nodeId in ipairs(nodes) do
			local nodeInfo = LibTalentTree:GetLibNodeInfo(treeId, nodeId);
			local entryInfo = C_Traits.GetEntryInfo(configId, nodeInfo.entryIDs[1]);

			local definitionId = entryInfo.definitionID
			local def = C_Traits.GetDefinitionInfo(definitionId)
			if (def.spellID == spell_id) then
				return nodeId
			end
		end

	end
end

function opt:HasTalentNode(nodeId)
	local configId = C_ClassTalents.GetActiveConfigID();
	if (configId) then
		local nodeInfo = C_Traits.GetNodeInfo(configId, nodeId)
		if (nodeInfo) then
			return (nodeInfo.ranksPurchased > 0)
		end
	end

	return false
end