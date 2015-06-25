local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

-- local SIZE_CARD_HEIGHT = 72
-- local SIZE_CARD_WIDTH = 40
local SIZE_CARD_HEIGHT = 79
local SIZE_CARD_WIDTH = 49
local SIZE_ICON = 64
local SIZE_BORDER_TOTAL = 100

local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_CARD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
--local TEXTURE_CARD_ICONBG = "Interface\\COMMON\\Indicator-Gray"
local TEXTURE_CARD_ICONBG = "Interface\\COMMON\\Indicator-Yellow" 
local TEXTURE_ICONS = {["path"]="Interface\\GUILDFRAME\\GUILDEMBLEMSLG_01", ["width"]=1024, ["height"]=1024}
local TEXTURE_TOTAL_BORDERNORMAL = "Interface\\UNITPOWERBARALT\\MetalPlain_Circular_Frame"
local TEXTURE_TOTAL_BORDERWINNING = "Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame"
local TEXTURE_ARROWDOWN = "Interface\\ICONS\\misc_arrowdown"
local TEXTURE_ARROWUP = "Interface\\ICONS\\misc_arrowlup"
local TEXTURE_CUSTOM_PATH = "Interface\\AddOns\\Gwent\\CardTextures\\"


local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local COORDS_ICON_RANGED = {["x"]=64*15, ["y"]=64*1}
local COORDS_ICON_SIEGE = {["x"]=64*3, ["y"]=64*7}
local COORDS_SMALLCARD = {["left"]=76/256, ["right"]=244/256, ["top"]=30/512, ["bottom"]=300/512}

local MESSAGE_PLACEINAREA = "%s#%d"
local MESSAGE_CHALLENGE = "It's time to du-du-du-duel"
local MESSAGE_LOGOUT = "logged out"
local MESSAGE_PASS = "passing"
local MESSAGE_WON = "win: "
local MESSAGE_TIE = "tie"

local TEXT_SIEGE = "siege"
local TEXT_RANGED = "ranged"
local TEXT_MELEE = "melee"

local _CardPool = {}

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

local _YourTurn = false
local _EnemyPassed = false
local _PlayerPassed = false

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

local function IsYourTurn(bool)
	_YourTurn = bool
	
	for k, card in ipairs(_PlayerHand) do
		card:SetMovable(bool)
		card:EnableMouse(bool)
	end
	
	_GwentPlayFrame.playerTurn:Hide()
	_GwentPlayFrame.enemyTurn:Hide()
	
	if _YourTurn then
		_GwentPlayFrame.playerTurn:Show()
	else
		_GwentPlayFrame.enemyTurn:Show()
	end
end

local function PassTurn()
	if _YourTurn then
		_PlayerPassed = true
		_GwentPlayFrame.passButton:Disable()
		SendAddonMessage(addonName, MESSAGE_PASS , "whisper" , _ChallengerName)
		IsYourTurn(false)
	end
end

local function CreateCardArea(name, parent, coords)
	local frame = CreateFrame("frame", addonName.."PlayFrame_" .. name, parent)
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
	
	frame.icon = frame:CreateTexture(addonName.."PlayFrame_"..name.."_ICON", "art")
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
	PlayFrame:SetHeight(780)
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
	  
	PlayFrame.passButton = CreateFrame("button", addonName.."PlayFrame_PassButton", PlayFrame, "UIPanelButtonTemplate")
	PlayFrame.passButton:SetPoint("left", PlayFrame.playerHand, "right", 20, 0)
	PlayFrame.passButton:SetSize(100, 25)
	PlayFrame.passButton:SetText("Pass")
	PlayFrame.passButton:SetScript("OnClick", PassTurn)
	
	  
	-- player siege
	PlayFrame.playerSiege = CreateCardArea("PlayerRanged", PlayFrame, COORDS_ICON_SIEGE)
	PlayFrame.playerSiege:SetPoint("bottom", PlayFrame.playerHand, "top", 0, 20) 
	-- player ranged
	PlayFrame.playerRanged = CreateCardArea("PlayerRanged", PlayFrame, COORDS_ICON_RANGED)
	PlayFrame.playerRanged:SetPoint("bottom", PlayFrame.playerSiege, "top", 0, 10)  
	-- player melee
	PlayFrame.playerMelee = CreateCardArea("PlayerMelee", PlayFrame, COORDS_ICON_MELEE)
	PlayFrame.playerMelee:SetPoint("bottom", PlayFrame.playerRanged, "top", 0, 10)
	
	-- player total Points
	PlayFrame.playerTotal = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerTotal", "ARTWORK")
	PlayFrame.playerTotal:SetDrawLayer("ARTWORK", -7)
	PlayFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.playerTotal:SetWidth(SIZE_BORDER_TOTAL)
	PlayFrame.playerTotal:SetHeight(SIZE_BORDER_TOTAL)
	PlayFrame.playerTotal:SetPoint("right", PlayFrame.playerRanged, "left", -75, 0)
	
	PlayFrame.playerTotal.points = PlayFrame:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	PlayFrame.playerTotal.points:SetPoint("topleft", PlayFrame.playerTotal)
	PlayFrame.playerTotal.points:SetPoint("bottomright", PlayFrame.playerTotal)
	PlayFrame.playerTotal.points:SetText(0)

	-- player portrait
	PlayFrame.playerPortrait = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerPortrait", "ARTWORK")
	PlayFrame.playerPortrait:SetDrawLayer("ARTWORK", -8)
	PlayFrame.playerPortrait:SetWidth(SIZE_CARD_HEIGHT-10)
	PlayFrame.playerPortrait:SetHeight(SIZE_CARD_HEIGHT-10)
	PlayFrame.playerPortrait:SetPoint("right", PlayFrame.playerHand, "left", -150, 0)
	SetPortraitTexture(PlayFrame.playerPortrait, "player")
	
	PlayFrame.playerPortraitborder = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerPortraitBorder", "ARTWORK")
	PlayFrame.playerPortraitborder:SetDrawLayer("ARTWORK", -7)
	PlayFrame.playerPortraitborder:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.playerPortraitborder:SetWidth(SIZE_CARD_HEIGHT+50)
	PlayFrame.playerPortraitborder:SetHeight(SIZE_CARD_HEIGHT+50)
	PlayFrame.playerPortraitborder:SetPoint("center", PlayFrame.playerPortrait)
	
	-- player nametag
	PlayFrame.playerNametag = PlayFrame:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.playerNametag:SetPoint("left", PlayFrame.playerPortrait, "right", 10, 0)
	PlayFrame.playerNametag:SetPoint("right", PlayFrame.playerHand, "left", -10, 0)
	PlayFrame.playerNametag:SetJustifyH("left")
	PlayFrame.playerNametag:SetText(GetUnitName("player", false))
	
	-- player turn arrow
	PlayFrame.playerTurn = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerTurn", "ARTWORK")
	PlayFrame.playerTurn:SetDrawLayer("ARTWORK", -7)
	PlayFrame.playerTurn:SetTexture(TEXTURE_ARROWDOWN)
	PlayFrame.playerTurn:SetWidth(SIZE_ICON)
	PlayFrame.playerTurn:SetHeight(SIZE_ICON)
	PlayFrame.playerTurn:SetPoint("right", PlayFrame.playerSiege, "left", -75, 0)
	PlayFrame.playerTurn:Hide()
	
	
	
	
	-- enemy hand
	PlayFrame.enemyHand = CreateFrame("frame", addonName.."PlayFrame_EnemyHand", PlayFrame)
	PlayFrame.enemyHand:SetPoint("top", PlayFrame, "top", 0, -30)
	PlayFrame.enemyHand:SetHeight(SIZE_CARD_HEIGHT)
	PlayFrame.enemyHand:SetWidth(SIZE_CARD_WIDTH * 10)
	PlayFrame.enemyHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	-- enemy siege
	PlayFrame.enemySiege = CreateCardArea("EnemyRanged", PlayFrame, COORDS_ICON_SIEGE)
	PlayFrame.enemySiege:SetPoint("top", PlayFrame.enemyHand, "bottom", 0, -20) 
	-- enemy ranged
	PlayFrame.enemyRanged = CreateCardArea("EnemyRanged", PlayFrame, COORDS_ICON_RANGED)
	PlayFrame.enemyRanged:SetPoint("top", PlayFrame.enemySiege, "bottom", 0, -10)  
	-- enemy melee
	PlayFrame.enemyMelee = CreateCardArea("EnemyMelee", PlayFrame, COORDS_ICON_MELEE)
	PlayFrame.enemyMelee:SetPoint("top", PlayFrame.enemyRanged, "bottom", 0, -10)
	
	-- player total Points
	PlayFrame.enemyTotal = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyTotal", "ARTWORK")
	PlayFrame.enemyTotal:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.enemyTotal:SetWidth(SIZE_BORDER_TOTAL)
	PlayFrame.enemyTotal:SetHeight(SIZE_BORDER_TOTAL)
	PlayFrame.enemyTotal:SetPoint("right", PlayFrame.enemyRanged, "left", -75, 0)
	
	PlayFrame.enemyTotal.points = PlayFrame:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	PlayFrame.enemyTotal.points:SetPoint("topleft", PlayFrame.enemyTotal)
	PlayFrame.enemyTotal.points:SetPoint("bottomright", PlayFrame.enemyTotal)
	PlayFrame.enemyTotal.points:SetText(0)
	
	-- player portrait
	PlayFrame.enemyPortrait = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyPortrait", "art")
	PlayFrame.enemyPortrait:SetTexture("Interface\\CHARACTERFRAME\\TemporaryPortrait-Vehicle-Organic")
	PlayFrame.enemyPortrait:SetWidth(SIZE_CARD_HEIGHT-10)
	PlayFrame.enemyPortrait:SetHeight(SIZE_CARD_HEIGHT-10)
	PlayFrame.enemyPortrait:SetPoint("right", PlayFrame.enemyHand, "left", -150, 0)
	--SetPortraitTexture(PlayFrame.playerPortrait, "player")
	
	PlayFrame.enemyPortraitborder = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyPortraitBorder", "ARTWORK")
	PlayFrame.enemyPortraitborder:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyPortraitborder:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.enemyPortraitborder:SetWidth(SIZE_CARD_HEIGHT+50)
	PlayFrame.enemyPortraitborder:SetHeight(SIZE_CARD_HEIGHT+50)
	PlayFrame.enemyPortraitborder:SetPoint("center", PlayFrame.enemyPortrait)
	
	-- enemy nametag
	PlayFrame.enemyNametag = PlayFrame:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.enemyNametag:SetPoint("left", PlayFrame.enemyPortrait, "right", 10, 0)
	PlayFrame.enemyNametag:SetPoint("right", PlayFrame.enemyHand, "left", -10, 0)
	PlayFrame.enemyNametag:SetJustifyH("left")
	--PlayFrame.enemyNametag:SetText(GetUnitName("player", false))
	
	-- player turn arrow
	PlayFrame.enemyTurn = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyTurn", "ARTWORK")
	PlayFrame.enemyTurn:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyTurn:SetTexture(TEXTURE_ARROWUP)
	PlayFrame.enemyTurn:SetWidth(SIZE_ICON)
	PlayFrame.enemyTurn:SetHeight(SIZE_ICON)
	PlayFrame.enemyTurn:SetPoint("right", PlayFrame.enemySiege, "left", -75, 0)
	PlayFrame.enemyTurn:Hide()
	
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
		return totalPoints
	end
end

local function UpdateTotalBorders(playerPoints, enemyPoints)
	_GwentPlayFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	_GwentPlayFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	
	if playerPoints > enemyPoints  then
		_GwentPlayFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
	elseif enemyPoints > playerPoints then
		_GwentPlayFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
	end
	
end

local function UpdateTotalPoints(playerPoints, enemyPoints)
	_GwentPlayFrame.playerTotal.points:SetText(playerPoints)
	_GwentPlayFrame.playerTotal.amount = playerPoints
	_GwentPlayFrame.enemyTotal.points:SetText(enemyPoints)
	_GwentPlayFrame.enemyTotal.amount = enemyPoints
end

local function PlaceAllCards()
	local playerPoints = 0
	PlayerPlaceCardsOnFrame(_PlayerHand, _GwentPlayFrame.playerHand)
	playerPoints = playerPoints + PlayerPlaceCardsOnFrame(_PlayerSiege, _GwentPlayFrame.playerSiege)
	playerPoints = playerPoints + PlayerPlaceCardsOnFrame(_PlayerRanged, _GwentPlayFrame.playerRanged)
	playerPoints = playerPoints + PlayerPlaceCardsOnFrame(_PlayerMelee, _GwentPlayFrame.playerMelee)
	
	local enemyPoints = 0
	-- Place enemy hand
	enemyPoints = enemyPoints + PlayerPlaceCardsOnFrame(_EnemySiege, _GwentPlayFrame.enemySiege)
	enemyPoints = enemyPoints + PlayerPlaceCardsOnFrame(_EnemyRanged, _GwentPlayFrame.enemyRanged)
	enemyPoints = enemyPoints + PlayerPlaceCardsOnFrame(_EnemyMelee, _GwentPlayFrame.enemyMelee)
	
	UpdateTotalPoints(playerPoints, enemyPoints)
	UpdateTotalBorders(playerPoints, enemyPoints)
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
		_DraggedCard = nil

		SendAddonMessage(addonName, string.format(MESSAGE_PLACEINAREA, area, card.data.Id), "whisper" , _ChallengerName)
		
		-- don't end your turn if enemy passed
		if not _EnemyPassed then
			IsYourTurn(false)
		end
		
	end

	_DraggedCard = nil
	card:StopMovingOrSizing()
	PlaceAllCards()
	
	

end

local function CeateCardIcon(name, parent, coords)
	icon = parent:CreateTexture(name, "art")
	icon:SetDrawLayer("ARTWORK", 2)
	icon:SetTexture(TEXTURE_ICONS.path)
	icon:SetTexCoord(coords.x/TEXTURE_ICONS.width, (coords.x+SIZE_ICON)/TEXTURE_ICONS.width, coords.y/TEXTURE_ICONS.height, (coords.y+SIZE_ICON)/TEXTURE_ICONS.height)
	--icon:SetVertexColor(1, 1, 1, 0.3)
	icon:SetWidth(SIZE_CARD_WIDTH/2)
	icon:SetHeight(SIZE_CARD_WIDTH/2)
	
	return icon
end

local function CreateCardTypeIcons(card)
	local count = 0;

	if card.data.cardType.melee then
		card.iconMeleeBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_IconMeleeBG", "ARTWORK")
		card.iconMeleeBG:SetDrawLayer("ARTWORK", 1)
		card.iconMeleeBG:SetTexture(TEXTURE_CARD_ICONBG)
		card.iconMeleeBG:SetVertexColor(0, 0, 0, .75)
		card.iconMeleeBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
		card.iconMeleeBG:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		card.iconMeleeBG:SetHeight(SIZE_CARD_WIDTH/2)
		card.iconMeleeBG:SetWidth(SIZE_CARD_WIDTH/2)
		
		card.iconMelee = CeateCardIcon(card:GetName() .. "_IconMelee", card, COORDS_ICON_MELEE)
		card.iconMelee:SetPoint("center", card.iconMeleeBG)
		--card.iconMelee:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		count = count + 1
	end
	if card.data.cardType.ranged then
		card.iconRangedBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_IconRangedBG", "ARTWORK")
		card.iconRangedBG:SetDrawLayer("ARTWORK", 1)
		card.iconRangedBG:SetTexture(TEXTURE_CARD_ICONBG)
		card.iconRangedBG:SetVertexColor(0, 0, 0, .75)
		card.iconRangedBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
		card.iconRangedBG:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		card.iconRangedBG:SetHeight(SIZE_CARD_WIDTH/2)
		card.iconRangedBG:SetWidth(SIZE_CARD_WIDTH/2)
	
		card.iconRanged = CeateCardIcon(card:GetName() .. "_IconRanged", card, COORDS_ICON_RANGED)
		card.iconRanged:SetPoint("center", card.iconRangedBG)
		--card.iconRanged:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		count = count + 1
	end
	if card.data.cardType.siege then
		card.iconSiegeBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_IconSiegeBG", "ARTWORK")
		card.iconSiegeBG:SetDrawLayer("ARTWORK", 1)
		card.iconSiegeBG:SetTexture(TEXTURE_CARD_ICONBG)
		card.iconSiegeBG:SetVertexColor(0, 0, 0, .75)
		card.iconSiegeBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
		card.iconSiegeBG:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		card.iconSiegeBG:SetHeight(SIZE_CARD_WIDTH/2)
		card.iconSiegeBG:SetWidth(SIZE_CARD_WIDTH/2)
	
		card.iconSiege = CeateCardIcon(card:GetName() .. "_IconSiege", card, COORDS_ICON_SIEGE)
		card.iconSiege:SetPoint("center", card.iconSiegeBG)
		--card.iconSiege:SetPoint("bottomleft", card, "bottomleft", (SIZE_CARD_WIDTH/2)*count, 0)
		count = count + 1
	end
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
	
	-- card.texture = card:CreateTexture(addonName.."_Card_".._CardNr.."_Texture", "ARTWORK")
	-- card.texture:SetDrawLayer("ARTWORK", 0)
	-- card.texture:SetTexture(TEXTURE_CUSTOM_PATH..cardData.texture)
	-- card.texture:SetTexCoord(COORDS_SMALLCARD.left, COORDS_SMALLCARD.right, COORDS_SMALLCARD.top, COORDS_SMALLCARD.bottom)
	-- card.texture:SetPoint("topleft", card, 2, -2)
	-- card.texture:SetPoint("bottomright", card, -2, 2)
	
	card:SetMovable(false)
	card:RegisterForDrag("LeftButton")
	card:SetScript("OnDragStart", function(self) StartDraggingCard(self) end)
	card:SetScript("OnDragStop", function(self) StopDraggingCard(self) end)
	card:EnableMouse(false)
	  
	-- card.name = card:CreateFontString(nil, nil, "GameFontNormal")
	-- card.name:SetPoint("topleft", card, "topleft", 2, -2)
	-- card.name:SetPoint("bottomright", card, "topright", -2, -22)
	-- card.name:SetJustifyH("center")
	-- card.name:SetText(cardData.name)
	
	
	card.strengthBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_StrengthBG", "ARTWORK")
	card.strengthBG:SetDrawLayer("ARTWORK", 1)
	card.strengthBG:SetTexture(TEXTURE_CARD_ICONBG)
	card.strengthBG:SetVertexColor(0, 0, 0, .75)
	card.strengthBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
	card.strengthBG:SetPoint("topleft", card, 0, 0)
	card.strengthBG:SetHeight(SIZE_CARD_WIDTH/2)
	card.strengthBG:SetWidth(SIZE_CARD_WIDTH/2)
	
	--card.strengthBG:SetPoint("bottomright", card, -2, 2)
	
	card.strength = card:CreateFontString(nil, nil, "GameFontWhite")
	--card.strength:SetDrawLayer("ARTWORK", 1)
	card.strength:SetPoint("topleft", card.strengthBG)
	card.strength:SetPoint("bottomright", card.strengthBG)
	--card.strength:SetPoint("bottomright", card, "bottomright", -2, -7)
	card.strength:SetJustifyH("center")
	card.strength:SetJustifyV("middle")
	card.strength:SetText(cardData.strength)
	  
	CreateCardTypeIcons(card)
	  
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

local function ChangeChallenger(sender)
	_ChallengerName = sender
	_GwentPlayFrame.enemyNametag:SetText(_ChallengerName)
	for i=1,10 do
		DrawCard()
	end
	
	local challenger = GetUnitName("target", true)	
	if challenger ~= nil then
		SetPortraitTexture(_GwentPlayFrame.enemyPortrait, "target")
		
	end
end

local function DestroyCardsInList(list)
	for k, card in pairs(list) do
		table.insert(_CardPool, card)
		card:Hide()
		list[k] = nil
	end
	
	list = {}
end

local function ResetGame() 
	_ChallengerName = nil
	DestroyCardsInList(_PlayerHand)
	DestroyCardsInList(_PlayerSiege)
	DestroyCardsInList(_PlayerRanged)
	DestroyCardsInList(_PlayerMelee)
	DestroyCardsInList(_EnemySiege)
	DestroyCardsInList(_EnemyRanged)
	DestroyCardsInList(_EnemyMelee)
	PlaceAllCards()
	_DraggedCard = nil
	_DragginOverFrame = nil
	_YourTurn = false
	_EnemyPassed = false

	_GwentPlayFrame.playerTurn:Hide()
	
	_GwentPlayFrame.enemyNametag:SetText("")
	_GwentPlayFrame.enemyTurn:Hide()
	
	_GwentPlayFrame.playerTotal.amount = 0
	_GwentPlayFrame.enemyTotal.amount = 0
	
end

local function FinishBattle() 
	local playerWon = false
	
	if _GwentPlayFrame.playerTotal.amount == _GwentPlayFrame.enemyTotal.amount then 
		SendAddonMessage(addonName, MESSAGE_TIE, "whisper" , _ChallengerName)
		return
	end
	
	if _GwentPlayFrame.playerTotal.amount > _GwentPlayFrame.enemyTotal.amount then
		playerWon = true
	end

	SendAddonMessage(addonName, MESSAGE_WON.. (playerWon and "false" or "true"), "whisper" , _ChallengerName)
	
	ResetGame()
end

local L_FPS_LoadFrame = CreateFrame("FRAME", "Gwent_EventFrame"); 
Gwent_EventFrame:RegisterEvent("ADDON_LOADED");
Gwent_EventFrame:RegisterEvent("CHAT_MSG_ADDON");
Gwent_EventFrame:RegisterEvent("PLAYER_LOGOUT");
Gwent_EventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Gwent_EventFrame:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= addonName then
		return
	end
	
	--GwentAddon:DEBUGMessageSent(message, sender)
	
	if message == TEXT_ADDONMSG_RECIEVED then
		return
	end
	
	if message == MESSAGE_CHALLENGE then
		ChangeChallenger(sender)
	end
	
	if message == MESSAGE_LOGOUT then
		
		ResetGame()
	end
	
	if message == MESSAGE_PASS then
		IsYourTurn(true)
		_EnemyPassed = true
		
		if _PlayerPassed then
			FinishBattle()
		end
	end
	
	-- Enemy played card
	if string.find(message, "#") then
		AddEnemyCard(message)
		IsYourTurn(true)
	end
	
	if string.find(message, MESSAGE_WON) then
		ResetGame()
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

function Gwent_EventFrame:PLAYER_LOGOUT(ADDON_LOADED)
	--if ADDON_LOADED ~= addonName then return end
	
	SendAddonMessage(addonName, MESSAGE_LOGOUT, "whisper" , _ChallengerName)

end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'debug' then

		GwentAddon:DEBUGToggleFrame()
		
	elseif msg == 'test' then
		
		print(_GwentPlayFrame.enemyPortrait:GetTexture())
	
	elseif msg == 'duel' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, ""..MESSAGE_CHALLENGE , "whisper" , name)
		ChangeChallenger(name)
		IsYourTurn(true)
		
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
	elseif msg == 'log' then
		SendAddonMessage(addonName, MESSAGE_LOGOUT, "whisper" , _ChallengerName)
	else
	
	
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd