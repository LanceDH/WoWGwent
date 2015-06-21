local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

local SIZE_CARD_HEIGHT = 75
local SIZE_CARD_WIDTH = 50

local _GwentPlayFrame = {}
local _PlayerHand = {}
local _PlayerSiege = {}
local _DraggedCard = nil
local _DragginOverFrame = nil
local _CardNr = 1

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

local function CreatePlayFrame()
	
	local PlayFrame = CreateFrame("frame", addonName.."PlayFrame", UIParent)
	--PlayFrame:SetPoint("topleft", parent.frame, "topleft", 0, 0)
	PlayFrame:SetHeight(750)
	PlayFrame:SetWidth(1000)
	PlayFrame:SetMovable(true)
	PlayFrame:SetPoint("Center", 250, 0)
	PlayFrame:RegisterForDrag("LeftButton")
	PlayFrame:SetScript("OnDragStart", PlayFrame.StartMoving )
	PlayFrame:SetScript("OnDragStop", PlayFrame.StopMovingOrSizing)
	--PlayFrame:SetClampedToScreen(true)
	PlayFrame:EnableMouse(true)
	
	PlayFrame.topleft = PlayFrame:CreateTexture(addonName.."PlayFrame_TL", "BACKGROUND")
	PlayFrame.topleft:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft")
	PlayFrame.topleft:SetTexCoord(0, 1, 0, 0.25)
	PlayFrame.topleft:SetWidth(128)
	PlayFrame.topleft:SetHeight(32)
	PlayFrame.topleft:SetPoint("topleft", PlayFrame)
	
	PlayFrame.bottomleft = PlayFrame:CreateTexture(addonName.."PlayFrame_BL", "BACKGROUND")
	PlayFrame.bottomleft:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTLEFT")
	PlayFrame.bottomleft:SetTexCoord(0, 1, 0.75, 1)
	PlayFrame.bottomleft:SetWidth(128)
	PlayFrame.bottomleft:SetHeight(32)
	PlayFrame.bottomleft:SetPoint("bottomleft", PlayFrame)
	
	PlayFrame.topright = PlayFrame:CreateTexture(addonName.."PlayFrame_TR", "BACKGROUND")
	PlayFrame.topright:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight")
	PlayFrame.topright:SetTexCoord(0, 1, 0, 0.25)
	PlayFrame.topright:SetWidth(64)
	PlayFrame.topright:SetHeight(32)
	PlayFrame.topright:SetPoint("topright", PlayFrame)
	
	PlayFrame.bottomright = PlayFrame:CreateTexture(addonName.."PlayFrame_BR", "BACKGROUND")
	PlayFrame.bottomright:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT")
	PlayFrame.bottomright:SetTexCoord(0, 1, 0.75, 1)
	PlayFrame.bottomright:SetWidth(64)
	PlayFrame.bottomright:SetHeight(32)
	PlayFrame.bottomright:SetPoint("bottomright", PlayFrame)
	
	PlayFrame.top = PlayFrame:CreateTexture(addonName.."PlayFrame_T", "BACKGROUND")
	PlayFrame.top:SetTexture("Interface\\HELPFRAME\\HelpFrame-Top", true)
	PlayFrame.top:SetTexCoord(0, 3, 0, 0.25)
	PlayFrame.top:SetPoint("topleft", PlayFrame.topleft, "topright")
	PlayFrame.top:SetPoint("bottomright", PlayFrame.topright, "bottomleft")
	
	PlayFrame.bottom = PlayFrame:CreateTexture(addonName.."PlayFrame_B", "BACKGROUND")
	PlayFrame.bottom:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTTOM", true)
	PlayFrame.bottom:SetTexCoord(0, 3, 0.75, 1)
	PlayFrame.bottom:SetPoint("topleft", PlayFrame.bottomleft, "topright")
	PlayFrame.bottom:SetPoint("bottomright", PlayFrame.bottomright, "bottomleft")
	
	PlayFrame.left = PlayFrame:CreateTexture(addonName.."PlayFrame_L", "BACKGROUND")
	PlayFrame.left:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft")
	PlayFrame.left:SetTexCoord(0, 1, 0.5, 1)
	PlayFrame.left:SetPoint("topleft", PlayFrame.topleft, "bottomleft")
	PlayFrame.left:SetPoint("bottomright", PlayFrame.bottomleft, "topright")
	
	PlayFrame.right = PlayFrame:CreateTexture(addonName.."PlayFrame_R", "BACKGROUND")
	PlayFrame.right:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight")
	PlayFrame.right:SetTexCoord(0, 1, 0.5, 1)
	PlayFrame.right:SetPoint("topleft", PlayFrame.topright, "bottomleft")
	PlayFrame.right:SetPoint("bottomright", PlayFrame.bottomright, "topright")
	
	PlayFrame.center = PlayFrame:CreateTexture(addonName.."PlayFrame_C", "BACKGROUND")
	PlayFrame.center:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft")
	PlayFrame.center:SetTexCoord(0.5, 1, 0.5, 1)
	PlayFrame.center:SetPoint("topleft", PlayFrame.topleft, "bottomright")
	PlayFrame.center:SetPoint("bottomright", PlayFrame.bottomright, "topleft")
	
	local parentLevel = PlayFrame:GetFrameLevel()
	
	PlayFrame.playerHand = CreateFrame("frame", addonName.."PlayFrame_PlayerHand", PlayFrame)
	PlayFrame.playerHand:SetPoint("bottom", PlayFrame, "bottom", 0, 23)
	PlayFrame.playerHand:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.playerHand:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.playerHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	PlayFrame.playerSiege = CreateFrame("frame", addonName.."PlayFrame_PlayerSiege", PlayFrame)
	PlayFrame.playerSiege:SetPoint("bottom", PlayFrame.playerHand, "top", 0, 20)
	PlayFrame.playerSiege:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.playerSiege:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.playerSiege:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		edgeFile = nil,
		tileSize = 0, edgeSize = 16,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
	  
	PlayFrame.playerRanged = CreateFrame("frame", addonName.."PlayFrame_PlayerRanged", PlayFrame)
	PlayFrame.playerRanged:SetPoint("bottom", PlayFrame.playerSiege, "top", 0, 10)
	PlayFrame.playerRanged:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.playerRanged:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.playerRanged:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	
	return PlayFrame
end

local function PlayerPlaceHand()
	for k, card in ipairs(_PlayerHand) do
		card:ClearAllPoints()
		card:SetPoint("topleft", _GwentPlayFrame.playerHand, "topleft", (k-1)*SIZE_CARD_WIDTH, 0)
		card:SetWidth(SIZE_CARD_WIDTH)
		card:SetHeight(SIZE_CARD_HEIGHT)
	end
end

local function PlayerPlaceSiege()
	for k, card in ipairs(_PlayerSiege) do
		card:ClearAllPoints()
		card:SetPoint("topleft", _GwentPlayFrame.playerSiege , "topleft", (k-1)*SIZE_CARD_WIDTH, 0)
		card:SetWidth(SIZE_CARD_WIDTH)
		card:SetHeight(SIZE_CARD_HEIGHT)
	end
end

local function PlaceAllCards()
	PlayerPlaceHand()
	PlayerPlaceSiege()
end

local function GetCardOfId(id)
	for k, v in ipairs(GwentAddon.CardList) do
		if v.Id == id then
			return v
		end
	end
	
	return nil
end

local function RemoveCardFromHand(card)
	local cardToRemove = nil
	for k, v in ipairs(_PlayerHand) do
		if v.nr == card.nr then
			cardToRemove = k
			break
		end
	end
	
	if cardToRemove ~= nil then
		table.remove(_PlayerHand, cardToRemove)
	end
	
end

local function StartDraggingCard(card)
	_DraggedCard = card
	print("dragging " .. _DraggedCard.data.name)
	card:StartMoving()
end

local function AddDraggedCardToNewList(list, frame)
	table.insert(list, _DraggedCard)
	RemoveCardFromHand(_DraggedCard)
	_DraggedCard:SetMovable(false)
	_DraggedCard:EnableMouse(false)
end

local function DroppingCardInSiege()
	local left, bottom, width, height = _GwentPlayFrame.playerSiege:GetBoundsRect()
	local mouseX, mouseY = GetCursorPosition()
	local s = _GwentPlayFrame.playerSiege:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s

	if mouseX > left and mouseX < left + width and mouseY > bottom and mouseY < bottom + height then
		print("Dropping in siege")
		return true
	end
	
	return false
	
end

local function DropCardArea(card)
	if DroppingCardInSiege() then
		AddDraggedCardToNewList(_PlayerSiege, _GwentPlayFrame.playerSiege)
		return true
	end
	return false
end

local function StopDraggingCard(card)

	if DropCardArea() then
		
	end

	_DraggedCard = nil
	print("stopped dragging ")
	card:StopMovingOrSizing()
	PlaceAllCards()
	
	

end

local function CreateCardOfId(id)
	
	local cardData = GetCardOfId(id)
	
	if not cardData then
		print("Could not create card with Id ".. id)
		return
	end

	local card = CreateFrame("frame", addonName.."_Card_".._CardNr, _GwentPlayFrame)
	card.data = cardData
	card.nr = _CardNr
	card:SetPoint("topleft", _GwentPlayFrame, "topleft", 0, 0)
	card:SetHeight(SIZE_CARD_HEIGHT)
	card:SetWidth(SIZE_CARD_WIDTH)
	card:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top 
	  = 0, bottom = 0 }
	  })
	  
	card:SetMovable(true)
	card:RegisterForDrag("LeftButton")
	card:SetScript("OnDragStart", function(self) StartDraggingCard(self) end)
	card:SetScript("OnDragStop", function(self) StopDraggingCard(self) end)
	card:SetClampedToScreen(true)
	card:EnableMouse(true)
	  
	card.name = card:CreateFontString(nil, nil, "GameFontNormal")
	card.name:SetPoint("topleft", card, "topleft", 0, 0)
	card.name:SetPoint("topright", card, "topright", 0, 0)
	card.name:SetHeight(15)
	card.name:SetJustifyH("center")
	card.name:SetText(cardData.name)
	  
	_CardNr = _CardNr + 1
	  
	return card
end

local function DrawCard()
	table.insert(_PlayerHand, CreateCardOfId(math.random(#GwentAddon.CardList)))
	
	PlaceAllCards()
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
	
	--table.insert(DEBUGMESSAGES, {sender = s, message = m})

	--DEBUGPrintMessages()
	
	-- Send Success Message
	--SendAddonMessage(addonName, TEXT_ADDONMSG_RECIEVED , "whisper" , s)

	
end

function Gwent_EventFrame:PLAYER_ENTERING_WORLD(loadedAddon)
	
	_GwentPlayFrame = CreatePlayFrame()
	
	GwentAddon:CreateCardsList()
	
	if not RegisterAddonMessagePrefix(addonName) then
		print(addonName ..": Could not register prefix.")
	end
end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'debug' then

		DEBUGToggleFrame()
		
	elseif msg == 'test' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, "This is a test message "..name , "whisper" , name)
		SendAddonMessage(addonName, "What if I type a really long text, will it wrap or not I don't know "..name , "whisper" , name)
		
	elseif msg == 'toggle' then
	
	if GwentPlayFrame ~= nil then
		
		if GwentPlayFrame:IsShown() then
			GwentPlayFrame:Hide()
		else
			GwentPlayFrame:Show()
		end
	end
	
	elseif msg == 'draw' then
		DrawCard()
	else
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd