local addonName, GwentAddon = ...
local AceGUI = LibStub("AceGUI-3.0")

-- local GwentAddon.NUM_CARD_HEIGHT = 72
-- local GwentAddon.NUM_CARD_WIDTH = 40
GwentAddon.NUM_CARD_HEIGHT = 79
GwentAddon.NUM_CARD_WIDTH = 49
local NUM_SIZE_ICON = 64
local NUM_BORDERSIZE_TOTAL = 100
local NUM_ICON_OPACITY = 0.1
local NUM_VERTEXCOLOR_NORMAL = 1
local NUM_VERTEXCOLOR_NORMAL = 0

local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_CARD_DARKEN = "Interface\\DialogFrame\\UI-DialogBox-Background"
local TEXTURE_CARD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
--local TEXTURE_CARD_ICONBG = "Interface\\COMMON\\Indicator-Gray"
local TEXTURE_CARD_ICONBG2 = "Interface\\COMMON\\Indicator-Yellow" 
local TEXTURE_CARD_ICONBG = "Interface\\FriendsFrame\\UI-Toast-ToastIcons" 
local TEXTURE_ICONS = {["path"]="Interface\\GUILDFRAME\\GUILDEMBLEMSLG_01", ["width"]=1024, ["height"]=1024}
local TEXTURE_TOTAL_BORDERNORMAL = "Interface\\UNITPOWERBARALT\\MetalPlain_Circular_Frame"
local TEXTURE_TOTAL_BORDERWINNING = "Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame"
local TEXTURE_ARROWDOWN = "Interface\\ICONS\\misc_arrowdown"
local TEXTURE_ARROWUP = "Interface\\ICONS\\misc_arrowlup"
local TEXTURE_CUSTOM_PATH = "Interface\\AddOns\\Gwent\\CardTextures\\"
local TEXTURE_PORTAITDEFAULT = "Interface\\CHARACTERFRAME\\TemporaryPortrait-Vehicle-Organic"
local TEXTURE_LIFECRYSTAL = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73"
local TEXTURE_TYPE_AGILE = TEXTURE_CUSTOM_PATH.."TypeAgile"
local TEXTURE_TYPE_MELEE = TEXTURE_CUSTOM_PATH.."TypeMelee"
local TEXTURE_TYPE_RANGED = TEXTURE_CUSTOM_PATH.."TypeRanged"
local TEXTURE_TYPE_SIEGE = TEXTURE_CUSTOM_PATH.."TypeSiege"
local TEXTURE_ABILITY_COMMANDER = TEXTURE_CUSTOM_PATH.."AbilityCommander"

local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local COORDS_ICON_RANGED = {["x"]=64*15, ["y"]=64*1}
local COORDS_ICON_SIEGE = {["x"]=64*3, ["y"]=64*7}
local COORDS_SMALLCARD = {["left"]=76/256, ["right"]=244/256, ["top"]=30/512, ["bottom"]=300/512}

GwentAddon.messages = {["placeInArea"] = "%s#%d"
						,["challenge"] = "It's time to du-du-du-duel"
						,["logout"] = "logged out"
						,["pass"] = "passing"
						,["won"] = "win: "
						,["tie"] = "tie"
						,["discarded"] = "Done discarding"}

	local TEXT_SIEGE = "siege"
	local TEXT_RANGED = "ranged"
	local TEXT_MELEE = "melee"

local _CardPool = {}

GwentAddon.challengerName = nil
--local GwentAddon.playFrame = {}
GwentAddon.lists = {["player"] = {["hand"] = {}
								,["siege"] = {}
								,["ranged"] = {}
								,["melee"] = {}
								,["deck"] = {}}
					,["enemy"] = {["hand"] = {}
								,["siege"] = {}
								,["ranged"] = {}
								,["melee"] = {}}
								}

--local _PlayerGraveyard = {}
local _DraggedCard = nil
local _DragginOverFrame = nil
local _CardNr = 1


GwentAddon.currentState = 0
GwentAddon.states = {["noGame"] = 0
					,["playerDiscard"] = 1
					,["round"] = 2
					,["betweenRounds"] = 3
					,["waitEnemyDiscard"] = 4
					,["enemyDoneDiscarding"] = 5} 
					
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

function GwentAddon:GetStateName(state)
	for name, nr in pairs(GwentAddon.states) do
		if nr == state then
			return name
		end
	end
	return "Unknown"
end

function GwentAddon:IsYourTurn(bool)
	_YourTurn = bool
	
	for k, card in ipairs(GwentAddon.lists.player.hand) do
		card:SetMovable(bool)
		--card:EnableMouse(bool)
	end
	
	GwentAddon.playFrame.playerTurn:Hide()
	GwentAddon.playFrame.enemyTurn:Hide()
	
	if _YourTurn then
		GwentAddon.playFrame.playerTurn:Show()
	else
		GwentAddon.playFrame.enemyTurn:Show()
	end
end

local function PassTurn()
	if _YourTurn then
		_PlayerPassed = true
		GwentAddon.playFrame.passButton:Disable()
		SendAddonMessage(addonName, GwentAddon.messages.pass , "whisper" , GwentAddon.challengerName)
		GwentAddon:IsYourTurn(false)
	end
end

function GwentAddon:PlayerPlaceCardsOnFrame(list, frame)
	local totalPoints = 0

	for k, card in ipairs(list) do
		card:ClearAllPoints()
		card:SetPoint("topleft", frame , "topleft", (k-1)*GwentAddon.NUM_CARD_WIDTH, 0)
		card:SetWidth(GwentAddon.NUM_CARD_WIDTH)
		card:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
		
		totalPoints = totalPoints + card.data.strength
	end
	
	if frame.points ~= nil then
		frame.points:SetText(totalPoints)
		return totalPoints
	end
end

function GwentAddon:UpdateTotalBorders(playerPoints, enemyPoints)
	GwentAddon.playFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	GwentAddon.playFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	
	if playerPoints > enemyPoints  then
		GwentAddon.playFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
	elseif enemyPoints > playerPoints then
		GwentAddon.playFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
	end
	
end

function GwentAddon:UpdateTotalPoints(playerPoints, enemyPoints)
	GwentAddon.playFrame.playerTotal.points:SetText(playerPoints)
	GwentAddon.playFrame.playerTotal.amount = playerPoints
	GwentAddon.playFrame.enemyTotal.points:SetText(enemyPoints)
	GwentAddon.playFrame.enemyTotal.amount = enemyPoints
end



function GwentAddon:DestroyCardsInList(list)
	for k, card in pairs(list) do
		table.insert(_CardPool, card)
		card:Hide()
		list[k] = nil
	end
	
	list = {}
end

function GwentAddon:SetCardTooltip(card)
	local tp = GwentAddon.playFrame.cardTooltip
	
	local vcBG = 1
	local vc = 0
	if card.data.cardType.hero then
		vcBG = 0
		vc = 1
	end
	
	tp:Show()
	tp.typeBG:Hide()
	tp.type:Hide()
	tp.abilityBG:Hide()
	tp.ability:Hide()
	
	tp.strengthBG:SetVertexColor(vcBG, vcBG, vcBG, .75)
	tp.abilityBG:SetVertexColor(vcBG, vcBG, vcBG, .75)
	tp.typeBG:SetVertexColor(vcBG, vcBG, vcBG, .75)
	tp.type:SetVertexColor(vc, vc, vc)
	tp.strength:SetTextColor(vc, vc, vc)
	--tp.texture:SetTexture(TEXTURE_CUSTOM_PATH..card.data.texture)
	
	
	
	local typeIcon = GwentAddon.cards:GetTypeIcon(card)
	if typeIcon ~= nil then
		tp.type:SetTexture(typeIcon)
		tp.typeBG:Show()
		tp.type:Show()
	end
	
	local ability = GwentAddon:GetAbilitydataByName(card.data.ability)
	if ability ~= nil then
		tp.abilityBG:Show()
		tp.ability:Show()
		tp.ability:SetVertexColor(vc, vc, vc)
		tp.ability:SetTexture(ability.texture)
		tp.ability:SetTexCoord(ability.coords.left, ability.coords.right, ability.coords.top, ability.coords.bottom)
	end
	
	
	
	
	tp.name:SetText(card.data.name)
	tp.faction:SetText(card.data.faction)
	tp.strength:SetText(card.data.strength)
end

local function CreateCardArea(name, parent, texture)
	local frame = CreateFrame("frame", addonName.."PlayFrame_" .. name, parent)
	frame:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	 
	frame.commander = CreateFrame("frame", addonName.."PlayFrame_" .. name .."_Commander", parent)
	frame.commander:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander:SetWidth(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander:SetPoint("right", frame, "left", -5, 0)
	frame.commander:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	 
	frame.commander.icon = frame.commander:CreateTexture(addonName.."PlayFrame_"..name.."_ICONCOMMANDER", "art")
	frame.commander.icon:SetTexture(TEXTURE_ABILITY_COMMANDER)
	--frame.commander.icon:SetTexCoord(coords.x/TEXTURE_ICONS.width, (coords.x+NUM_SIZE_ICON)/TEXTURE_ICONS.width, coords.y/TEXTURE_ICONS.height, (coords.y+NUM_SIZE_ICON)/TEXTURE_ICONS.height)
	frame.commander.icon:SetVertexColor(1, 1, 1, NUM_ICON_OPACITY)
	frame.commander.icon:SetWidth(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander.icon:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander.icon:SetPoint("center", frame.commander)
	  
	frame.points = frame:CreateFontString(nil, nil, "GameFontNormal")
	frame.points:SetPoint("right", frame.commander, "left", -20, 0)
	frame.points:SetText(0)
	
	
	
	frame.icon = frame:CreateTexture(addonName.."PlayFrame_"..name.."_ICON", "art")
	frame.icon:SetTexture(texture)
	frame.icon:SetTexCoord(0, 1, 0, 1)

	
	
	frame.icon:SetVertexColor(1, 1, 1, NUM_ICON_OPACITY)
	frame.icon:SetWidth(GwentAddon.NUM_CARD_HEIGHT)
	frame.icon:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame.icon:SetPoint("center", frame)
	
	return frame
end

local function CreateCardTooltip(parent)
	parent.cardTooltip = CreateFrame("frame", addonName.."parent_CardTooltip", parent)
	parent.cardTooltip:SetPoint("right", parent, "right", -50, 0)
	parent.cardTooltip:SetHeight(GwentAddon.NUM_CARD_HEIGHT*4)
	parent.cardTooltip:SetWidth(GwentAddon.NUM_CARD_WIDTH * 4)
	parent.cardTooltip:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = TEXTURE_CARD_BORDER,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 }
	  })
	parent.cardTooltip:Hide()
	
	-- parent.cardTooltip.texture = parent.cardTooltip:CreateTexture(addonName.."_Card_".._CardNr.."_Texture", "ARTWORK")
	-- parent.cardTooltip.texture:SetDrawLayer("ARTWORK", 0)
	-- parent.cardTooltip.texture:SetTexCoord(0, 1, 0, 464/512)
	-- parent.cardTooltip.texture:SetPoint("topleft", parent.cardTooltip, 2, -2)
	-- parent.cardTooltip.texture:SetPoint("bottomright", parent.cardTooltip, -2, 2)
	  
	parent.cardTooltip.strengthBG = parent.cardTooltip:CreateTexture(addonName.."parent_CardTooltip_StrengthBG", "ARTWORK")
	parent.cardTooltip.strengthBG:SetDrawLayer("ARTWORK", 1)
	parent.cardTooltip.strengthBG:SetTexture(TEXTURE_CARD_ICONBG)
	parent.cardTooltip.strengthBG:SetVertexColor(0, 0, 0, .75)
	parent.cardTooltip.strengthBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	parent.cardTooltip.strengthBG:SetPoint("topleft", parent.cardTooltip, "topleft", 10, -7)
	parent.cardTooltip.strengthBG:SetHeight(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.strengthBG:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	
	parent.cardTooltip.strength = parent.cardTooltip:CreateFontString(nil, nil, "GameFontNormalLarge")
	parent.cardTooltip.strength:SetPoint("topleft", parent.cardTooltip.strengthBG)
	parent.cardTooltip.strength:SetPoint("bottomright", parent.cardTooltip.strengthBG)
	parent.cardTooltip.strength:SetJustifyH("center")
	parent.cardTooltip.strength:SetJustifyV("middle")
	parent.cardTooltip.strength:SetTextColor(1,1,1)
	parent.cardTooltip.strength:SetText("10")
	
	parent.cardTooltip.typeBG = parent.cardTooltip:CreateTexture(addonName.."parent_CardTooltip_TypeBG", "ARTWORK")
	parent.cardTooltip.typeBG:SetDrawLayer("ARTWORK", 1)
	parent.cardTooltip.typeBG:SetTexture(TEXTURE_CARD_ICONBG)
	parent.cardTooltip.typeBG:SetVertexColor(0, 0, 0, .75)
	parent.cardTooltip.typeBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	parent.cardTooltip.typeBG:SetPoint("top", parent.cardTooltip.strengthBG, "bottom", 0, -25)
	parent.cardTooltip.typeBG:SetHeight(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.typeBG:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	
	parent.cardTooltip.type = parent.cardTooltip:CreateTexture(addonName.."parent_CardTooltip_Type", "ARTWORK")
	parent.cardTooltip.type:SetDrawLayer("ARTWORK", 2)
	parent.cardTooltip.type:SetPoint("center", parent.cardTooltip.typeBG)
	parent.cardTooltip.type:SetHeight(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.type:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.type:SetVertexColor(1, 1, 1)
	
	parent.cardTooltip.abilityBG = parent.cardTooltip:CreateTexture(addonName.."parent_CardTooltip_AbilityBG", "ARTWORK")
	parent.cardTooltip.abilityBG:SetDrawLayer("ARTWORK", 1)
	parent.cardTooltip.abilityBG:SetTexture(TEXTURE_CARD_ICONBG)
	parent.cardTooltip.abilityBG:SetVertexColor(0, 0, 0, .75)
	parent.cardTooltip.abilityBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	parent.cardTooltip.abilityBG:SetPoint("top", parent.cardTooltip.typeBG, "bottom", 0, -5)
	parent.cardTooltip.abilityBG:SetHeight(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.abilityBG:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	
	parent.cardTooltip.ability = parent.cardTooltip:CreateTexture(addonName.."parent_CardTooltip_Ability", "ARTWORK")
	parent.cardTooltip.ability:SetDrawLayer("ARTWORK", 2)
	parent.cardTooltip.ability:SetPoint("center", parent.cardTooltip.abilityBG)
	parent.cardTooltip.ability:SetHeight(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.ability:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	parent.cardTooltip.ability:SetVertexColor(1, 1, 1)
	
	parent.cardTooltip.name = parent.cardTooltip:CreateFontString(nil, nil, "GameFontNormal")
	--parent.cardTooltip.name:SetPoint("topleft", parent.cardTooltip, 10, -5)
	parent.cardTooltip.name:SetPoint("bottom", parent.cardTooltip, "bottom", 0 , 70)
	parent.cardTooltip.name:SetWidth(parent.cardTooltip:GetWidth()-10)
	parent.cardTooltip.name:SetJustifyH("center")
	parent.cardTooltip.name:SetJustifyV("middle")
	parent.cardTooltip.name:SetTextColor(1,1,1)
	parent.cardTooltip.name:SetWordWrap(false)
	parent.cardTooltip.name:SetText("name")
	
	parent.cardTooltip.faction = parent.cardTooltip:CreateFontString(nil, nil, "GameFontNormal")
	--parent.cardTooltip.name:SetPoint("topleft", parent.cardTooltip, 10, -5)
	parent.cardTooltip.faction:SetPoint("top", parent.cardTooltip.name, "bottom", 0 , -5)
	parent.cardTooltip.faction:SetWidth(parent.cardTooltip:GetWidth()-10)
	parent.cardTooltip.faction:SetJustifyH("center")
	parent.cardTooltip.faction:SetJustifyV("middle")
	parent.cardTooltip.faction:SetTextColor(1,1,1)
	parent.cardTooltip.faction:SetWordWrap(false)
	parent.cardTooltip.faction:SetText("deck")
end

local function CreateWeatherArea(PlayFrame)
	PlayFrame.weatherArea = CreateFrame("frame", PlayFrame:GetName() .. "_WeatherArea", PlayFrame)
	PlayFrame.weatherArea:SetPoint("left", PlayFrame, "left", 50, 0)
	PlayFrame.weatherArea:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.weatherArea:SetWidth(GwentAddon.NUM_CARD_WIDTH * 3)
	PlayFrame.weatherArea:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
end

local function CreatePlayFrame()
	
	local PlayFrame = CreateFrame("frame", addonName.."PlayFrame", UIParent)
	PlayFrame:SetHeight(780)
	PlayFrame:SetWidth(1200)
	PlayFrame:SetMovable(true)
	PlayFrame:SetPoint("Center", 0, 0)
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

	CreateCardTooltip(PlayFrame)
	CreateWeatherArea(PlayFrame)
	
	-- player hand
	PlayFrame.playerHand = CreateFrame("frame", addonName.."PlayFrameGwentAddon.lists.player.hand", PlayFrame)
	PlayFrame.playerHand:SetPoint("bottom", PlayFrame, "bottom", 0, 23)
	PlayFrame.playerHand:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.playerHand:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	PlayFrame.playerHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	-- player siege
	PlayFrame.playerSiege = CreateCardArea("PlayerRanged", PlayFrame, TEXTURE_TYPE_SIEGE)
	PlayFrame.playerSiege:SetPoint("bottom", PlayFrame.playerHand, "top", 0, 20) 
	-- player ranged
	PlayFrame.playerRanged = CreateCardArea("PlayerRanged", PlayFrame, TEXTURE_TYPE_RANGED)
	PlayFrame.playerRanged:SetPoint("bottom", PlayFrame.playerSiege, "top", 0, 10)  
	-- player melee
	PlayFrame.playerMelee = CreateCardArea("PlayerMelee", PlayFrame, TEXTURE_TYPE_MELEE)
	PlayFrame.playerMelee:SetPoint("bottom", PlayFrame.playerRanged, "top", 0, 10)
	
	PlayFrame.playerDetails = CreateFrame("frame", PlayFrame:GetName() .. "_PlayerDetails", PlayFrame)
	PlayFrame.playerDetails:SetPoint("left", PlayFrame, "left", 10, -GwentAddon.NUM_CARD_HEIGHT *2)
	PlayFrame.playerDetails:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.playerDetails:SetWidth(GwentAddon.NUM_CARD_WIDTH * 4)
	PlayFrame.playerDetailsBG = PlayFrame.playerDetails:CreateTexture(addonName.."PlayFrame_PlayerDetailsBG", "BACKGROUND")
	--PlayFrame.playerDetailsBG:SetDrawLayer("BACKGROUND", -1)
	PlayFrame.playerDetailsBG:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Background")
	PlayFrame.playerDetailsBG:SetPoint("topleft", PlayFrame.playerDetails)
	PlayFrame.playerDetailsBG:SetPoint("bottomright", PlayFrame.playerDetails)
	
	-- player total Points
	PlayFrame.playerTotal = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerTotal", "ARTWORK")
	PlayFrame.playerTotal:SetDrawLayer("ARTWORK", 0)
	PlayFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.playerTotal:SetWidth(NUM_BORDERSIZE_TOTAL)
	PlayFrame.playerTotal:SetHeight(NUM_BORDERSIZE_TOTAL)
	PlayFrame.playerTotal:SetPoint("bottomright", PlayFrame.playerDetails, "topright", 10, -10)
	
	PlayFrame.playerTotal.points = PlayFrame:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	PlayFrame.playerTotal.points:SetPoint("topleft", PlayFrame.playerTotal)
	PlayFrame.playerTotal.points:SetPoint("bottomright", PlayFrame.playerTotal)
	PlayFrame.playerTotal.points:SetText(0)

	-- player portrait
	PlayFrame.playerPortrait = PlayFrame.playerDetails:CreateTexture(addonName.."PlayFrame_PlayerPortrait", "ARTWORK")
	PlayFrame.playerPortrait:SetDrawLayer("ARTWORK", 0)
	PlayFrame.playerPortrait:SetWidth(GwentAddon.NUM_CARD_HEIGHT-10)
	PlayFrame.playerPortrait:SetHeight(GwentAddon.NUM_CARD_HEIGHT-10)
	PlayFrame.playerPortrait:SetPoint("left", PlayFrame.playerDetails, "left", 10, 0)
	
	SetPortraitTexture(PlayFrame.playerPortrait, "player")
	
	PlayFrame.playerPortraitborder = PlayFrame.playerDetails:CreateTexture(addonName.."PlayFrame_PlayerPortraitBorder", "ARTWORK")
	PlayFrame.playerPortraitborder:SetDrawLayer("ARTWORK", 1)
	PlayFrame.playerPortraitborder:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.playerPortraitborder:SetWidth(GwentAddon.NUM_CARD_HEIGHT+50)
	PlayFrame.playerPortraitborder:SetHeight(GwentAddon.NUM_CARD_HEIGHT+50)
	PlayFrame.playerPortraitborder:SetPoint("center", PlayFrame.playerPortrait)
	
	-- player nametag
	PlayFrame.playerNametag = PlayFrame.playerDetails:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.playerNametag:SetPoint("left", PlayFrame.playerPortrait, "right", 10, -5)
	PlayFrame.playerNametag:SetPoint("right", PlayFrame.playerDetails, "right", -10, -5)
	PlayFrame.playerNametag:SetJustifyH("left")
	PlayFrame.playerNametag:SetText(GetUnitName("player", false))
	
	-- player deck
	PlayFrame.playerFaction = PlayFrame.playerDetails:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.playerFaction:SetPoint("topleft", PlayFrame.playerNametag, "bottomleft", 0, 0)
	PlayFrame.playerFaction:SetPoint("topright", PlayFrame.playerNametag, "bottomright", 0, 0)
	PlayFrame.playerFaction:SetJustifyH("left")
	PlayFrame.playerFaction:SetText("Faction here")
	
	-- player life 2
	PlayFrame.playerLife2 = PlayFrame.playerDetails:CreateTexture(addonName.."PlayFrame_PlayerLife2", "ARTWORK")
	PlayFrame.playerLife2:SetDrawLayer("ARTWORK", 1)
	PlayFrame.playerLife2:SetTexture(TEXTURE_LIFECRYSTAL)
	PlayFrame.playerLife2:SetVertexColor(0.8, 0.1, 0.1)
	PlayFrame.playerLife2:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.playerLife2:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.playerLife2:SetPoint("topright", PlayFrame.playerDetails)
	
	PlayFrame.playerLife1 = PlayFrame.playerDetails:CreateTexture(addonName.."PlayFrame_PlayerLife1", "ARTWORK")
	PlayFrame.playerLife1:SetDrawLayer("ARTWORK", 1)
	PlayFrame.playerLife1:SetTexture(TEXTURE_LIFECRYSTAL)
	PlayFrame.playerLife1:SetVertexColor(0.8, 0.1, 0.1)
	PlayFrame.playerLife1:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.playerLife1:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.playerLife1:SetPoint("right", PlayFrame.playerLife2, "left")
	
	-- player turn arrow
	PlayFrame.playerTurn = PlayFrame:CreateTexture(addonName.."PlayFrame_PlayerTurn", "ARTWORK")
	PlayFrame.playerTurn:SetDrawLayer("ARTWORK", -7)
	PlayFrame.playerTurn:SetTexture(TEXTURE_ARROWDOWN)
	PlayFrame.playerTurn:SetWidth(NUM_SIZE_ICON)
	PlayFrame.playerTurn:SetHeight(NUM_SIZE_ICON)
	PlayFrame.playerTurn:SetPoint("right", PlayFrame.playerSiege.commander, "left", -75, 0)
	PlayFrame.playerTurn:Hide()
	
	-- player pass button
	PlayFrame.passButton = CreateFrame("button", addonName.."PlayFrame_PassButton", PlayFrame, "UIPanelButtonTemplate")
	PlayFrame.passButton:SetPoint("bottomleft", PlayFrame.playerDetails, "topleft", 5, 10)
	PlayFrame.passButton:SetSize(100, 25)
	PlayFrame.passButton:SetText("Pass")
	PlayFrame.passButton:SetScript("OnClick", PassTurn)	
	
	-- player discard button
	PlayFrame.discardButton = CreateFrame("button", addonName.."PlayFrame_DiscardButton", PlayFrame, "UIPanelButtonTemplate")
	PlayFrame.discardButton:SetPoint("bottomleft", PlayFrame.playerHand, "bottomright", 15, 10)
	PlayFrame.discardButton:SetSize(100, 25)
	PlayFrame.discardButton:SetText("Discard")
	PlayFrame.discardButton:SetScript("OnClick", function() GwentAddon.cards:DiscardSelectedCards() end)	
	PlayFrame.discardButton:Hide()
	
	
	
	-- enemy hand
	PlayFrame.enemyHand = CreateFrame("frame", addonName.."PlayFrame_EnemyHand", PlayFrame)
	PlayFrame.enemyHand:SetPoint("top", PlayFrame, "top", 0, -30)
	PlayFrame.enemyHand:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemyHand:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	PlayFrame.enemyHand:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	  
	-- enemy siege
	PlayFrame.enemySiege = CreateCardArea("EnemyRanged", PlayFrame, TEXTURE_TYPE_SIEGE)
	PlayFrame.enemySiege:SetPoint("top", PlayFrame.enemyHand, "bottom", 0, -20) 
	-- enemy ranged
	PlayFrame.enemyRanged = CreateCardArea("EnemyRanged", PlayFrame, TEXTURE_TYPE_RANGED)
	PlayFrame.enemyRanged:SetPoint("top", PlayFrame.enemySiege, "bottom", 0, -10)  
	-- enemy melee
	PlayFrame.enemyMelee = CreateCardArea("EnemyMelee", PlayFrame, TEXTURE_TYPE_MELEE)
	PlayFrame.enemyMelee:SetPoint("top", PlayFrame.enemyRanged, "bottom", 0, -10)
	
	PlayFrame.enemyDetails = CreateFrame("frame", PlayFrame:GetName() .. "_EnemyDetails", PlayFrame)
	PlayFrame.enemyDetails:SetPoint("left", PlayFrame, "left", 10, GwentAddon.NUM_CARD_HEIGHT *2)
	PlayFrame.enemyDetails:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemyDetails:SetWidth(GwentAddon.NUM_CARD_WIDTH * 4)
	PlayFrame.enemyDetailsBG = PlayFrame.enemyDetails:CreateTexture(addonName.."PlayFrame_PlayerDetailsBG", "BACKGROUND")
	--PlayFrame.playerDetailsBG:SetDrawLayer("BACKGROUND", -1)
	PlayFrame.enemyDetailsBG:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Background")
	PlayFrame.enemyDetailsBG:SetPoint("topleft", PlayFrame.enemyDetails)
	PlayFrame.enemyDetailsBG:SetPoint("bottomright", PlayFrame.enemyDetails)
	
	-- player total Points
	PlayFrame.enemyTotal = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyTotal", "ARTWORK")
	PlayFrame.enemyTotal:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.enemyTotal:SetWidth(NUM_BORDERSIZE_TOTAL)
	PlayFrame.enemyTotal:SetHeight(NUM_BORDERSIZE_TOTAL)
	PlayFrame.enemyTotal:SetPoint("topright", PlayFrame.enemyDetails, "bottomright", 10, 10)
	
	PlayFrame.enemyTotal.points = PlayFrame:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	PlayFrame.enemyTotal.points:SetPoint("topleft", PlayFrame.enemyTotal)
	PlayFrame.enemyTotal.points:SetPoint("bottomright", PlayFrame.enemyTotal)
	PlayFrame.enemyTotal.points:SetText(0)
	
	-- player portrait
	PlayFrame.enemyPortrait = PlayFrame.enemyDetails:CreateTexture(addonName.."PlayFrame_EnemyPortrait", "art")
	PlayFrame.enemyPortrait:SetDrawLayer("ARTWORK", 0)
	PlayFrame.enemyPortrait:SetTexture(TEXTURE_PORTAITDEFAULT)
	PlayFrame.enemyPortrait:SetWidth(GwentAddon.NUM_CARD_HEIGHT-10)
	PlayFrame.enemyPortrait:SetHeight(GwentAddon.NUM_CARD_HEIGHT-10)
	PlayFrame.enemyPortrait:SetPoint("left", PlayFrame.enemyDetails, "left", 10, 0)
	--SetPortraitTexture(PlayFrame.playerPortrait, "player")
	
	PlayFrame.enemyPortraitborder = PlayFrame.enemyDetails:CreateTexture(addonName.."PlayFrame_EnemyPortraitBorder", "ARTWORK")
	PlayFrame.enemyPortraitborder:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyPortraitborder:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	PlayFrame.enemyPortraitborder:SetWidth(GwentAddon.NUM_CARD_HEIGHT+50)
	PlayFrame.enemyPortraitborder:SetHeight(GwentAddon.NUM_CARD_HEIGHT+50)
	PlayFrame.enemyPortraitborder:SetPoint("center", PlayFrame.enemyPortrait)
	
	-- enemy nametag
	PlayFrame.enemyNametag = PlayFrame.enemyDetails:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.enemyNametag:SetPoint("left", PlayFrame.enemyPortrait, "right", 10, -10)
	PlayFrame.enemyNametag:SetPoint("right", PlayFrame.enemyDetails, "right", -10, -10)
	PlayFrame.enemyNametag:SetJustifyH("left")
	PlayFrame.enemyNametag:SetWordWrap(false)
	PlayFrame.enemyNametag:SetText("Enemy name")
	
	-- enemy deck
	PlayFrame.enemyFaction = PlayFrame.enemyDetails:CreateFontString(nil, nil, "GameFontNormal")
	PlayFrame.enemyFaction:SetPoint("topleft", PlayFrame.enemyNametag, "bottomleft", 0, 0)
	PlayFrame.enemyFaction:SetPoint("topright", PlayFrame.enemyNametag, "bottomright", 0, 0)
	PlayFrame.enemyFaction:SetJustifyH("left")
	PlayFrame.enemyFaction:SetText("Enemy faction")
	
	-- enemy life 2
	PlayFrame.enemyLife2 = PlayFrame.enemyDetails:CreateTexture(addonName.."PlayFrame_EnemyLife2", "ARTWORK")
	PlayFrame.enemyLife2:SetDrawLayer("ARTWORK", 1)
	PlayFrame.enemyLife2:SetTexture(TEXTURE_LIFECRYSTAL)
	PlayFrame.enemyLife2:SetVertexColor(0.8, 0.1, 0.1)
	PlayFrame.enemyLife2:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.enemyLife2:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.enemyLife2:SetPoint("topright", PlayFrame.enemyDetails)
	
	PlayFrame.enemyLife1 = PlayFrame.enemyDetails:CreateTexture(addonName.."PlayFrame_EnemyLife1", "ARTWORK")
	PlayFrame.enemyLife1:SetDrawLayer("ARTWORK", 1)
	PlayFrame.enemyLife1:SetTexture(TEXTURE_LIFECRYSTAL)
	PlayFrame.enemyLife1:SetVertexColor(0.8, 0.1, 0.1)
	PlayFrame.enemyLife1:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.enemyLife1:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	PlayFrame.enemyLife1:SetPoint("right", PlayFrame.enemyLife2, "left")
	
	-- player turn arrow
	PlayFrame.enemyTurn = PlayFrame:CreateTexture(addonName.."PlayFrame_EnemyTurn", "ARTWORK")
	PlayFrame.enemyTurn:SetDrawLayer("ARTWORK", -7)
	PlayFrame.enemyTurn:SetTexture(TEXTURE_ARROWUP)
	PlayFrame.enemyTurn:SetWidth(NUM_SIZE_ICON)
	PlayFrame.enemyTurn:SetHeight(NUM_SIZE_ICON)
	PlayFrame.enemyTurn:SetPoint("right", PlayFrame.enemySiege.commander, "left", -75, 0)
	PlayFrame.enemyTurn:Hide()
	
	
	return PlayFrame
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

function GwentAddon:DropCardArea(card)
	if DroppingCardOnFrame(GwentAddon.playFrame.playerSiege) and IsRightTypeForArea(card, TEXT_SIEGE) then
		
		GwentAddon.cards:AddCardToNewList(card, GwentAddon.lists.player.siege)
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_SIEGE
	elseif DroppingCardOnFrame(GwentAddon.playFrame.playerRanged) and IsRightTypeForArea(card, TEXT_RANGED) then
		
		GwentAddon.cards:AddCardToNewList(card, GwentAddon.lists.player.ranged)
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_RANGED
	elseif DroppingCardOnFrame(GwentAddon.playFrame.playerMelee) and IsRightTypeForArea(card, TEXT_MELEE) then
		
		GwentAddon.cards:AddCardToNewList(card, GwentAddon.lists.player.melee)
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_MELEE
	end
	return false
end



function GwentAddon:NumberInList(card, list)
	for k, v in ipairs(list) do
		if v.data.Id == card.data.Id then
			return k
		end
	end
	
	return -1
end



local function ChangeChallenger(sender)
	GwentAddon.challengerName = sender
	GwentAddon.playFrame.enemyNametag:SetText(GwentAddon.challengerName)
	for i=1,10 do
		GwentAddon.cards:DrawCard()
	end
	
	local challenger = GetUnitName("target", true)	
	if challenger ~= nil then
		SetPortraitTexture(GwentAddon.playFrame.enemyPortrait, "target")
		
	end
end



local function ResetGame() 
	GwentAddon.challengerName = nil
	GwentAddon:DestroyCardsInList(GwentAddon.lists.player.hand)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.player.siege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.player.ranged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.player.melee)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemy.siege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemy.ranged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemy.melee)
	GwentAddon.cards:PlaceAllCards()
	_DraggedCard = nil
	_DragginOverFrame = nil
	_YourTurn = false
	_EnemyPassed = false
	
	GwentAddon.currentState = GwentAddon.states.noGame

	GwentAddon.playFrame.playerTurn:Hide()
	
	GwentAddon.playFrame.enemyNametag:SetText("")
	GwentAddon.playFrame.enemyTurn:Hide()
	GwentAddon.playFrame.enemyPortrait:SetTexture(TEXTURE_PORTAITDEFAULT)
	GwentAddon.playFrame.playerTotal.amount = 0
	GwentAddon.playFrame.enemyTotal.amount = 0
	
end

local function FinishBattle() 
	local playerWon = false
	
	if GwentAddon.playFrame.playerTotal.amount == GwentAddon.playFrame.enemyTotal.amount then 
		SendAddonMessage(addonName, GwentAddon.messages.tie, "whisper" , GwentAddon.challengerName)
		return
	end
	
	if GwentAddon.playFrame.playerTotal.amount > GwentAddon.playFrame.enemyTotal.amount then
		playerWon = true
	end

	SendAddonMessage(addonName, GwentAddon.messages.won.. (playerWon and "false" or "true"), "whisper" , GwentAddon.challengerName)
	
	ResetGame()
end

function GwentAddon:ChangeState(state)
	GwentAddon.currentState = state
	GwentAddon.playFrame.discardButton:Hide()
	
	if GwentAddon.currentState == GwentAddon.states.playerDiscard or GwentAddon.currentState == GwentAddon.states.enemyDoneDiscarding then
		GwentAddon.playFrame.discardButton:Show()
	end
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
	
	if message == GwentAddon.messages.challenge then
		ChangeChallenger(sender)
		GwentAddon:ChangeState(GwentAddon.states.playerDiscard)
	end
	
	if message == GwentAddon.messages.logout then
		
		ResetGame()
	end
	
	if message == GwentAddon.messages.discarded then
		if GwentAddon.currentState == GwentAddon.states.waitEnemyDiscard then
			GwentAddon:ChangeState(GwentAddon.states.round)
		else
			GwentAddon:ChangeState(GwentAddon.states.enemyDoneDiscarding)
		end
	end
	
	if message == GwentAddon.messages.pass then
		GwentAddon:IsYourTurn(true)
		_EnemyPassed = true
		
		if _PlayerPassed then
			FinishBattle()
		end
	end
	
	-- Enemy played card
	if string.find(message, "#") then
		GwentAddon.cards:AddEnemyCard(message)
		GwentAddon:IsYourTurn(true)
	end
	
	if string.find(message, GwentAddon.messages.won) then
		ResetGame()
	end
	
end

function Gwent_EventFrame:ADDON_LOADED(ADDON_LOADED)
	if ADDON_LOADED ~= addonName then return end
	
	GwentAddon.playFrame = CreatePlayFrame()
	
	GwentAddon:CreateAbilitieList()
	GwentAddon:CreateCardsClass()
	--GwentAddon:CreateCardsList()
	GwentAddon.lists.player.deck = GwentAddon:CreateTestDeck()
	
	
	if not RegisterAddonMessagePrefix(addonName) then
		print(addonName ..": Could not register prefix.")
	end
end

function Gwent_EventFrame:PLAYER_LOGOUT(ADDON_LOADED)
	--if ADDON_LOADED ~= addonName then return end
	
	SendAddonMessage(addonName, GwentAddon.messages.logout, "whisper" , GwentAddon.challengerName)

end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'debug' then
	
		GwentAddon:DEBUGToggleFrame()
		
	elseif msg == 'test' then
		
		
		print(#class.list)
		--print(GwentAddon.cards.test)
	
	elseif msg == 'duel' then
		
		name = GetUnitName("target", true)
		
		if name == nil then
			return
		end
		
		SendAddonMessage(addonName, ""..GwentAddon.messages.challenge , "whisper" , name)
		ChangeChallenger(name)
		GwentAddon:IsYourTurn(true)
		GwentAddon:ChangeState(GwentAddon.states.playerDiscard)
		
		GwentAddon:DEBUGMessageSent("duelling "..GwentAddon.challengerName, GwentAddon.challengerName)
	
	elseif msg == 'toggle' then
	
	if GwentPlayFrame ~= nil then
		
		if GwentPlayFrame:IsShown() then
			GwentPlayFrame:Hide()
		else
			GwentPlayFrame:Show()
		end
	end
	
	elseif string.find(msg, "draw") then
		local nr = string.match(msg, "draw (%d+)")
		
		table.insert(GwentAddon.lists.player.hand, CreateCardOfId(nr))
		GwentAddon.cards:PlaceAllCards()
		
	elseif msg == 'log' then
		SendAddonMessage(addonName, GwentAddon.messages.logout, "whisper" , GwentAddon.challengerName)
	elseif msg == 'center' then
		print("centering")
		GwentAddon.playFrame:ClearAllPoints()
		GwentAddon.playFrame:SetPoint("center", UIParent)
		GwentAddon.playFrame:Show()
	else
	
		
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd




