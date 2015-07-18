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
local TEXTURE_SHADOW_CORNERS = "Interface\\BankFrame\\CornersShadow"
local TEXTURE_SHADOW_VERTICAL = "Interface\\BankFrame\\VertShadow"
local TEXTURE_SHADOW_HORIZONTAL = "Interface\\BankFrame\\HorizShadow"
local TEXTURE_WEATHER_RAIN = "Interface\\PETBATTLES\\Weather-Rain"
local TEXTURE_WEATHER_FOG = "Interface\\PETBATTLES\\Weather-Windy"
local TEXTURE_WEATHER_FROST = "Interface\\PETBATTLES\\Weather-Blizzard"

local COORDS_ICON_LIFE = {["x"]=64*7, ["y"]=64*11}
local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local COORDS_ICON_RANGED = {["x"]=64*15, ["y"]=64*1}
local COORDS_ICON_SIEGE = {["x"]=64*3, ["y"]=64*7}
local COORDS_SMALLCARD = {["left"]=76/256, ["right"]=244/256, ["top"]=30/512, ["bottom"]=300/512}

GwentAddon.messages = {["placeInArea"] = "#%s#%d#%d"
						,["challenge"] = "It's time to du du du duel"
						--,["challenge"] = "fuck"
						,["logout"] = "logged out"
						,["pass"] = "passing"
						,["roundWon"] = "round won: "
						,["roundTie"] = "round tied"
						,["battleWon"] = "battle won: "
						,["battleTie"] = "battle tied"
						,["discarded"] = "Done discarding"
						,["start"] = "start: "
						,["placeCard"] = "enemyCard"}

	local TEXT_SIEGE = "siege"
	local TEXT_RANGED = "ranged"
	local TEXT_MELEE = "melee"

local _CardPool = {}

GwentAddon.challengerName = nil
--local GwentAddon.playFrame = {}
GwentAddon.lists = {["playerHand"] = {}
					,["playerSiege"] = {}
					,["playerRanged"] = {}
					,["playerMelee"] = {}
					,["baseDeck"] = {}
					,["enemyHand"] = {}
					,["enemySiege"] = {}
					,["enemyRanged"] = {}
					,["enemyMelee"] = {}}
					
GwentAddon.areas = {["playerHand"] = {}
					,["playerSiege"] = {}
					,["playerRanged"] = {}
					,["playerMelee"] = {}
					,["baseDeck"] = {}
					,["enemyHand"] = {}
					,["enemySiege"] = {}
					,["enemyRanged"] = {}
					,["enemyMelee"] = {}}

--local _PlayerGraveyard = {}
local _DraggedCard = nil
local _DragginOverFrame = nil
local _CardNr = 1
local _baseDeck = {} -- basic deck, stores cards
local _GameDeck = {} -- deck used to play games with, starts as copy of baseDeck


GwentAddon.currentState = 0
GwentAddon.states = {["noGame"] = 0
					,["playerDiscard"] = 1
					,["playerTurn"] = 2
					,["enemyTurn"] = 3
					,["waitEnemyDiscard"] = 4
					,["enemyDoneDiscarding"] = 5
					,["determinStart"] = 6
					,["gameEnd"] = 7} 
					
GwentAddon.enemyPassed = false
GwentAddon.playerPassed = false
GwentAddon.playerLives = {["count"] = 2, ["texture1"] = nil, ["texture2"] = nil}
GwentAddon.enemyLives = {["count"] = 2, ["texture1"] = nil, ["texture2"] = nil}

GwentAddon.draggingOver = {}

GwentAddon.frameBaseLevel = 0

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

-- Get state number by name
function GwentAddon:GetStateName(state)
	for name, nr in pairs(GwentAddon.states) do
		if nr == state then
			return name
		end
	end
	return "Unknown"
end

local function PassTurn()
	if GwentAddon.currentState == GwentAddon.states.playerTurn then
		GwentAddon.playerPassed = true
		GwentAddon.playFrame.passButton:Disable()
		SendAddonMessage(addonName, GwentAddon.messages.pass , "whisper" , GwentAddon.challengerName)
		GwentAddon:ChangeState(GwentAddon.states.enemyTurn)
	end
end

-- Reduces a player's total lives by 1
function GwentAddon:DeductLife(lives)
	lives.count = lives.count - 1
	--lives.texture1:Show()
	--lives.texture2:Show()
	lives.texture1:SetVertexColor(0.8, 0.1, 0.1)
	lives.texture2:SetVertexColor(0.8, 0.1, 0.1)
	
	if lives.count < 2 then
		--lives.texture1:Hide()
		lives.texture1:SetVertexColor(0.5, 0.5, 0.5)
	end
	if lives.count < 1 then
		--lives.texture2:Hide()
		lives.texture2:SetVertexColor(0.5, 0.5, 0.5)
	end
end

-- Checks if either player has won or tie
-- Returns true if a player won
function GwentAddon:CheckBattleWinner()
	-- battle tied
	if GwentAddon.playerLives.count == 0 and GwentAddon.enemyLives.count == 0 then
		GwentAddon.popup:ShowButtonMessage("The battle tied.", "End game", function() GwentAddon:ResetGame() end)
		SendAddonMessage(addonName, GwentAddon.messages.battleTie, "whisper" , GwentAddon.challengerName)
		GwentAddon:ChangeState(GwentAddon.states.gameEnd)
		return true
	end
	
	-- player wins
	if GwentAddon.enemyLives.count == 0 then
		GwentAddon.popup:ShowButtonMessage("You won the battle.", "End game", function() GwentAddon:ResetGame() end)
		SendAddonMessage(addonName, GwentAddon.messages.battleWon.. "0", "whisper" , GwentAddon.challengerName)
		GwentAddon:ChangeState(GwentAddon.states.gameEnd)
		return true
	end
	
	-- enemy wins
	if GwentAddon.playerLives.count == 0 then
		GwentAddon.popup:ShowButtonMessage("You lost the battle.", "End game", function() GwentAddon:ResetGame() end)
		SendAddonMessage(addonName, GwentAddon.messages.battleWon.. "1", "whisper" , GwentAddon.challengerName)
		GwentAddon:ChangeState(GwentAddon.states.gameEnd)
		return true
	end
	
	return false
end    

-- Place all cards from a list on a frame
-- TODO: Change to require name
function GwentAddon:PlaceCardsOnFrame(list, frame)
	local totalPoints = 0
	
	local distance = 0
	frame.cardContainer:SetWidth(0)

	for k, card in ipairs(list) do
		card.frame:ClearAllPoints()
		
		-- reset spacing when not draggin a card around
		if GwentAddon.cards.draggedCard == nil then 
			card.leftSpacing = 0
			card.rightSpacing = 0
		end
		
		--(k-1)*GwentAddon.NUM_CARD_WIDTH
		
		if card.leftSpacing > 0 then distance = distance + card.leftSpacing end
		card.frame:SetPoint("left", frame.cardContainer , "left",distance , 0)
		if card.rightSpacing > 0 then distance = distance + card.rightSpacing end
		-- Change inset for mouseover
		card.frame:SetHitRectInsets(-card.leftSpacing, -card.rightSpacing, 0, 0)
		--print(card.frame:GetName(), card.frame:GetHitRectInsets())
		
		card.frame:SetWidth(GwentAddon.NUM_CARD_WIDTH)
		card.frame:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
		
		distance = distance + GwentAddon.NUM_CARD_WIDTH

		-- reset the strength
		card.data.calcStrength = card.data.strength
		card:UpdateCardStrength()
	end
	
	-- use abilities but not when it's the player's hand
	if list ~= GwentAddon.lists.playerHand then
		for k, card in ipairs(list) do
			if card.data.ability then
				print(k)
				card.data.ability.funct(card, list, k)
			end
		
		end
	end
	
	-- count row points
	for k, card in ipairs(list) do
		totalPoints = totalPoints + card.data.calcStrength
	end
	
	frame.cardContainer:SetWidth(distance)
	
	if frame.points ~= nil then
		frame.points:SetText(totalPoints)
		return totalPoints
	end
	
end

-- Updates to borders of player's total points depending on highest total
function GwentAddon:UpdateTotalBorders(playerPoints, enemyPoints)
	-- GwentAddon.playFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	-- GwentAddon.playFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	GwentAddon.playFrame.player.total.border:Hide()
	GwentAddon.playFrame.enemy.total.border:Hide()
	
	if playerPoints > enemyPoints  then
		-- GwentAddon.playFrame.playerTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
		GwentAddon.playFrame.player.total.border:Show()
	elseif enemyPoints > playerPoints then
		-- GwentAddon.playFrame.enemyTotal:SetTexture(TEXTURE_TOTAL_BORDERWINNING)
		GwentAddon.playFrame.enemy.total.border:Show()
	end
	
end

-- Update the total points for both players
function GwentAddon:UpdateTotalPoints(playerPoints, enemyPoints)
	GwentAddon.playFrame.player.total:SetText(playerPoints)
	GwentAddon.playFrame.player.Totalamount = playerPoints
	GwentAddon.playFrame.enemy.total:SetText(enemyPoints)
	GwentAddon.playFrame.enemy.Totalamount = enemyPoints
end

-- Places card frames in a list into the card pool, removing them from the game
function GwentAddon:DestroyCardsInList(list)
	for k, card in pairs(list) do
		table.insert(_CardPool, card.frame)
		card.frame:Hide()
		list[k] = nil
	end
	
	list = {}
end

-- Show the mouse over tooltip for a card
function GwentAddon:SetCardTooltip(card)
	local tp = GwentAddon.playFrame.cardTooltip
	
	local vcBG = 1
	local vc = 0
	if card.data.cardType.leader then
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
	tp.texture:SetTexture(TEXTURE_CUSTOM_PATH..card.data.texture)
	
	
	
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
	
	tp.strength:SetTextColor(0, 0, 0)
	if card.data.cardType.leader then
		tp.strength:SetTextColor(1, 1, 1)
	end
	
	tp.strength:SetText(card.data.calcStrength)
	
	if ( card.data.calcStrength > card.data.strength ) then -- buffed
		tp.strength:SetTextColor(0.2, 1, 0.2)
	elseif ( card.data.calcStrength < card.data.strength ) then -- nerfed
		tp.strength:SetTextColor(1, 0.7, 0.7)
	end
	
	
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
	
	parent.cardTooltip.texture = parent.cardTooltip:CreateTexture(addonName.."_Card_".._CardNr.."_Texture", "ARTWORK")
	parent.cardTooltip.texture:SetDrawLayer("ARTWORK", 0)
	parent.cardTooltip.texture:SetTexCoord(0, 1, 0, 464/512)
	parent.cardTooltip.texture:SetPoint("topleft", parent.cardTooltip, 2, -2)
	parent.cardTooltip.texture:SetPoint("bottomright", parent.cardTooltip, -2, 2)
	  
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

-- Get the list and area the mouse is currently hovering over
function GwentAddon:GetCardlistMouseOver()
	if GwentAddon:MouseIsOverFrame(GwentPlayFrame.playerSiege) then
		return GwentAddon.lists.playerSiege, GwentPlayFrame.playerSiege
	elseif GwentAddon:MouseIsOverFrame(GwentPlayFrame.playerRanged) then
		return GwentAddon.lists.playerRanged, GwentPlayFrame.playerRanged
	elseif GwentAddon:MouseIsOverFrame(GwentPlayFrame.playerMelee) then
		return GwentAddon.lists.playerMelee, GwentPlayFrame.playerMelee
	end
	
	return nil
end

-- Get the card the from a list the mouse is currently hovering over
function GwentAddon:GetCardMouseOverInLisT(list)
	if list == nil then return nil end

	for k, card in pairs(list) do
		if GwentAddon:MouseIsOverFrame(card) then
			return card
		end
	end
	
	return nil
end

-- Creates inner shadow textures for a frame
local function CreateInnerShadow(parent, multiplier)
	local mult = 1
	if multiplier ~= nil then
		mult = multiplier
	end
	
	local drawlayer = 0

	parent.topleft = parent:CreateTexture(parent:GetName().."Shadow_TL", "BACKGROUND")
	parent.topleft:SetTexture(TEXTURE_SHADOW_CORNERS)
	parent.topleft:SetTexCoord(0, 46/64, 0, 46/256)
	parent.topleft:SetWidth(32*mult)
	parent.topleft:SetHeight(32*mult)
	parent.topleft:SetDrawLayer("background", drawlayer+2)
	parent.topleft:SetPoint("topleft", parent)
	
	parent.bottomleft = parent:CreateTexture(parent:GetName().."Shadow_BL", "BACKGROUND")
	parent.bottomleft:SetTexture(TEXTURE_SHADOW_CORNERS)
	parent.bottomleft:SetTexCoord(0, 46/64, 46/256, 92/256)
	parent.bottomleft:SetWidth(32*mult)
	parent.bottomleft:SetHeight(32*mult)
	parent.bottomleft:SetDrawLayer("background", drawlayer+2)
	parent.bottomleft:SetPoint("bottomleft", parent)
	
	parent.topright = parent:CreateTexture(parent:GetName().."Shadow_TR", "BACKGROUND")
	parent.topright:SetTexture(TEXTURE_SHADOW_CORNERS)
	parent.topright:SetTexCoord(0, 46/64, 92/256, 138/256)
	parent.topright:SetWidth(32*mult)
	parent.topright:SetHeight(32*mult)
	parent.topright:SetDrawLayer("background", drawlayer+2)
	parent.topright:SetPoint("topright", parent)
	
	parent.bottomright = parent:CreateTexture(parent:GetName().."Shadow_BR", "BACKGROUND")
	parent.bottomright:SetTexture(TEXTURE_SHADOW_CORNERS)
	parent.bottomright:SetTexCoord(0, 46/64, 138/256, 184/256)
	parent.bottomright:SetWidth(32*mult)
	parent.bottomright:SetHeight(32*mult)
	parent.bottomright:SetDrawLayer("background", drawlayer+2)
	parent.bottomright:SetPoint("bottomright", parent)
	
	parent.top = parent:CreateTexture(parent:GetName().."Shadow_T", "BACKGROUND")
	parent.top:SetTexture(TEXTURE_SHADOW_HORIZONTAL, true)
	parent.top:SetTexCoord(0, 1, 19/64, 38/64)
	parent.top:SetHeight(14*mult)
	parent.top:SetDrawLayer("background", drawlayer+2)
	parent.top:SetPoint("topleft", parent.topleft, "topright")
	parent.top:SetPoint("topright", parent.topright, "topleft")
	
	
	parent.bottom = parent:CreateTexture(parent:GetName().."Shadow_B", "BACKGROUND")
	parent.bottom:SetTexture(TEXTURE_SHADOW_HORIZONTAL, true)
	parent.bottom:SetTexCoord(0, 1, 0, 19/64)
	parent.bottom:SetHeight(14*mult)
	parent.bottom:SetDrawLayer("background", drawlayer+2)
	parent.bottom:SetPoint("bottomleft", parent.bottomleft, "bottomright")
	parent.bottom:SetPoint("bottomright", parent.bottomright, "bottomleft")
	
	parent.left = parent:CreateTexture(parent:GetName().."Shadow_L", "BACKGROUND")
	parent.left:SetTexture(TEXTURE_SHADOW_VERTICAL)
	parent.left:SetTexCoord(19/64, 38/64, 0, 1)
	parent.left:SetWidth(14*mult)
	parent.left:SetDrawLayer("background", drawlayer+2)
	parent.left:SetPoint("topleft", parent.topleft, "bottomleft")
	parent.left:SetPoint("bottomleft", parent.bottomleft, "topleft")
	
	parent.right = parent:CreateTexture(parent:GetName().."Shadow_R", "BACKGROUND")
	parent.right:SetTexture(TEXTURE_SHADOW_VERTICAL)
	parent.right:SetTexCoord(0, 19/64, 0, 1)
	parent.right:SetWidth(14*mult)
	parent.right:SetDrawLayer("background", drawlayer+2)
	parent.right:SetPoint("topright", parent.topright, "bottomright")
	parent.right:SetPoint("bottomright", parent.bottomright, "topright")
end

-- Creates inner shadow textures for a frame
local function CreateOuterCardShadow(parent, multiplier)
	local mult = 1
	if multiplier ~= nil then
		mult = multiplier
	end
	
	local drawlayer = 0

	local tex = "Interface\\ACHIEVEMENTFRAME\\UI-Shadow-Backdrop"
	
	parent.topleft = parent:CreateTexture(parent:GetName().."Shadow_TL", "BACKGROUND")
	parent.topleft:SetTexture(tex)
	parent.topleft:SetTexCoord(16*4/128, 16*5/128, 0, 1)
	parent.topleft:SetWidth(16*mult)
	parent.topleft:SetHeight(16*mult)
	parent.topleft:SetDrawLayer("background", drawlayer+2)
	parent.topleft:SetPoint("bottomright", parent, "topleft", 6*mult, -10*mult)
	
	parent.bottomleft = parent:CreateTexture(parent:GetName().."Shadow_BL", "BACKGROUND")
	parent.bottomleft:SetTexture(tex)
	parent.bottomleft:SetTexCoord(16*6/128, 16*7/128, 0, 1)
	parent.bottomleft:SetWidth(16*mult)
	parent.bottomleft:SetHeight(16*mult)
	parent.bottomleft:SetDrawLayer("background", drawlayer+2)
	parent.bottomleft:SetPoint("topright", parent, "bottomleft", 6*mult, 7*mult)
	
	parent.topright = parent:CreateTexture(parent:GetName().."Shadow_TR", "BACKGROUND")
	parent.topright:SetTexture(tex)
	parent.topright:SetTexCoord(16*5/128, 16*6/128, 0, 1)
	parent.topright:SetWidth(16*mult)
	parent.topright:SetHeight(16*mult)
	parent.topright:SetDrawLayer("background", drawlayer+2)
	parent.topright:SetPoint("bottomleft", parent, "topright", -10*mult, -10*mult)
	
	parent.bottomright = parent:CreateTexture(parent:GetName().."Shadow_BR", "BACKGROUND")
	parent.bottomright:SetTexture(tex)
	parent.bottomright:SetTexCoord(16*7/128, 16*8/128, 0, 1)
	parent.bottomright:SetWidth(16*mult)
	parent.bottomright:SetHeight(16*mult)
	parent.bottomright:SetDrawLayer("background", drawlayer+2)
	parent.bottomright:SetPoint("topleft", parent, "bottomright", -10*mult, 7*mult)
	
	parent.top = parent:CreateTexture(parent:GetName().."Shadow_T", "BACKGROUND")
	parent.top:SetTexture(tex, true)
	parent.top:SetTexCoord(16*0/128, 16*1/128, 0, 1)
	parent.top:SetHeight(16*mult)
	parent.top:SetDrawLayer("background", drawlayer+2)
	parent.top:SetPoint("topleft", parent.topleft, "topright")
	parent.top:SetPoint("topright", parent.topright, "topleft")

	parent.bottom = parent:CreateTexture(parent:GetName().."Shadow_B", "BACKGROUND")
	parent.bottom:SetTexture(tex, true)
	parent.bottom:SetTexCoord(16*1/128, 16*2/128, 0, 1)
	parent.bottom:SetHeight(16*mult)
	parent.bottom:SetDrawLayer("background", drawlayer+2)
	parent.bottom:SetPoint("bottomleft", parent.bottomleft, "bottomright")
	parent.bottom:SetPoint("bottomright", parent.bottomright, "bottomleft")
	
	parent.left = parent:CreateTexture(parent:GetName().."Shadow_L", "BACKGROUND")
	parent.left:SetTexture(tex, true)
	parent.left:SetTexCoord(16*2/128, 16*3/128, 0, 1)
	parent.left:SetWidth(16*mult)
	parent.left:SetDrawLayer("background", drawlayer+2)
	parent.left:SetPoint("topleft", parent.topleft, "bottomleft")
	parent.left:SetPoint("bottomleft", parent.bottomleft, "topleft")
	
	parent.right = parent:CreateTexture(parent:GetName().."Shadow_R", "BACKGROUND")
	parent.right:SetTexture(tex, true)
	parent.right:SetTexCoord(16*3/128, 16*4/128, 0, 1)
	parent.right:SetWidth(16*mult)
	parent.right:SetDrawLayer("background", drawlayer+2)
	parent.right:SetPoint("topright", parent.topright, "bottomright")
	parent.right:SetPoint("bottomright", parent.bottomright, "topright")
end

local function CreateCardArea(name, parent, texture, weatherTex)
	local frame = CreateFrame("frame", addonName.."PlayFrame_" .. name, parent)
	frame:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	
	frame.bg = frame:CreateTexture(addonName.."PlayFrame_"..name.."BG")
	frame.bg:SetTexture(TEXTURE_CARD_BG)
	frame.bg:SetDrawLayer("background", 1)
	frame.bg:SetPoint("topleft", frame)
	frame.bg:SetPoint("bottomright", frame)
	-- frame:SetBackdrop({bgFile = TEXTURE_CARD_BG,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	  
	CreateInnerShadow(frame, 0.5)
	  
	frame.cardContainer = CreateFrame("frame", addonName.."PlayFrame_" .. name.."_Cardcontainer", parent)
	frame.cardContainer:SetPoint("center", frame)
	frame.cardContainer:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	 
	frame.commander = CreateFrame("frame", addonName.."PlayFrame_" .. name .."_Commander", parent)
	frame.commander:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander:SetWidth(GwentAddon.NUM_CARD_HEIGHT)
	frame.commander:SetPoint("right", frame, "left", -5, 0)
	-- frame.commander:SetBackdrop({bgFile = TEXTURE_CARD_BG,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	CreateInnerShadow(frame.commander, 0.5)
	 
	frame.commander.bg = frame.commander:CreateTexture(addonName.."PlayFrame_"..name.."_ICONCOMMANDERBG")
	frame.commander.bg:SetTexture(TEXTURE_CARD_BG)
	frame.commander.bg:SetDrawLayer("background", 1)
	frame.commander.bg:SetPoint("topleft", frame.commander)
	frame.commander.bg:SetPoint("bottomright", frame.commander)
	 
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
	
	frame.weather = frame:CreateTexture(addonName.."PlayFrame_"..name.."_Weather", "art")
	frame.weather:SetTexture(weatherTex)
	frame.weather:SetTexCoord(0, 1, 0, 1)
	frame.weather:SetDrawLayer("Overlay", 0)
	frame.weather:SetVertexColor(1, 1, 1, 0.5)
	frame.weather:SetPoint("topleft", frame, 0, -3)
	frame.weather:SetPoint("bottomright", frame, 0, 3)
	--frame.weather:Hide()
	
	return frame
end

-- Create a sidebar to use for player details, weather area and leader cards
local function CreateSidebar(parent)
	parent.sideBar = CreateFrame("frame", addonName.."SideBar", parent)
	parent.sideBar:SetPoint("topleft", parent, "topleft", 23, -22)
	parent.sideBar:SetPoint("bottomright", parent, "bottomleft", 259, 23)
	--parent.playerHand:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	--parent.playerHand:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	-- parent.playerHand:SetBackdrop({bgFile = TEXTURE_CARD_DARKEN,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	  
	parent.sideBar.tex = parent.sideBar:CreateTexture(addonName.."SideBarBG", "BACKGROUND")
	-- parent.sideBar.tex:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment")
	parent.sideBar.tex:SetTexture("Interface\\Garrison\\GarrisonLandingPageMiddleTile", true)

	-- parent.sideBar.tex:SetTexture("Interface\\PETBATTLES\\MountJournal-BG")
	parent.sideBar.tex:SetTexCoord(0, 1, 0, 4)
	--parent.sideBar.tex:SetTexture("Interface\\PETBATTLES\\MountJournal-BG")
	-- parent.sideBar.tex:SetTexCoord(0, 1, 0, 404/512)
	parent.sideBar.tex:SetVertexColor(135/255, 105/255, 70/255)
	parent.sideBar.tex:SetPoint("topleft", parent.sideBar)
	parent.sideBar.tex:SetPoint("bottomright", parent.sideBar)
	
	CreateInnerShadow(parent.sideBar, 0.5)
	return parent.sideBar
end

-- Create a frame to use for cards ares, card tooltip, graveyards and decks
local function CreatePlayField(parent)
	parent.playField = CreateFrame("frame", addonName.."playField", parent)
	parent.playField:SetPoint("topleft", parent.sideBar, "topright", 0, 0)
	parent.playField:SetPoint("bottomright", parent, "bottomright", -23, 23)

	parent.playField.tex = parent.playField:CreateTexture(addonName.."SideBarBG", "BACKGROUND")
	--parent.playField.tex:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment")
	--parent.playField.tex:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTTOM", true)
	parent.playField.tex:SetTexture("Interface\\Garrison\\GarrisonLandingPageMiddleTile", true)

	-- parent.sideBar.tex:SetTexture("Interface\\PETBATTLES\\MountJournal-BG")
	parent.playField.tex:SetTexCoord(0, 5, 0, 4)
	parent.playField.tex:SetVertexColor(175/255, 135/255, 90/255)
	-- parent.playField.tex:SetVertexColor(135/255, 105/255, 70/255)
	parent.playField.tex:SetPoint("topleft", parent.playField)
	parent.playField.tex:SetPoint("bottomright", parent.playField)
	
	CreateInnerShadow(parent.playField)
	
	return parent.playField
end

-- Create a frame for a players' portair, total point, name, faction and live points
local function CreatePlayerDisplay(parent, xPos, yPos, name)
	local collection = {}
	collection.details = CreateFrame("frame", parent:GetName() .. name.."Details", parent)
	collection.details:SetPoint("left", parent, "left", xPos, yPos)
	collection.details:SetPoint("right", parent, "right", xPos, yPos)
	collection.details:SetHeight(GwentAddon.NUM_CARD_HEIGHT+10)
	collection.detailsBG = collection.details:CreateTexture(parent:GetName() .. name.."DetailsBG", "BACKGROUND")
	collection.detailsBG:SetTexture("Interface\\Cooldown\\LoC-ShadowBG")
	collection.detailsBG:SetPoint("topleft", collection.details)
	collection.detailsBG:SetPoint("bottomright", collection.details)
	
	-- player total Points
	collection.total = collection.details:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	collection.total:SetPoint("right", collection.details, "right", 20, 0)
	collection.total:SetWidth(NUM_BORDERSIZE_TOTAL)
	collection.total:SetHeight(NUM_BORDERSIZE_TOTAL)
	--collection.total:SetPoint("right", collection.total)
	collection.total:SetText(0)

	collection.total.bg = collection.details:CreateTexture(parent:GetName() .. name.."TotalBG", "ARTWORK")
	collection.total.bg:SetDrawLayer("ARTWORK", 0)
	collection.total.bg:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Neutral")
	--collection.total.bg:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-SHIELDS")
	--collection.total.bg:SetTexCoord(0.5, 1, 0, 0.5)
	collection.total.bg:SetWidth(NUM_BORDERSIZE_TOTAL*0.6)
	collection.total.bg:SetHeight(NUM_BORDERSIZE_TOTAL*0.6)
	collection.total.bg:SetPoint("center", collection.total, 0, 0)
	
	collection.total.border = collection.details:CreateTexture(parent:GetName() .. name.."Total", "ARTWORK")
	collection.total.border:SetDrawLayer("ARTWORK", 1)
	collection.total.border:SetTexture(TEXTURE_ICONS.path)
	collection.total.border:SetTexCoord((0)/TEXTURE_ICONS.width, (1 + NUM_SIZE_ICON)/TEXTURE_ICONS.width, (0)/TEXTURE_ICONS.height, (1+ NUM_SIZE_ICON)/TEXTURE_ICONS.height)
	collection.total.border:SetVertexColor(220/255, 185/255, 0)
	collection.total.border:SetWidth(NUM_BORDERSIZE_TOTAL*0.75)
	collection.total.border:SetHeight(NUM_BORDERSIZE_TOTAL*1.1)
	collection.total.border:SetPoint("center", collection.total, 0, -6)
	collection.total.border:Hide()
	
	-- collection.total.points = collection.details:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	-- collection.total.points:SetPoint("topleft", collection.total)
	-- collection.total.points:SetPoint("bottomright", collection.total)
	-- collection.total.points:SetText(0)

	-- player portrait
	collection.portrait = collection.details:CreateTexture(parent:GetName() .. name.."Portrait", "ARTWORK")
	collection.portrait:SetDrawLayer("ARTWORK", 0)
	collection.portrait:SetWidth(GwentAddon.NUM_CARD_HEIGHT-10)
	collection.portrait:SetHeight(GwentAddon.NUM_CARD_HEIGHT-10)
	collection.portrait:SetPoint("left", collection.details, "left", 10, 0)
	
	SetPortraitTexture(collection.portrait, TEXTURE_PORTAITDEFAULT)
	
	collection.portraitborder = collection.details:CreateTexture(parent:GetName() .. name.."PortraitBorder", "ARTWORK")
	collection.portraitborder:SetDrawLayer("ARTWORK", 1)
	collection.portraitborder:SetTexture(TEXTURE_TOTAL_BORDERNORMAL)
	collection.portraitborder:SetWidth(GwentAddon.NUM_CARD_HEIGHT+50)
	collection.portraitborder:SetHeight(GwentAddon.NUM_CARD_HEIGHT+50)
	collection.portraitborder:SetPoint("center", collection.portrait)
	
	-- player nametag
	collection.nametag = collection.details:CreateFontString(nil, nil, "GameFontNormal")
	collection.nametag:SetPoint("left", collection.portrait, "right", 10, -5)
	collection.nametag:SetPoint("right", collection.details, "right", -10, -5)
	collection.nametag:SetJustifyH("left")
	collection.nametag:SetText("Enemy name")
	
	-- player deck
	collection.faction = collection.details:CreateFontString(nil, nil, "GameFontNormal")
	collection.faction:SetPoint("topleft", collection.nametag, "bottomleft", 0, 0)
	collection.faction:SetPoint("topright", collection.nametag, "bottomright", 0, 0)
	collection.faction:SetJustifyH("left")
	collection.faction:SetText("Faction here")
	
	collection.life1 = collection.details:CreateTexture(parent:GetName() .. name.."Life1", "ARTWORK")
	collection.life1:SetDrawLayer("ARTWORK", 1)
	collection.life1:SetTexture(TEXTURE_ICONS.path)
	collection.life1:SetTexCoord((COORDS_ICON_LIFE.x+5)/TEXTURE_ICONS.width, (COORDS_ICON_LIFE.x + NUM_SIZE_ICON-5)/TEXTURE_ICONS.width, (COORDS_ICON_LIFE.y+5)/TEXTURE_ICONS.height, (COORDS_ICON_LIFE.y + NUM_SIZE_ICON -5)/TEXTURE_ICONS.height)
	collection.life1:SetVertexColor(0.8, 0.1, 0.1)
	collection.life1:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	collection.life1:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	collection.life1:SetPoint("bottomleft", collection.nametag, "topleft")
	
	
	-- player life 2
	collection.life2 = collection.details:CreateTexture(parent:GetName() .. name.."Life2", "ARTWORK")
	collection.life2:SetDrawLayer("ARTWORK", 1)
	collection.life2:SetTexture(TEXTURE_ICONS.path)
	collection.life2:SetTexCoord((COORDS_ICON_LIFE.x+5)/TEXTURE_ICONS.width, (COORDS_ICON_LIFE.x + NUM_SIZE_ICON-5)/TEXTURE_ICONS.width, (COORDS_ICON_LIFE.y+5)/TEXTURE_ICONS.height, (COORDS_ICON_LIFE.y + NUM_SIZE_ICON -5)/TEXTURE_ICONS.height)
	collection.life2:SetVertexColor(0.8, 0.1, 0.1)
	collection.life2:SetWidth(GwentAddon.NUM_CARD_HEIGHT/2)
	collection.life2:SetHeight(GwentAddon.NUM_CARD_HEIGHT/2)
	collection.life2:SetPoint("left", collection.life1, "right")
	
	-- Turn highlight
	collection.turn = collection.details:CreateTexture(parent:GetName() .. name.."Turn")
	collection.turn:SetDrawLayer("overlay", 1)
	collection.turn:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
	collection.turn:SetTexCoord(0, 328/512, 788/1024, 851/1024)
	collection.turn:SetVertexColor(1, 1, 1, 0.5)
	collection.turn:SetPoint("topleft", collection.details)
	collection.turn:SetPoint("bottomright", collection.details)
	collection.turn:SetBlendMode("add")
	collection.turn:Hide()
	
	return collection
end

local function CreatePlayFrame()

	GwentAddon.draggingOver.timer = 0
	local GwentUpdater = CreateFrame("frame", "GwentUpdater", UIParent)
	
	GwentUpdater:SetScript("OnUpdate", function(self,elapsed) 
		
		
		if GwentAddon.cards.draggedCard == nil then return end
		
		
		GwentAddon.draggingOver.timer = GwentAddon.draggingOver.timer + elapsed
		if GwentAddon.draggingOver.timer >= 0.05 then
			GwentAddon.draggingOver.list = nil
		GwentAddon.draggingOver.card = nil
		GwentAddon.draggingOver.mouseX, GwentAddon.draggingOver.mouseY = 0, 0
			
			GwentAddon.draggingOver.list, GwentAddon.draggingOver.area = GwentAddon:GetCardlistMouseOver()
			--GwentAddon.draggingOver.card = GwentAddon:GetCardMouseOverInLisT(GwentAddon.draggingOver.list)
			GwentAddon.draggingOver.mouseX, GwentAddon.draggingOver.mouseY = GetCursorPosition()
			if GwentAddon.draggingOver.list ~= nil then
				for k, card in pairs(GwentAddon.draggingOver.list) do
					if GwentAddon.cards:UpdateCardSpaceing(card, GwentAddon.draggingOver.mouseX, GwentAddon.draggingOver.mouseY) then
						GwentAddon.draggingOver.card = card
					end
				end
				GwentAddon:PlaceCardsOnFrame(GwentAddon.draggingOver.list, GwentAddon.draggingOver.area)
			end
			-- safety to not lose card
			-- if overCard ~= nil then
				-- GwentAddon.cards:UpdateCardSpaceing(GwentAddon.draggingOver.card, GwentAddon.draggingOver.mouseX, GwentAddon.draggingOver.mouseY)
				-- GwentAddon:PlaceCardsOnFrame(GwentAddon.draggingOver.list, GwentAddon.draggingOver.area)
			-- end
			GwentAddon.draggingOver.timer = 0
		end
		end)
	
	
	
		local PlayFrame = CreateFrame("frame", addonName.."PlayFrame", UIParent)
	PlayFrame:SetHeight(780)
	PlayFrame:SetWidth(1200)
	-- PlayFrame:SetAlpha(0.7)
	PlayFrame:SetMovable(true)
	PlayFrame:SetPoint("Center", 0, 0)
	PlayFrame:RegisterForDrag("LeftButton")
	PlayFrame:SetScript("OnDragStart", PlayFrame.StartMoving )
	PlayFrame:SetScript("OnDragStop", PlayFrame.StopMovingOrSizing)
	PlayFrame:EnableMouse(true)
	GwentAddon.frameBaseLevel = PlayFrame:GetFrameLevel()
	local fbl = GwentAddon.frameBaseLevel
	
	PlayFrame:SetBackdrop({bgFile = nil,
      edgeFile = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-WoodBorder",
	  tileSize = 32, edgeSize = 64,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	

	local bSat = 0.6
	
	PlayFrame.left = PlayFrame:CreateTexture(addonName.."PlayFrame_L")
	PlayFrame.left:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left")
	PlayFrame.left:SetTexCoord(0, 1, 0, .87)
	PlayFrame.left:SetDrawLayer("ARTWORK", 0)
	PlayFrame.left:SetWidth(16)
	PlayFrame.left:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.left:SetPoint("topleft", PlayFrame, "topleft", 15, -25)
	PlayFrame.left:SetPoint("bottomleft", PlayFrame, "bottomleft", 15, 25)
	
	PlayFrame.right = PlayFrame:CreateTexture(addonName.."PlayFrame_R")
	PlayFrame.right:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left")
	PlayFrame.right:SetTexCoord(1, 0, 0, .87)
	PlayFrame.right:SetDrawLayer("ARTWORK", 0)
	PlayFrame.right:SetWidth(16)
	PlayFrame.right:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.right:SetPoint("topright", PlayFrame, "topright", -15, -25)
	PlayFrame.right:SetPoint("bottomright", PlayFrame, "bottomright", -15, 25)
	
	PlayFrame.bottom = PlayFrame:CreateTexture(addonName.."PlayFrame_B")
	PlayFrame.bottom:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top")
	PlayFrame.bottom:SetTexCoord(0, .87, 1, 0)
	PlayFrame.bottom:SetDrawLayer("ARTWORK", 0)
	PlayFrame.bottom:SetHeight(16)
	PlayFrame.bottom:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.bottom:SetPoint("bottomleft", PlayFrame, "bottomleft", 30, 15)
	PlayFrame.bottom:SetPoint("bottomright", PlayFrame, "bottomright", -30, 15)
	
	PlayFrame.top = PlayFrame:CreateTexture(addonName.."PlayFrame_T")
	PlayFrame.top:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top")
	PlayFrame.top:SetTexCoord(0, .87, 0, 1)
	PlayFrame.top:SetDrawLayer("ARTWORK", 0)
	PlayFrame.top:SetHeight(16)
	PlayFrame.top:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.top:SetPoint("topleft", PlayFrame, "topleft", 30, -15)
	PlayFrame.top:SetPoint("topright", PlayFrame, "topright", -30, -15)
	
	PlayFrame.topleft = PlayFrame:CreateTexture(addonName.."PlayFrame_TL")
	PlayFrame.topleft:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	PlayFrame.topleft:SetTexCoord(1, 0, 1, 0)
	PlayFrame.topleft:SetDrawLayer("ARTWORK", 2)
	PlayFrame.topleft:SetWidth(32)
	PlayFrame.topleft:SetHeight(32)
	PlayFrame.topleft:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.topleft:SetPoint("topleft", PlayFrame, 10, -10)
	
	PlayFrame.topleftDetail = PlayFrame:CreateTexture(addonName.."PlayFrame_TLDetail")
	PlayFrame.topleftDetail:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	PlayFrame.topleftDetail:SetTexCoord(0, 1, 0, 1)
	PlayFrame.topleftDetail:SetDrawLayer("ARTWORK", 1)
	PlayFrame.topleftDetail:SetWidth(64)
	PlayFrame.topleftDetail:SetHeight(64)
	PlayFrame.topleftDetail:SetPoint("topleft", PlayFrame, 3, -2)
	
	PlayFrame.topright = PlayFrame:CreateTexture(addonName.."PlayFrame_TR")
	PlayFrame.topright:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	PlayFrame.topright:SetTexCoord(0, 1, 1, 0)
	PlayFrame.topright:SetDrawLayer("ARTWORK", 2)
	PlayFrame.topright:SetWidth(32)
	PlayFrame.topright:SetHeight(32)
	PlayFrame.topright:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.topright:SetPoint("topright", PlayFrame, -10, -10)
	
	PlayFrame.toprightDetail = PlayFrame:CreateTexture(addonName.."PlayFrame_TRDetail")
	PlayFrame.toprightDetail:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	PlayFrame.toprightDetail:SetTexCoord(1, 0, 0, 1)
	PlayFrame.toprightDetail:SetDrawLayer("ARTWORK", 1)
	PlayFrame.toprightDetail:SetWidth(64)
	PlayFrame.toprightDetail:SetHeight(64)
	PlayFrame.toprightDetail:SetPoint("topright", PlayFrame, -3, -2)
	
	PlayFrame.bottomleft = PlayFrame:CreateTexture(addonName.."PlayFrame_BL")
	PlayFrame.bottomleft:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	PlayFrame.bottomleft:SetTexCoord(1, 0, 0, 1)
	PlayFrame.bottomleft:SetDrawLayer("ARTWORK", 2)
	PlayFrame.bottomleft:SetWidth(32)
	PlayFrame.bottomleft:SetHeight(32)
	PlayFrame.bottomleft:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.bottomleft:SetPoint("bottomleft", PlayFrame, 10, 10)
	
	PlayFrame.bottomleftDetail = PlayFrame:CreateTexture(addonName.."PlayFrame_BLDetail")
	PlayFrame.bottomleftDetail:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	PlayFrame.bottomleftDetail:SetTexCoord(0, 1, 1, 0)
	PlayFrame.bottomleftDetail:SetDrawLayer("ARTWORK", 1)
	PlayFrame.bottomleftDetail:SetWidth(64)
	PlayFrame.bottomleftDetail:SetHeight(64)
	PlayFrame.bottomleftDetail:SetPoint("bottomleft", PlayFrame, 3, 2)
	
	PlayFrame.bottomright = PlayFrame:CreateTexture(addonName.."PlayFrame_BR")
	PlayFrame.bottomright:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	PlayFrame.bottomright:SetTexCoord(0, 1, 0, 1)
	PlayFrame.bottomright:SetDrawLayer("ARTWORK", 2)
	PlayFrame.bottomright:SetWidth(32)
	PlayFrame.bottomright:SetHeight(32)
	PlayFrame.bottomright:SetVertexColor(bSat, bSat, bSat)
	PlayFrame.bottomright:SetPoint("bottomright", PlayFrame, -10, 10)
	
	PlayFrame.bottomrightDetail = PlayFrame:CreateTexture(addonName.."PlayFrame_BRDetail")
	PlayFrame.bottomrightDetail:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	PlayFrame.bottomrightDetail:SetTexCoord(1, 0, 1, 0)
	PlayFrame.bottomrightDetail:SetDrawLayer("ARTWORK", 1)
	PlayFrame.bottomrightDetail:SetWidth(64)
	PlayFrame.bottomrightDetail:SetHeight(64)
	PlayFrame.bottomrightDetail:SetPoint("bottomright", PlayFrame, -3, 2)
	
	PlayFrame.header = CreateFrame("frame", addonName.."PlayFrameHeader", PlayFrame)
	PlayFrame.header:SetHeight(106)
	PlayFrame.header:SetWidth(726)
	PlayFrame.header:SetPoint("bottom", PlayFrame ,"top", 0, -41)
	PlayFrame.header:Hide()
	
	
	PlayFrame.headerLeft = PlayFrame.header:CreateTexture(addonName.."PlayFrameHeaderLeft")
	PlayFrame.headerLeft:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Header")
	PlayFrame.headerLeft:SetTexCoord(0, 1, 0, 0.4140625)
	PlayFrame.headerLeft:SetDrawLayer("ARTWORK", 0)
	PlayFrame.headerLeft:SetWidth(512)
	PlayFrame.headerLeft:SetHeight(106)
	PlayFrame.headerLeft:SetPoint("bottomleft", PlayFrame.header)
	
	PlayFrame.headerRight = PlayFrame.header:CreateTexture(addonName.."PlayFrameHeaderRight")
	PlayFrame.headerRight:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Header")
	PlayFrame.headerRight:SetTexCoord(0, 0.419921875, 0.4140625, 0.8046875)
	PlayFrame.headerRight:SetDrawLayer("ARTWORK", 0)
	PlayFrame.headerRight:SetWidth(214)
	PlayFrame.headerRight:SetHeight(100)
	PlayFrame.headerRight:SetPoint("bottomright", PlayFrame.header, 0, -6)
	
	PlayFrame.closeButton = CreateFrame("Button", addonName.."PlayFrameCloseButton", PlayFrame, "UIPanelCloseButton")
	PlayFrame.closeButton:SetFrameLevel(fbl + 1)
	-- PlayFrame.closeButton:SetHitRectInsets(4, 4, 4, 4)
	PlayFrame.closeButton:SetPoint("topright", PlayFrame, 3, 4)
	PlayFrame.closeButton:Show()
	PlayFrame.closeButton:SetScript("OnClick",  function() 
		PlayFrame:Hide()
	end)
	
	CreateCardTooltip(PlayFrame)
	--CreateWeatherArea(PlayFrame)
	local sidebar = CreateSidebar(PlayFrame)
	local playfield = CreatePlayField(PlayFrame)
	
	
	PlayFrame.weather = CreateFrame("frame", addonName.."Weather", playfield)
	--GwentAddon.areas.playerHand = PlayFrame.playerHand
	PlayFrame.weather:SetPoint("right", sidebar, "right", -30, 0)
	PlayFrame.weather:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.weather:SetWidth(GwentAddon.NUM_CARD_WIDTH * 3)
	
	PlayFrame.weather.bg = PlayFrame.weather:CreateTexture(addonName.."WeatherBG")
	PlayFrame.weather.bg:SetTexture(TEXTURE_CARD_BG)
	PlayFrame.weather.bg:SetDrawLayer("background", 1)
	PlayFrame.weather.bg:SetPoint("topleft", PlayFrame.weather)
	PlayFrame.weather.bg:SetPoint("bottomright", PlayFrame.weather)
	
	CreateInnerShadow(PlayFrame.weather, 0.5)
	-- PlayFrame.playerHand:SetBackdrop({bgFile = TEXTURE_CARD_DARKEN,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	  
	PlayFrame.weather.cardContainer = CreateFrame("frame", addonName.."WeatherContainer", PlayFrame.weather)
	PlayFrame.weather.cardContainer:SetPoint("center", PlayFrame.weather)
	PlayFrame.weather.cardContainer:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	
	
	PlayFrame.player = CreatePlayerDisplay(sidebar, 0, -GwentAddon.NUM_CARD_HEIGHT *2, "player")
	PlayFrame.player.nametag:SetText(GetUnitName("player", false))
	GwentAddon.playerLives.texture1 = PlayFrame.player.life1
	GwentAddon.playerLives.texture2 = PlayFrame.player.life2
	
	-- player hand
	PlayFrame.playerHand = CreateFrame("frame", addonName.."playerHand", playfield)
	GwentAddon.areas.playerHand = PlayFrame.playerHand
	PlayFrame.playerHand:SetPoint("bottom", playfield, "bottom", -30, 10)
	PlayFrame.playerHand:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.playerHand:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	
	CreateInnerShadow(PlayFrame.playerHand, 0.5)
	-- PlayFrame.playerHand:SetBackdrop({bgFile = TEXTURE_CARD_DARKEN,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	  
	PlayFrame.playerHand.cardContainer = CreateFrame("frame", addonName.."playerHandContainer", PlayFrame.playerHand)
	PlayFrame.playerHand.cardContainer:SetPoint("center", PlayFrame.playerHand)
	PlayFrame.playerHand.cardContainer:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	  
	PlayFrame.player.deck = CreateFrame("frame", addonName.."baseDeck", playfield)
	PlayFrame.player.deck:SetPoint("bottomright", playfield, "bottomright", -50, 50)
	PlayFrame.player.deck:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.player.deck:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateOuterCardShadow(PlayFrame.player.deck)
	
	PlayFrame.player.decktex = PlayFrame.player.deck:CreateTexture(addonName.."baseDeckBack")
	PlayFrame.player.decktex:SetDrawLayer("ARTWORK", 0)
	PlayFrame.player.decktex:SetTexture(TEXTURE_CUSTOM_PATH.."BackNeutral")
	PlayFrame.player.decktex:SetTexCoord(0, 1, 0, 464/512)
	PlayFrame.player.decktex:SetPoint("topleft", PlayFrame.player.deck)
	PlayFrame.player.decktex:SetPoint("bottomright", PlayFrame.player.deck)
	
	PlayFrame.player.leader = CreateFrame("frame", addonName.."playerHero", sidebar)
	PlayFrame.player.leader:SetPoint("bottomleft", sidebar, "bottomleft", 50, 50)
	PlayFrame.player.leader:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.player.leader:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateOuterCardShadow(PlayFrame.player.leader)
	
	PlayFrame.player.herotex = PlayFrame.player.leader:CreateTexture(addonName.."playerHeroTex")
	PlayFrame.player.herotex:SetDrawLayer("ARTWORK", 0)
	PlayFrame.player.herotex:SetTexture(TEXTURE_CUSTOM_PATH.."BackNeutral")
	PlayFrame.player.herotex:SetTexCoord(0, 1, 0, 464/512)
	PlayFrame.player.herotex:SetPoint("topleft", PlayFrame.player.leader)
	PlayFrame.player.herotex:SetPoint("bottomright", PlayFrame.player.leader)
	
	--CreateInnerShadow(PlayFrame.player.deck, 0.5)
	
	PlayFrame.player.graveyard = CreateFrame("frame", addonName.."playerGY", playfield)
	PlayFrame.player.graveyard:SetPoint("right", PlayFrame.player.deck, "left", -30, 0)
	PlayFrame.player.graveyard:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.player.graveyard:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateInnerShadow(PlayFrame.player.graveyard, 0.5)
	  
	-- player siege
	PlayFrame.playerSiege = CreateCardArea("playerSiege", PlayFrame, TEXTURE_TYPE_SIEGE, TEXTURE_WEATHER_RAIN)
	GwentAddon.areas.playerSiege = PlayFrame.playerSiege
	PlayFrame.playerSiege:SetPoint("bottom", PlayFrame.playerHand, "top", 0, 10) 
	-- player ranged
	PlayFrame.playerRanged = CreateCardArea("playerRanged", PlayFrame, TEXTURE_TYPE_RANGED, TEXTURE_WEATHER_FOG)
	GwentAddon.areas.playerRanged = PlayFrame.playerRanged
	PlayFrame.playerRanged:SetPoint("bottom", PlayFrame.playerSiege, "top", 0, 10)  
	-- player melee
	PlayFrame.playerMelee = CreateCardArea("playerMelee", PlayFrame, TEXTURE_TYPE_MELEE, TEXTURE_WEATHER_FROST)
	GwentAddon.areas.playerMelee = PlayFrame.playerMelee
	PlayFrame.playerMelee:SetPoint("bottom", PlayFrame.playerRanged, "top", 0, 10)
	
	
	
	------------------------------------------------------------------------------
	
	-- player pass button
	PlayFrame.passButton = CreateFrame("button", addonName.."PlayFrame_PassButton", PlayFrame, "UIPanelButtonTemplate")
	PlayFrame.passButton:SetPoint("bottomleft", PlayFrame.player.details, "topleft", 5, 10)
	PlayFrame.passButton:SetFrameLevel(fbl+2)
	PlayFrame.passButton:SetSize(100, 25)
	PlayFrame.passButton:SetText("Pass")
	PlayFrame.passButton:SetScript("OnClick", PassTurn)	
	
	-- player discard button
	PlayFrame.discardButton = CreateFrame("button", addonName.."PlayFrame_DiscardButton", PlayFrame, "UIPanelButtonTemplate")
	PlayFrame.discardButton:SetPoint("bottomleft", PlayFrame.playerHand, "bottomright", 15, 10)
	PlayFrame.discardButton:SetFrameLevel(fbl+2)
	PlayFrame.discardButton:SetSize(100, 25)
	PlayFrame.discardButton:SetText("Redraw")
	PlayFrame.discardButton:SetScript("OnClick", function() GwentAddon.cards:DiscardSelectedCards() end)	
	PlayFrame.discardButton:Hide()
	
	
	
	-- enemy hand
	PlayFrame.enemyHand = CreateFrame("frame", addonName.."PlayFrame_EnemyHand", playfield)
	GwentAddon.areas.enemyHand = PlayFrame.enemyHand
	PlayFrame.enemyHand:SetPoint("top", playfield, "top", -30, -10)
	PlayFrame.enemyHand:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemyHand:SetWidth(GwentAddon.NUM_CARD_WIDTH * 10)
	CreateInnerShadow(PlayFrame.enemyHand, 0.5)
	-- PlayFrame.enemyHand:SetBackdrop({bgFile = TEXTURE_CARD_DARKEN,
      -- edgeFile = nil,
	  -- tileSize = 0, edgeSize = 16,
      -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  -- })
	  
	PlayFrame.enemyHand.cardContainer = CreateFrame("frame", addonName.."EnemyHandContainer", PlayFrame.enemyHand)
	PlayFrame.enemyHand.cardContainer:SetPoint("center", PlayFrame.enemyHand)
	PlayFrame.enemyHand.cardContainer:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	
	PlayFrame.enemy = CreatePlayerDisplay(sidebar, 0, GwentAddon.NUM_CARD_HEIGHT *2, "player")
	GwentAddon.enemyLives.texture1 = PlayFrame.enemy.life1
	GwentAddon.enemyLives.texture2 = PlayFrame.enemy.life2
	
	PlayFrame.enemy.deck = CreateFrame("frame", addonName.."EnemyDeck", playfield)
	PlayFrame.enemy.deck:SetPoint("topright", playfield, "topright", -50, -50)
	PlayFrame.enemy.deck:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemy.deck:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateOuterCardShadow(PlayFrame.enemy.deck)
	
	PlayFrame.enemy.decktex = PlayFrame.enemy.deck:CreateTexture(addonName.."EnemyDeckBack")
	PlayFrame.enemy.decktex:SetDrawLayer("ARTWORK", 0)
	PlayFrame.enemy.decktex:SetTexture(TEXTURE_CUSTOM_PATH.."BackNeutral")
	PlayFrame.enemy.decktex:SetTexCoord(0, 1, 0, 464/512)
	PlayFrame.enemy.decktex:SetPoint("topleft", PlayFrame.enemy.deck)
	PlayFrame.enemy.decktex:SetPoint("bottomright", PlayFrame.enemy.deck)
	
	PlayFrame.enemy.leader = CreateFrame("frame", addonName.."enemyHero", sidebar)
	PlayFrame.enemy.leader:SetPoint("topleft", sidebar, "topleft", 50, -50)
	PlayFrame.enemy.leader:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemy.leader:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateOuterCardShadow(PlayFrame.enemy.leader)
	
	PlayFrame.enemy.herotex = PlayFrame.enemy.leader:CreateTexture(addonName.."enemyHeroTex")
	PlayFrame.enemy.herotex:SetDrawLayer("ARTWORK", 0)
	PlayFrame.enemy.herotex:SetTexture(TEXTURE_CUSTOM_PATH.."BackNeutral")
	PlayFrame.enemy.herotex:SetTexCoord(0, 1, 0, 464/512)
	PlayFrame.enemy.herotex:SetPoint("topleft", PlayFrame.enemy.leader)
	PlayFrame.enemy.herotex:SetPoint("bottomright", PlayFrame.enemy.leader)
	
	PlayFrame.enemy.graveyard = CreateFrame("frame", addonName.."playerGY", playfield)
	PlayFrame.enemy.graveyard:SetPoint("right", PlayFrame.enemy.deck, "left", -30, 0)
	PlayFrame.enemy.graveyard:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	PlayFrame.enemy.graveyard:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	CreateInnerShadow(PlayFrame.enemy.graveyard, 0.5)
	  
	-- enemy siege
	PlayFrame.enemySiege = CreateCardArea("enemyRanged", PlayFrame, TEXTURE_TYPE_SIEGE, TEXTURE_WEATHER_RAIN)
	GwentAddon.areas.enemySiege = PlayFrame.enemySiege
	PlayFrame.enemySiege:SetPoint("top", PlayFrame.enemyHand, "bottom", 0, -10) 
	-- enemy ranged
	PlayFrame.enemyRanged = CreateCardArea("enemyRanged", PlayFrame, TEXTURE_TYPE_RANGED, TEXTURE_WEATHER_FOG)
	GwentAddon.areas.enemyRanged = PlayFrame.enemyRanged
	PlayFrame.enemyRanged:SetPoint("top", PlayFrame.enemySiege, "bottom", 0, -10)  
	-- enemy melee
	PlayFrame.enemyMelee = CreateCardArea("enemyMelee", PlayFrame, TEXTURE_TYPE_MELEE, TEXTURE_WEATHER_FROST)
	GwentAddon.areas.enemyMelee = PlayFrame.enemyMelee
	PlayFrame.enemyMelee:SetPoint("top", PlayFrame.enemyRanged, "bottom", 0, -10)

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

-- Checks if the mouse is hovering over a specific frame
function GwentAddon:MouseIsOverFrame(frame)
	local left, bottom, width, height = frame:GetBoundsRect()
	local mouseX, mouseY = GetCursorPosition()
	local s = frame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s

	if mouseX > left and mouseX < left + width and mouseY > bottom and mouseY < bottom + height then
		return true
	end
	
	return false
	
end

-- Get a list by name
function GwentAddon:GetListByName(name)
	for k, v in pairs(GwentAddon.lists) do
		if k == name then
			return v
		end
	end
	
	return nil
end

-- Get a play area by name
function GwentAddon:GetAreaByName(name)
	for k, v in pairs(GwentAddon.areas) do
		if k == name then
			return v
		end
	end
	
	return nil
end

-- Tries to drop a card.
-- If successful returns true, the name of the area and the position in list it was added
function GwentAddon:DropCardArea(card)
	if GwentAddon:MouseIsOverFrame(GwentAddon.playFrame.playerSiege) and IsRightTypeForArea(card, TEXT_SIEGE) then
		
		local pos = GwentAddon.cards:AddCardToNewList(card, "playerSiege")
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_SIEGE, pos
	elseif GwentAddon:MouseIsOverFrame(GwentAddon.playFrame.playerRanged) and IsRightTypeForArea(card, TEXT_RANGED) then
		
		local pos = GwentAddon.cards:AddCardToNewList(card, "playerRanged")
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_RANGED, pos
	elseif GwentAddon:MouseIsOverFrame(GwentAddon.playFrame.playerMelee) and IsRightTypeForArea(card, TEXT_MELEE) then
		
		local pos = GwentAddon.cards:AddCardToNewList(card, "playerMelee")
		GwentAddon.cards:RemoveCardFromHand(card)
		return true, TEXT_MELEE, pos
	end
	return false
end

-- Returns the position of a card in a list
function GwentAddon:NumberInList(card, list)
	for k, v in ipairs(list) do
		if v.data.Id == card.data.Id then
			return k
		end
	end
	
	return -1
end

-- Change the current challengers
function GwentAddon:ChangeChallenger(sender, race, gender)
	if sender == nil then
		sender = ""
	end
		
	GwentAddon.challengerName = sender
	GwentAddon.playFrame.enemy.nametag:SetText(GwentAddon.challengerName)
	
	local challenger = GetUnitName("target", true)	
	if race ~= nil and gender ~= nil then
		if tonumber(gender) == 2 then -- male
			gender = "MALE"
		elseif tonumber(gender) == 3 then -- female
			gender = "FEMALE"
		end
		
		SetPortraitToTexture(GwentAddon.playFrame.enemy.portrait, "Interface\\CHARACTERFRAME\\TemporaryPortrait-"..gender.."-"..race)
		
	elseif challenger ~= nil then
		SetPortraitTexture(GwentAddon.playFrame.enemy.portrait, "target")
		
	end
end

-- Reset the entire game
function GwentAddon:ResetGame() 
	GwentAddon.challengerName = nil
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerHand)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerSiege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerRanged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerMelee)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemySiege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemyRanged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemyMelee)
	GwentAddon:PlaceAllCards()
	_DraggedCard = nil
	_DragginOverFrame = nil
	GwentAddon.enemyPassed = false
	GwentAddon.playerPassed = false
	
	GwentAddon:ChangeState(GwentAddon.states.noGame)

	local pf = GwentAddon.playFrame
	
	pf.player.turn:Hide()
	
	pf.enemy.faction:SetText("")
	pf.enemy.nametag:SetText("")
	pf.enemy.turn:Hide()
	pf.enemy.portrait:SetTexture(TEXTURE_PORTAITDEFAULT)
	pf.player.total.amount = 0
	pf.enemy.total.amount = 0
		
	GwentAddon:ChangeChallenger(nil)
	
	GwentAddon.playerLives.count = 2
	GwentAddon.playerLives.texture1:SetVertexColor(0.8, 0.1, 0.1)
	GwentAddon.playerLives.texture2:SetVertexColor(0.8, 0.1, 0.1)
	GwentAddon.enemyLives.count = 2
	GwentAddon.enemyLives.texture1:SetVertexColor(0.8, 0.1, 0.1)
	GwentAddon.enemyLives.texture2:SetVertexColor(0.8, 0.1, 0.1)
	
	
	
end

-- Resets the board to play a new round
function GwentAddon:StartNewRound()
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerSiege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerRanged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.playerMelee)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemySiege)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemyRanged)
	GwentAddon:DestroyCardsInList(GwentAddon.lists.enemyMelee)
	--GwentAddon.cards:DrawCard()
	GwentAddon:PlaceAllCards()
	_DraggedCard = nil
	_DragginOverFrame = nil
	
	GwentAddon.enemyPassed = false
	GwentAddon.playerPassed = false
	
	GwentAddon.playFrame.passButton:Enable()
end

local function FinishRound() 
	local playerWon = false
	
	if GwentAddon.playFrame.playerTotal.amount == GwentAddon.playFrame.enemyTotal.amount then 
		-- Tie
		SendAddonMessage(addonName, GwentAddon.messages.roundTie, "whisper" , GwentAddon.challengerName)
		GwentAddon:DeductLife(GwentAddon.playerLives)
		GwentAddon:DeductLife(GwentAddon.enemyLives)
		GwentAddon.popup:ShowMessage("Round tied", 4)
		GwentAddon:StartNewRound()
		return
	end
	
	if GwentAddon.playFrame.playerTotal.amount > GwentAddon.playFrame.enemyTotal.amount then
		playerWon = true
	end
	
	if playerWon then
		GwentAddon:DeductLife(GwentAddon.enemyLives)
		GwentAddon.popup:ShowMessage("Round won", 4)
	else
		GwentAddon:DeductLife(GwentAddon.playerLives)
		GwentAddon.popup:ShowMessage("Round lost", 4)
	end

	SendAddonMessage(addonName, GwentAddon.messages.roundWon.. (playerWon and "0" or "1"), "whisper" , GwentAddon.challengerName)
	
	-- check if a side won
	
	
	GwentAddon:StartNewRound()
	--GwentAddon:ResetGame()
end

-- Change the current state the game is in
function GwentAddon:ChangeState(state)
	GwentAddon.currentState = state
	GwentAddon.playFrame.discardButton:Hide()
	GwentAddon.playFrame.player.turn:Hide()
	GwentAddon.playFrame.enemy.turn:Hide()
	GwentAddon.playFrame.passButton:Enable()
	
	if GwentAddon.currentState == GwentAddon.states.playerDiscard or GwentAddon.currentState == GwentAddon.states.enemyDoneDiscarding then
		GwentAddon.popup:ShowMessage("Select up to 2 cards to redraw and click the redraw button.", 4)
		GwentAddon.playFrame.discardButton:Show()
		GwentAddon.playFrame.passButton:Disable()
		
	elseif GwentAddon.currentState == GwentAddon.states.playerTurn then
		if GwentAddon.enemyPassed then
			GwentAddon.popup:ShowMessage("Opponent passed.")
		else
			GwentAddon.popup:ShowMessage("Your turn.")
		end
		GwentAddon.playFrame.player.turn:Show()
		for k, card in ipairs(GwentAddon.lists.playerHand) do
			card.frame:SetMovable(true)
		end
		
	elseif GwentAddon.currentState == GwentAddon.states.enemyTurn then
		GwentAddon.popup:ShowMessage("Opponent turn.")
		GwentAddon.playFrame.enemy.turn:Show()
		for k, card in ipairs(GwentAddon.lists.playerHand) do
			card.frame:SetMovable(false)
		end
		GwentAddon.playFrame.passButton:Disable()
		
		
	elseif GwentAddon.currentState == GwentAddon.states.gameEnd then
		GwentAddon.playFrame.passButton:Disable()
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
	
	print(message)
	print(GwentAddon.messages.challenge)
	print(string.find(message, GwentAddon.messages.challenge))
	--GwentAddon:DEBUGMessageSent(message, sender)
	
	if message == TEXT_ADDONMSG_RECIEVED then
		return
	end
	
	if string.find(message, GwentAddon.messages.challenge) then
		
		local race, gender = string.match(message, GwentAddon.messages.challenge.."#(%a+)#(%d+)")
		GwentAddon:ChangeChallenger(sender, race, gender)
		for i = 1, 10 do
			table.insert(GwentAddon.lists.playerHand ,GwentAddon.lists.baseDeck:DrawCard())
		end
		GwentAddon:PlaceAllCards()
		GwentAddon:ChangeState(GwentAddon.states.playerDiscard)
	end
	
	if message == GwentAddon.messages.logout then
		
		GwentAddon:ResetGame()
	end
	
	if message == GwentAddon.messages.discarded then
		if GwentAddon.currentState == GwentAddon.states.waitEnemyDiscard then
			GwentAddon:ChangeState(GwentAddon.states.determinStart)
			
			local playerStart = math.random(2) == 1 and true or false

			SendAddonMessage(addonName, GwentAddon.messages.start .. (playerStart and "0" or "1"), "whisper" , GwentAddon.challengerName)
			
			if playerStart then
				GwentAddon:ChangeState(GwentAddon.states.playerTurn)
			else
				GwentAddon:ChangeState(GwentAddon.states.enemyTurn)
			end
			
		else
			GwentAddon:ChangeState(GwentAddon.states.enemyDoneDiscarding)
		end
	end
	
	if message == GwentAddon.messages.pass then
		
		GwentAddon.enemyPassed = true
		GwentAddon:ChangeState(GwentAddon.states.playerTurn)
		
		if GwentAddon.playerPassed then
			FinishRound()
		end
	end
	
	-- Enemy played card
	if string.find(message, GwentAddon.messages.placeCard) then
		GwentAddon.cards:AddEnemyCard(message)
		GwentAddon:ChangeState(GwentAddon.states.playerTurn)
	end
	
	if string.find(message, GwentAddon.messages.roundWon) then
		local playerWon = tonumber(string.match(message, GwentAddon.messages.roundWon.."(%d+)")) == 1 and true or false
		if playerWon then
			GwentAddon:DeductLife(GwentAddon.enemyLives)
			GwentAddon.popup:ShowMessage("Round won", 4)
		else
			GwentAddon.popup:ShowMessage("Round lost", 4)
			GwentAddon:DeductLife(GwentAddon.playerLives)
			
		end
		
		
		GwentAddon:StartNewRound()
		GwentAddon:CheckBattleWinner()
	end
	
	if string.find(message, GwentAddon.messages.battleWon) then
		local playerWon = tonumber(string.match(message, GwentAddon.messages.battleWon.."(%d+)")) == 1 and true or false
		if playerWon then
			GwentAddon.popup:ShowButtonMessage("Battle won", "End game", function() GwentAddon:ResetGame() end)
		else
			GwentAddon.popup:ShowButtonMessage("Battle lost", "End game", function() GwentAddon:ResetGame() end)
		end
		GwentAddon:ChangeState(GwentAddon.states.gameEnd)
	end
		
	if message == GwentAddon.messages.roundTie then
		GwentAddon:DeductLife(GwentAddon.enemyLives)
		GwentAddon:DeductLife(GwentAddon.playerLives)
		GwentAddon.popup:ShowMessage("Round tied", 4)
		GwentAddon:StartNewRound()
		GwentAddon:CheckBattleWinner()
	end
	
	if message == GwentAddon.messages.battleTie then
		GwentAddon.popup:ShowButtonMessage("The battle tied", "End game", function() GwentAddon:ResetGame() end)
		GwentAddon:ChangeState(GwentAddon.states.gameEnd)
	end
	
	if string.find(message, GwentAddon.messages.start) then
		local playerStart = tonumber(string.match(message, GwentAddon.messages.start.."(%d+)")) == 1 and true or false
		if playerStart then
			GwentAddon:ChangeState(GwentAddon.states.playerTurn)
		else
			GwentAddon:ChangeState(GwentAddon.states.enemyTurn)
		end
	end
	
end

function Gwent_EventFrame:ADDON_LOADED(ADDON_LOADED)
	if ADDON_LOADED ~= addonName then return end
	
	GwentAddon.playFrame = CreatePlayFrame()
	
	GwentAddon:CreatePopupClass(GwentAddon.playFrame)
	GwentAddon:CreateAbilitieList()
	GwentAddon:CreateCardsClass()
	--GwentAddon:CreateCardsList()
	
	GwentAddon.lists.baseDeck = GwentAddon:CreateTestDeck()
	
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
		
	elseif msg == 'deck' then
		GwentAddon.lists.baseDeck:PrintDeck()
		
	elseif msg == 'duel' then
		
		name = GetUnitName("target", true)
		
		if name == nil or name == GetUnitName("player", false) then
			return
		end
		
		SendAddonMessage(addonName, ""..GwentAddon.messages.challenge.."#"..select(2,UnitRace("player")).."#".. UnitSex("player"), "whisper" , name)
		GwentAddon:ChangeChallenger(name)
		--GwentAddon.cards:DrawStartHand()
		
		for i = 1, 10 do
			table.insert(GwentAddon.lists.playerHand ,GwentAddon.lists.baseDeck:DrawCard())
		end
		
		GwentAddon:PlaceAllCards()
		
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
		
		table.insert(GwentAddon.lists.playerHand, GwentAddon:CreateCard(nr, GwentAddon.cards))
		GwentAddon:PlaceAllCards()
	
	elseif string.find(msg, "scale") then
		local scale = string.match(msg, "scale (%d*%.?%d*)")
		
		GwentAddon.playFrame:SetScale(scale)
	
	elseif msg == 'log' then
		SendAddonMessage(addonName, GwentAddon.messages.logout, "whisper" , GwentAddon.challengerName)
	elseif msg == 'center' then
		print("centering")
		GwentAddon.playFrame:ClearAllPoints()
		GwentAddon.playFrame:SetPoint("center", UIParent)
		GwentAddon.playFrame:Show()
	else
	
		GwentAddon.playFrame:Show()
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd




