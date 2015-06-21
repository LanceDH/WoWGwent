local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

local SIZE_CARD_HEIGHT = 75
local SIZE_CARD_WIDTH = 50
local SIZE_ICON = 64

local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_CARD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local TEXTURE_ICONS = {["path"]="Interface\\GUILDFRAME\\GUILDEMBLEMSLG_01", ["width"]=1024, ["height"]=1024}

local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local COORDS_ICON_RANGED = {["x"]=64*15, ["y"]=64*1}
local COORDS_ICON_SIEGE = {["x"]=64*3, ["y"]=64*7}

local MESSAGE_PLACEINAREA = "%s#%d"
local TEXT_SIEGE = "siege"
local TEXT_RANGED = "ranged"
local TEXT_MELEE = "melee"

local _ChallengerName = nil

local _GwentPlayFrame = {}
local _PlayerHand = {}
local _PlayerSiege = {}
local _PlayerRanged = {}
local _PlayerMelee = {}
local _EnemySiege = {}
local _EnemyRanged = {}
local _EnemyMelee = {}
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

local function CreateCardArea(name, parent, coords)
	local frame = CreateFrame("frame", addonName.."PlayFrame_" .. name, parent)
	--frame:SetPoint("bottom", PlayFrame.playerRanged, "top", 0, 10)
	frame:SetHeight(SIZE_CARD_HEIGHT)
	frame:SetWidth(SIZE_CARD_WIDTH * 10)
	frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	frame.points = frame:CreateFontString(nil, nil, "GameFontNormal")
	frame.points:SetPoint("right", frame, "left", -20, 0)
	frame.points:SetText(0)
	
	frame.icon = frame:CreateTexture(addonName.."PlayFrame_PlayerMelee_ICON", "art")
	frame.icon:SetTexture(TEXTURE_ICONS.path)
	frame.icon:SetTexCoord(coords.x/TEXTURE_ICONS.width, (coords.x+SIZE_ICON)/TEXTURE_ICONS.width, coords.y/TEXTURE_ICONS.height, (coords.y+SIZE_ICON)/TEXTURE_ICONS.height)
	frame.icon:SetVertexColor(1, 1, 1, 0.3)
	frame.icon:SetWidth(SIZE_CARD_HEIGHT)
	frame.icon:SetHeight(SIZE_CARD_HEIGHT)
	frame.icon:SetPoint("center", frame)
	
	return frame
end

local function CreatePlayFrame()
	
	local PlayFrame = CreateFrame("frame", addonName.."PlayFrame", UIParent)
	PlayFrame:SetHeight(750)
	PlayFrame:SetWidth(1000)
	PlayFrame:SetMovable(true)
	PlayFrame:SetPoint("Center", 250, 0)
	PlayFrame:RegisterForDrag("LeftButton")
	PlayFrame:SetScript("OnDragStart", PlayFrame.StartMoving )
	PlayFrame:SetScript("OnDragStop", PlayFrame.StopMovingOrSizing)
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

	-- player hand
	PlayFrame.playerHand = CreateFrame("frame", addonName.."PlayFrame_PlayerHand", PlayFrame)
	PlayFrame.playerHand:SetPoint("bottom", PlayFrame, "bottom", 0, 23)
	PlayFrame.playerHand:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.playerHand:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.playerHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	-- player siege
	PlayFrame.playerSiege = CreateCardArea("PlayerRanged", PlayFrame, COORDS_ICON_SIEGE)
	PlayFrame.playerSiege:SetPoint("bottom", PlayFrame.playerHand, "top", 0, 20) 
	-- player ranged
	PlayFrame.playerRanged = CreateCardArea("PlayerRanged", PlayFrame, COORDS_ICON_RANGED)
	PlayFrame.playerRanged:SetPoint("bottom", PlayFrame.playerSiege, "top", 0, 10)  
	-- player melee
	PlayFrame.playerMelee = CreateCardArea("PlayerMelee", PlayFrame, COORDS_ICON_MELEE)
	PlayFrame.playerMelee:SetPoint("bottom", PlayFrame.playerRanged, "top", 0, 10)

	-- player hand
	PlayFrame.enemyHand = CreateFrame("frame", addonName.."PlayFrame_EnemyHand", PlayFrame)
	PlayFrame.enemyHand:SetPoint("top", PlayFrame, "top", 0, -30)
	PlayFrame.enemyHand:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.enemyHand:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.enemyHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	-- player siege
	PlayFrame.enemySiege = CreateCardArea("EnemyRanged", PlayFrame, COORDS_ICON_SIEGE)
	PlayFrame.enemySiege:SetPoint("top", PlayFrame.enemyHand, "bottom", 0, -20) 
	-- player ranged
	PlayFrame.enemyRanged = CreateCardArea("EnemyRanged", PlayFrame, COORDS_ICON_RANGED)
	PlayFrame.enemyRanged:SetPoint("top", PlayFrame.enemySiege, "bottom", 0, -10)  
	-- player melee
	PlayFrame.enemyMelee = CreateCardArea("EnemyMelee", PlayFrame, COORDS_ICON_MELEE)
	PlayFrame.enemyMelee:SetPoint("top", PlayFrame.enemyRanged, "bottom", 0, -10)
	
	return PlayFrame
end

local function PlayerPlaceCardsOnFrame(list, frame)
	local totalPoints = 0

	for k, card in ipairs(list) do
		card:ClearAllPoints()
		card:SetPoint("topleft", frame , "topleft", (k-1)*SIZE_CARD_WIDTH, 0)
		card:SetWidth(SIZE_CARD_WIDTH)
		card:SetHeight(SIZE_CARD_HEIGHT)
		
		totalPoints = totalPoints + card.data.strength
	end
	
	if frame.points ~= nil then
		frame.points:SetText(totalPoints)
	end
end

local function PlaceAllCards()
	PlayerPlaceCardsOnFrame(_PlayerHand, _GwentPlayFrame.playerHand)
	PlayerPlaceCardsOnFrame(_PlayerSiege, _GwentPlayFrame.playerSiege)
	PlayerPlaceCardsOnFrame(_PlayerRanged, _GwentPlayFrame.playerRanged)
	PlayerPlaceCardsOnFrame(_PlayerMelee, _GwentPlayFrame.playerMelee)
	-- Place enemy hand
	PlayerPlaceCardsOnFrame(_EnemySiege, _GwentPlayFrame.enemySiege)
	PlayerPlaceCardsOnFrame(_EnemyRanged, _GwentPlayFrame.enemyRanged)
	PlayerPlaceCardsOnFrame(_EnemyMelee, _GwentPlayFrame.enemyMelee)
end

local function GetCardOfId(id)
	for k, v in ipairs(GwentAddon.CardList) do
		if v.Id == tonumber(id) then
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
	card:StartMoving()
end

local function AddCardToNewList(card, list)
	GwentAddon:DEBUGMessageSent("Trying to add card to list")
	table.insert(list, card)
	card:SetMovable(false)
	card:EnableMouse(false)
end

local function IsRightTypeForArea(card, areaType)
	for k, v in pairs(card.data.cardType) do
		if k == areaType then
			return v
		end
	end
	return false
end

local function DroppingCardOnFrame(frame)
	local left, bottom, width, height = frame:GetBoundsRect()
	local mouseX, mouseY = GetCursorPosition()
	local s = frame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s

	if mouseX > left and mouseX < left + width and mouseY > bottom and mouseY < bottom + height then
		return true
	end
	
	return false
	
end

local function DropCardArea(card)
	if DroppingCardOnFrame(_GwentPlayFrame.playerSiege) and IsRightTypeForArea(card, TEXT_SIEGE) then
		
		AddCardToNewList(card, _PlayerSiege)
		RemoveCardFromHand(card)
		return true, TEXT_SIEGE
	elseif DroppingCardOnFrame(_GwentPlayFrame.playerRanged) and IsRightTypeForArea(card, TEXT_RANGED) then
		
		AddCardToNewList(card, _PlayerRanged)
		RemoveCardFromHand(card)
		return true, TEXT_RANGED
	elseif DroppingCardOnFrame(_GwentPlayFrame.playerMelee) and IsRightTypeForArea(card, TEXT_MELEE) then
		
		AddCardToNewList(card, _PlayerMelee)
		RemoveCardFromHand(card)
		return true, TEXT_MELEE
	end
	return false
end

local function StopDraggingCard(card)
	local success, area = DropCardArea(_DraggedCard)
	if success and _DraggedCard ~= nil then
		--local message = string.format(MESSAGE_PLACEINAREA, area, "5")
		_DraggedCard = nil
		--GwentAddon:DEBUGMessageSent(string.format(MESSAGE_PLACEINAREA, area, _DraggedCard.data.Id), _ChallengerName)
		SendAddonMessage(addonName, area .. "#" .. card.data.Id, "whisper" , _ChallengerName)
		--SendAddonMessage(addonName, "test", "whisper" , _ChallengerName)
		
	end

	_DraggedCard = nil
	card:StopMovingOrSizing()
	PlaceAllCards()
	
	

end

local function CreateCardOfId(id)
	
	local cardData = GetCardOfId(id)
	
	GwentAddon:DEBUGMessageSent("Trying to create card with id "..id)
	
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
	card:SetBackdrop({bgFile = TEXTURE_CARD_BG,
      edgeFile = TEXTURE_CARD_BORDER,
	  tileSize = 0, edgeSize = 4,
      insets = { left = 0, right = 0, top 
	  = 0, bottom = 0 }
	  })
	  
	card:SetMovable(true)
	card:RegisterForDrag("LeftButton")
	card:SetScript("OnDragStart", function(self) StartDraggingCard(self) end)
	card:SetScript("OnDragStop", function(self) StopDraggingCard(self) end)
	card:EnableMouse(true)
	  
	card.name = card:CreateFontString(nil, nil, "GameFontNormal")
	card.name:SetPoint("topleft", card, "topleft", 2, -2)
	card.name:SetPoint("bottomright", card, "topright", -2, -22)
	card.name:SetJustifyH("center")
	card.name:SetText(cardData.name)
	
	card.strength = card:CreateFontString(nil, nil, "GameFontNormal")
	card.strength:SetPoint("topleft", card.name, "topleft", 2, -7)
	card.strength:SetPoint("bottomright", card.name, "bottomright", -2, -27)
	card.strength:SetJustifyH("left")
	card.strength:SetText(cardData.strength)
	  
	_CardNr = _CardNr + 1
	  
	return card
end

local function DrawCard()
	table.insert(_PlayerHand, CreateCardOfId(math.random(#GwentAddon.CardList)))
	
	PlaceAllCards()
end

local function AddEnemyCard(message)
	--print(message, string.match(message, "(%a+)#(%d+)"))
	local areaType, id = string.match(message, "(%a+)#(%d+)")
	GwentAddon:DEBUGMessageSent(message .. " - ".. string.match(message, "(%a+)#(%d+)"))
	local card = CreateCardOfId(id)
	if areaType == TEXT_SIEGE then
		AddCardToNewList(card, _EnemySiege)
	elseif areaType == TEXT_RANGED then
		AddCardToNewList(card, _EnemyRanged)
	elseif areaType == TEXT_MELEE then
		AddCardToNewList(card, _EnemyMelee)
	end
	
	PlaceAllCards()
end

local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_EventFrame"); 
Gwent_EventFrame:RegisterEvent("ADDON_LOADED");
Gwent_EventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_EventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_EventFrame:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= addonName then
		return
	end
	
	if message == TEXT_ADDONMSG_RECIEVED then
		return
	end
	
	-- Enemy played card
	if string.find(message, "#") then
		AddEnemyCard(message)
	end
	
end

function Gwent_EventFrame:ADDON_LOADED(ADDON_LOADED)
	if ADDON_LOADED ~= addonName then return end
	
	_GwentPlayFrame = CreatePlayFrame()
	
	GwentAddon:CreateCardsList()
	
	if not RegisterAddonMessagePrefix(addonName) then
		print(addonName ..": Could not register prefix.")
	end
end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'debug' then

		GwentAddon:DEBUGToggleFrame()
		
	elseif msg == 'test' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, "What if I type a really long text, will it wrap or not I don't know "..name , "whisper" , name)
	
	elseif msg == 'challenge' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, "It's time to du-du-duel" , "whisper" , name)
		_ChallengerName = name
		GwentAddon:DEBUGMessageSent("duelling ".._ChallengerName, _ChallengerName)
	
	elseif msg == 'toggle' then
	
	if GwentPlayFrame ~= nil then
		
		if GwentPlayFrame:IsShown() then
			GwentPlayFrame:Hide()
		else
			GwentPlayFrame:Show()
		end
	end
	
	elseif msg == 'draw' then
		for i=1,10 do
			DrawCard()
		end
	else
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd