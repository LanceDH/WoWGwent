local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

local DEBUGWINDOW = {}
local DEBUGMESSAGES = {}
local TEXT_ADDONMSG_RECIEVED = "Message Recieved"


local function isInteger(x)
	return math.floor(x)==x
end


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

local function DEBUGAddMessage(message, sender)

	local messageSender = AceGUI:Create("Label")
	messageSender:SetRelativeWidth(1)
	messageSender:SetText("|cFFE6D707Message from "..sender .. "|r")
	DEBUGWINDOW.mainScroller:AddChild(messageSender)
	
	local messageText = AceGUI:Create("Label")
	messageText:SetRelativeWidth(1)
	messageText:SetText("> "..message)
	DEBUGWINDOW.mainScroller:AddChild(messageText)

end

local function DEBUGMessageSuccess(sender)
	
end

local function DEBUGPrintMessages()
	if DEBUGWINDOW.mainScroller == nil then return end
	
	DEBUGWINDOW.mainScroller:ReleaseChildren()

	for k , v in ipairs(DEBUGMESSAGES) do
			DEBUGAddMessage(v.message, v.sender)
	end

end

local function DEBUGShowMessageContainer(container)
	container:SetLayout("Fill")
	DEBUGWINDOW.mainScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.mainScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.mainScroller)
	
	DEBUGPrintMessages()
end

local function DEBUGShowCards(container)
	
	container:SetLayout("Fill")
	DEBUGWINDOW.cardScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.cardScroller:SetLayout("Flow")
	container:AddChild(DEBUGWINDOW.cardScroller)
	for k , v in ipairs(GwentAddon.CardList) do

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
	
	
	
	--DEBUGWINDOW:AddChild(DEBUGWINDOW.mainScroller)

end

local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_EventFrame"); 
Gwent_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
Gwent_EventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_EventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_EventFrame:CHAT_MSG_ADDON(prefix, m, channel, s)
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

function Gwent_EventFrame:PLAYER_ENTERING_WORLD(loadedAddon)
	CreateDebug()
	if not RegisterAddonMessagePrefix(addonName) then
		print(addonName ..": Could not register prefix.")
	end
end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'debug' then
		if DEBUGWINDOW == nil then
			return
		end
		
		if DEBUGWINDOW:IsShown() then
			DEBUGWINDOW.frame:Hide()
		else 
			DEBUGWINDOW.frame:Show()
		end
		
	elseif msg == 'test' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, "This is a test message "..name , "whisper" , name)
		SendAddonMessage(addonName, "What if I type a really long text, will it wrap or not I don't know "..name , "whisper" , name)
		
	elseif msg == 'create' then
	
	GwentAddon:CreateCardsList()
	
	elseif msg == 'clear' then
		DEBUGWINDOW.mainScroller:ReleaseChildren()
	
	else
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd