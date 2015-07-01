local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

GwentAddon.DEBUGWINDOW = {}
local DEBUGMESSAGES = {}
local TEXT_ADDONMSG_RECIEVED = "Message Recieved"

local function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end

local function DEBUGPrintCard(card)
	local cardName = AceGUI:Create("Label")
	cardName:SetRelativeWidth(1)
	cardName:SetText("|cFFE6D707"..card.Id .. ": " .. card.name.. (card.subText and " ("..card.subText..")" or "") .."|r")
	DEBUGWINDOW.cardScroller:AddChild(cardName)
	
	local cardStr = AceGUI:Create("Label")
	cardStr:SetRelativeWidth(0.1)
	cardStr:SetText(card.strength)
	DEBUGWINDOW.cardScroller:AddChild(cardStr)
	
	local cardType = AceGUI:Create("Label")
	cardType:SetRelativeWidth(0.3)
	local text = ""
	for cType, isType in pairs(card.cardType) do
		if isType then
			text = text .. cType .. " "
		end
	end
	cardType:SetText(text)
	DEBUGWINDOW.cardScroller:AddChild(cardType)
	
	local cardAbility = AceGUI:Create("Label")
	cardAbility:SetRelativeWidth(0.3)
	cardAbility:SetText(card.ability)
	DEBUGWINDOW.cardScroller:AddChild(cardAbility)
	
	local cardDeck = AceGUI:Create("Label")
	cardDeck:SetRelativeWidth(0.3)
	cardDeck:SetText(card.faction)
	DEBUGWINDOW.cardScroller:AddChild(cardDeck)
end

function GwentAddon:DEBUGToggleFrame()
			if DEBUGWINDOW == nil then
			return
		end
		
		
		if DEBUGWINDOW:IsShown() then
			DEBUGWINDOW.frame:Hide()
		else 
			DEBUGWINDOW.frame:Show()
		end

end


local function DEBUGAddMessage(message, sender)

	if sender ~= nil then
		message = "|cFFE6D707"..sender .. "|r\n> "..message
	end

	local messageText = AceGUI:Create("Label")
	messageText:SetRelativeWidth(1)
	messageText:SetText(message)
	DEBUGWINDOW.mainScroller:AddChild(messageText)

end



local function DEBUGPrintMessages()
	if DEBUGWINDOW.mainScroller == nil then return end
	
	DEBUGWINDOW.mainScroller:ReleaseChildren()
	
	for i = #DEBUGMESSAGES, 1, -1 do
		local v = DEBUGMESSAGES[i]
		DEBUGAddMessage(v.message, v.sender)
	end
	
	--for k , v in ipairs(DEBUGMESSAGES) do
	--		DEBUGAddMessage(v.message, v.sender)
	--end

end

function GwentAddon:DEBUGMessageSent(message, target)
	table.insert(DEBUGMESSAGES, {["sender"] = target, ["message"] = message})
	DEBUGPrintMessages()
	--DEBUGAddMessage(message, message)
end

local function DEBUGShowMessageContainer(container)
	container:SetLayout("Fill")
	DEBUGWINDOW.mainScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.mainScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.mainScroller)
	
	DEBUGPrintMessages()
end

local function DEBUGShowCards(container)
	--print("Showing "..#GwentAddon.CardList.." cards")
	container:SetLayout("Fill")
	DEBUGWINDOW.cardScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.cardScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.cardScroller)
	for k , v in ipairs(GwentAddon.cards.list) do

			DEBUGPrintCard(v)
	end
end

local function DEBUGSelectTab(container, event, group)
   container:ReleaseChildren()
   if group == "messages" then
		DEBUGShowMessageContainer(container)
   elseif group == "cards" then
		DEBUGShowCards(container)
   end
end

local function debug_updatext()
		local text = ""

		text = text .. "state: \n  " .. GwentAddon:GetStateName(GwentAddon.currentState).." ("..GwentAddon.currentState .. ")" .."\n"
		text = text .. "player passed: \n  " .. (GwentAddon.playerPassed and "true" or "false") .."\n"
		text = text .. "enemy passed: \n  " .. (GwentAddon.enemyPassed and "true" or "false") .."\n"
		text = text .. "player lives: " .. GwentAddon.playerLives.count .."\n"
		text = text .. "enemy lives: " .. GwentAddon.enemyLives.count .."\n"
		text = text .. "# mouseover list: \n  " .. (GwentAddon.draggingOver.list == nil and "none" or #GwentAddon.draggingOver.list) .."\n"
		text = text .. "mouse over card: " .. (GwentAddon.draggingOver.card == nil and "" or GwentAddon.draggingOver.card.nr).."\n  " .. (GwentAddon.draggingOver.card == nil and "none" or  round(GwentAddon.draggingOver.card.leftSpacing, 2) .. " - " .. round(GwentAddon.draggingOver.card.rightSpacing, 2)) .."\n"
		
		GwentDEBUGVariables.text:SetText(text)
	end

local function CreateDebug()
 
	DEBUGWINDOW = AceGUI:Create("Frame")
	DEBUGWINDOW:SetTitle("Gwent Debug")
	DEBUGWINDOW:SetLayout("Fill")
	DEBUGWINDOW:SetWidth(400)
	--DEBUGWINDOW.frame:Hide()

	DEBUGWINDOW.tabs = AceGUI:Create("TabGroup");
	DEBUGWINDOW.tabs:SetLayout("Flow")
	DEBUGWINDOW.tabs:SetTabs({{text = "Messages", value="messages"}, {text = "CardList", value="cards"}})
	DEBUGWINDOW.tabs:SetCallback("OnGroupSelected", DEBUGSelectTab)
	DEBUGWINDOW.tabs:SelectTab("messages")
	DEBUGWINDOW:AddChild(DEBUGWINDOW.tabs)
	
	local _updateTimer = 0

	local L_GwentDEBUGVariables = CreateFrame("frame", "GwentDEBUGVariables", DEBUGWINDOW.frame)

	GwentDEBUGVariables:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = nil,
		tileSize = 0, edgeSize = 16,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})

	GwentDEBUGVariables:SetFrameLevel(5)
	GwentDEBUGVariables:SetPoint("topleft", DEBUGWINDOW.frame, "topright", -3, -10)
	GwentDEBUGVariables:SetPoint("bottomleft", DEBUGWINDOW.frame, "bottomright", -3, 10)GwentDEBUGVariables:SetPoint("Center", 250, 0)
	GwentDEBUGVariables.text = GwentDEBUGVariables:CreateFontString(nil, nil, "GameFontNormal")
	GwentDEBUGVariables.text:SetPoint("topleft", 10, -10)
	GwentDEBUGVariables.text:SetText("blqh")
	GwentDEBUGVariables.text:SetJustifyH("left")
	GwentDEBUGVariables:SetWidth(175)
	GwentDEBUGVariables:SetScript("OnUpdate", function(self,elapsed) 
		_updateTimer = _updateTimer + elapsed
		if _updateTimer >= 0.5 then
			debug_updatext()
			_updateTimer = 0
		end
		end)
	GwentDEBUGVariables:Show()
	
	
	--DEBUGWINDOW:AddChild(DEBUGWINDOW.mainScroller)

end

local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_DEBUGEventFrame"); 
Gwent_DEBUGEventFrame:RegisterEvent("ADDON_LOADED");
Gwent_DEBUGEventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_DEBUGEventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_DEBUGEventFrame:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= addonName then
		return
	end
	
	if message == TEXT_ADDONMSG_RECIEVED then
		--DEBUGMessageSuccess(sender)
		return
	end
	
	--print("message "..txt.." from ".. s.. " through "..channel)
	
	table.insert(DEBUGMESSAGES, {["sender"] = sender, ["message"] = message})

	DEBUGPrintMessages()
	
	-- Send Success Message
	--SendAddonMessage(addonName, TEXT_ADDONMSG_RECIEVED , "whisper" , s)

	
end

function Gwent_DEBUGEventFrame:ADDON_LOADED(ADDON_LOADED)
	if ADDON_LOADED ~= addonName then return end
	CreateDebug()
end




-- Debug help
--------------------------------------------

