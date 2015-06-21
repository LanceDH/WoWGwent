local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

GwentAddon.DEBUGWINDOW = {}
local DEBUGMESSAGES = {}
local TEXT_ADDONMSG_RECIEVED = "Message Recieved"

function DEBUGPrintCard(card)
	local cardName = AceGUI:Create("Label")
	cardName:SetRelativeWidth(1)
	cardName:SetText("|cFFE6D707"..card.Id .. ": " .. card.name.. "|r")
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
	cardDeck:SetText(card.deck)
	DEBUGWINDOW.cardScroller:AddChild(cardDeck)
end

function DEBUGToggleFrame()
			if DEBUGWINDOW == nil then
			return
		end
		
		
		if DEBUGWINDOW:IsShown() then
			DEBUGWINDOW.frame:Hide()
		else 
			DEBUGWINDOW.frame:Show()
		end

end

function DEBUGAddMessage(message, sender)

	local messageSender = AceGUI:Create("Label")
	messageSender:SetRelativeWidth(1)
	messageSender:SetText("|cFFE6D707Message from "..sender .. "|r")
	DEBUGWINDOW.mainScroller:AddChild(messageSender)
	
	local messageText = AceGUI:Create("Label")
	messageText:SetRelativeWidth(1)
	messageText:SetText("> "..message)
	DEBUGWINDOW.mainScroller:AddChild(messageText)

end

function DEBUGMessageSuccess(sender)
	
end

function DEBUGPrintMessages()
	if DEBUGWINDOW.mainScroller == nil then return end
	
	DEBUGWINDOW.mainScroller:ReleaseChildren()

	for k , v in ipairs(DEBUGMESSAGES) do
			DEBUGAddMessage(v.message, v.sender)
	end

end

function DEBUGShowMessageContainer(container)
	container:SetLayout("Fill")
	DEBUGWINDOW.mainScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.mainScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.mainScroller)
	
	DEBUGPrintMessages()
end

function DEBUGShowCards(container)
	--print("Showing "..#GwentAddon.CardList.." cards")
	container:SetLayout("Fill")
	DEBUGWINDOW.cardScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.cardScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.cardScroller)
	for k , v in ipairs(GwentAddon.CardList) do

			DEBUGPrintCard(v)
	end
end

function DEBUGSelectTab(container, event, group)
   container:ReleaseChildren()
   if group == "messages" then
     DEBUGShowMessageContainer(container)
   elseif group == "cards" then
     DEBUGShowCards(container)
   end
end

function CreateDebug()
 
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
	
	
	
	--DEBUGWINDOW:AddChild(DEBUGWINDOW.mainScroller)

end

local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_DEBUGEventFrame"); 
Gwent_DEBUGEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
Gwent_DEBUGEventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_DEBUGEventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_DEBUGEventFrame:CHAT_MSG_ADDON(prefix, m, channel, s)
	if prefix ~= addonName then
		return
	end
	
	if message == TEXT_ADDONMSG_RECIEVED then
		--DEBUGMessageSuccess(sender)
		return
	end
	
	table.insert(DEBUGMESSAGES, {sender = s, message = m})

	DEBUGPrintMessages()
	
	-- Send Success Message
	--SendAddonMessage(addonName, TEXT_ADDONMSG_RECIEVED , "whisper" , s)

	
end

function Gwent_DEBUGEventFrame:PLAYER_ENTERING_WORLD(loadedAddon)
	CreateDebug()
end