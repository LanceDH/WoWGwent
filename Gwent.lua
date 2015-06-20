local addonName, BGS_TrackerClasses = ...
local AceGUI = LibStub("AceGUI-3.0")

local DEBUGWINDOW = nil
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

local function CreateDebug()
 
	DEBUGWINDOW = AceGUI:Create("Frame")
	DEBUGWINDOW:SetTitle("Gwent Debug")
	DEBUGWINDOW:SetLayout("Fill")
	DEBUGWINDOW:SetWidth(250)
	DEBUGWINDOW.frame:Hide()
	
	DEBUGWINDOW.mainScroller = AceGUI:Create("ScrollFrame")
	DEBUGWINDOW.mainScroller:SetLayout("Flow")
	DEBUGWINDOW:AddChild(DEBUGWINDOW.mainScroller)

end

local function DEBUGAddMessage(message, sender)
	local messageSender = AceGUI:Create("SimpleGroup")
	messageSender:SetRelativeWidth(1)
	messageSender:SetHeight(10)
	messageSender:SetLayout("fill")
	messageSender.text = messageSender.frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	messageSender.text:SetText("|cFFE6D707Message from "..sender .. "|r")
	messageSender.text:SetJustifyH("left")
	messageSender.text:SetJustifyV("top")
	messageSender.text:SetPoint("topleft", 0, 0)
	messageSender.text:SetPoint("bottomright")
	DEBUGWINDOW.mainScroller:AddChild(messageSender)
	
	
	
	local messageText = AceGUI:Create("SimpleGroup")
	messageText:SetRelativeWidth(1)
	messageText:SetHeight(20)
	messageText:SetLayout("fill")
	messageText.text = messageText.frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	messageText.text:SetText("> "..message)
	messageText.text:SetWordWrap(true)
	messageText.text:SetJustifyH("left")
	messageText.text:SetJustifyV("top")
	messageText.text:SetPoint("topleft", 0, 0)
	messageText.text:SetPoint("bottomright")
	DEBUGWINDOW.mainScroller:AddChild(messageText)
end

local function DEBUGMessageSuccess(sender)
	local messageSender = AceGUI:Create("SimpleGroup")
	messageSender:SetRelativeWidth(1)
	messageSender:SetHeight(10)
	messageSender:SetLayout("fill")
	messageSender.text = messageSender.frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	messageSender.text:SetText("|cFF00CC0EMessage to "..sender .. " success|r")
	messageSender.text:SetJustifyH("left")
	messageSender.text:SetJustifyV("top")
	messageSender.text:SetPoint("topleft", 0, 0)
	messageSender.text:SetPoint("bottomright")
	DEBUGWINDOW.mainScroller:AddChild(messageSender)
end


local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_EventFrame"); 
Gwent_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
Gwent_EventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_EventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_EventFrame:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= addonName then
		return
	end
	
	if message == TEXT_ADDONMSG_RECIEVED then
		DEBUGMessageSuccess(sender)
		return
	end
	
	DEBUGAddMessage(message, sender)
	
	
	-- Send Success Message
	SendAddonMessage(addonName, TEXT_ADDONMSG_RECIEVED , "whisper" , sender)

	
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
		
	elseif msg == 'info' then
	
	
	elseif msg == 'clear' then
	
	
	else
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd