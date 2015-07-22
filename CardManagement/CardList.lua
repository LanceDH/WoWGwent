local addonName, GwentAddon = ...

--self.list = {}
GwentAddon.cards = {}

local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_CARD_DARKEN = "Interface\\DialogFrame\\UI-DialogBox-Background"
local TEXTURE_CARD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
local COORDS_SMALLCARD = {["left"]=76/256, ["right"]=244/256, ["top"]=30/512, ["bottom"]=300/512}
local TEXTURE_CUSTOM_PATH = "Interface\\AddOns\\Gwent\\CardTextures\\"
local TEXTURE_CARD_ICONBG = "Interface\\FriendsFrame\\UI-Toast-ToastIcons" 
local _CardNr = 0
local _InitialDiscardSelected = {}
	local TEXT_SIEGE = "siege"
	local TEXT_RANGED = "ranged"
	local TEXT_MELEE = "melee"

local CardList = {}
CardList.__index = CardList
setmetatable(CardList, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

GwentAddon.Card = {}
GwentAddon.Card.__index = GwentAddon.Card
setmetatable(GwentAddon.Card, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local ABILITY_Spy = "Spy"
local ABILITY_Bond = "Tight Bond"
local ABILITY_Morale = "Morale Boost"
local ABILITY_Medic = "Medic"
local ABILITY_Muster = "Muster"
local ABILITY_Agile = "Agile"
local ABILITY_Command = "Commander's Horn"
local ABILITY_SCORCH = "Scorch"
local ABILITY_Hero = "Immune to special CardList"

function GwentAddon.Card.new(id, cardList)
	local self = setmetatable({}, GwentAddon.Card)
	
	self.cardList = cardList
	self.leftSpacing = 0
	self.rightSpacing = 0
	
	self.data = cardList:GetCardDataOfId(id)
	self.frame = self:CreateFrame(id)
	
	if self.data.ability ~= nil then
		GwentAddon:SetAblityIcon(self.frame, self.data)
	end

	return self
end

-- Create the frame for the card
function GwentAddon.Card:CreateFrame()
	local cardData = self.data

	if not cardData then
		return
	end

	local card = CreateFrame("frame", addonName.."_Card_".._CardNr, GwentAddon.playFrame)
	card:SetFrameLevel(GwentAddon.playFrame:GetFrameLevel() + 4) 
	card.data = cardData
	card.nr = _CardNr
	card.leftSpacing = 0
	card.rightSpacing = 0
	card:SetPoint("topleft", GwentAddon.playFrame, "topleft", 0, 0)
	card:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	card:SetWidth(GwentAddon.NUM_CARD_WIDTH)
	card:SetBackdrop({bgFile = nil, --TEXTURE_CARD_BG,
		edgeFile = nil, --TEXTURE_CARD_BORDER,

	  tileSize = 0, edgeSize = 4,
      insets = { left = 0, right = 0, top 
	  = 0, bottom = 0 }
	  })
	  
	GwentAddon:CreateOuterCardShadow(card, 0.5)
	
	card.texture = card:CreateTexture(addonName.."_Card_".._CardNr.."_Texture", "ARTWORK")
	card.texture:SetDrawLayer("ARTWORK", 0)
	card.texture:SetTexture(TEXTURE_CUSTOM_PATH..cardData.texture)
	card.texture:SetTexCoord(COORDS_SMALLCARD.left, COORDS_SMALLCARD.right, COORDS_SMALLCARD.top, COORDS_SMALLCARD.bottom)
	card.texture:SetPoint("topleft", card, 1, -1)
	card.texture:SetPoint("bottomright", card, -1, 1)
	
	card.darken = card:CreateTexture(addonName.."_Card_".._CardNr.."_Darken", "ARTWORK")
	card.darken:SetDrawLayer("ARTWORK", 7)
	card.darken:SetTexture(TEXTURE_CARD_DARKEN)
	card.darken:SetVertexColor(0, 0, 0, 1)
	card.darken:SetPoint("topleft", card, 0, 0)
	card.darken:SetPoint("bottomright", card, 0, 0)
	card.darken:Hide()
	
	card:SetMovable(false)
	card:RegisterForDrag("LeftButton")
	card:SetScript("OnDragStart", function(c) self:StartDragging() end)
	card:SetScript("OnDragStop", function(c) self:StopDragging() end)
	card:SetScript("OnMouseDown", function(c) self:SelectForDiscard(self) end)
	--card:SetScript("OnLeave", function(self) GwentAddon.playFrame.cardTooltip:Hide() end)
	card:SetScript("OnEnter", function(c) GwentAddon:SetCardTooltip(self) end)
	card:SetScript("OnLeave", function(c) GwentAddon.playFrame.cardTooltip:Hide() end)
	--card:EnableMouse(false)
	  
	
	local vc = 1
	local font = "GameFontBlack"
	if self.data.cardType.hero then
		font = "GameFontWhite"
		vc = 0
	end
	
	card.strengthBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_StrengthBG", "ARTWORK")
	card.strengthBG:SetDrawLayer("ARTWORK", 1)
	card.strengthBG:SetTexture(TEXTURE_CARD_ICONBG)
	card.strengthBG:SetVertexColor(vc, vc, vc, .75)
	card.strengthBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	card.strengthBG:SetPoint("topleft", card, 0, 0)
	card.strengthBG:SetHeight(GwentAddon.NUM_CARD_WIDTH/2)
	card.strengthBG:SetWidth(GwentAddon.NUM_CARD_WIDTH/2)
	
	card.abilityBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_AbilityBG", "ARTWORK")
	card.abilityBG:SetDrawLayer("ARTWORK", 1)
	card.abilityBG:SetTexture(TEXTURE_CARD_ICONBG)
	card.abilityBG:SetVertexColor(vc, vc, vc, .75)
	card.abilityBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	card.abilityBG:SetPoint("bottomleft", card)
	card.abilityBG:SetHeight(GwentAddon.NUM_CARD_WIDTH/2)
	card.abilityBG:SetWidth(GwentAddon.NUM_CARD_WIDTH/2)
	card.abilityBG:Hide()
	
	card.iconAbility = card:CreateTexture(addonName.."_Card_".._CardNr.."_AbilityIcon", "ARTWORK")
	card.iconAbility:SetDrawLayer("ARTWORK", 2)
	card.iconAbility:SetPoint("center", card.abilityBG)
	card.iconAbility:SetHeight(GwentAddon.NUM_CARD_WIDTH/2)
	card.iconAbility:SetWidth(GwentAddon.NUM_CARD_WIDTH/2)
	card.iconAbility:SetVertexColor(0, 0, 0)
	
	card.nrTxt = card:CreateFontString(nil, nil, "QuestTitleFontBlackShadow")
	card.nrTxt:SetPoint("bottomright", card)
	card.nrTxt:SetText(card.nr)
	
	
	--card.strengthBG:SetPoint("bottomright", card, -2, 2)
	
	card.strength = card:CreateFontString(nil, nil, font)
	--card.strength:SetDrawLayer("ARTWORK", 1)
	card.strength:SetPoint("topleft", card.strengthBG)
	card.strength:SetPoint("bottomright", card.strengthBG)
	--card.strength:SetPoint("bottomright", card, "bottomright", -2, -7)
	card.strength:SetJustifyH("center")
	card.strength:SetJustifyV("middle")
	card.strength:SetText(cardData.calcStrength)
	--card.strength:SetTextColor(0,0,0)
	if self.data.cardType.hero then
		--card.strength:SetTextColor(1,1,1)
	end
	  
	self:CreateCardTypeIcons(card)
	  
	_CardNr = _CardNr + 1
	
	
	  
	return card
end

-- Create the icon for combat type
function GwentAddon.Card:CreateCardTypeIcons(card)
	local count = 0;
	local vcBG = 1
	local vc = 0
	if self.data.cardType.hero then
		vcBG = 0
		vc = 1
	end
	
	card.iconTypeBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_TypeBG", "ARTWORK")
	card.iconTypeBG:SetDrawLayer("ARTWORK", 1)
	card.iconTypeBG:SetTexture(TEXTURE_CARD_ICONBG)
	card.iconTypeBG:SetVertexColor(vcBG, vcBG, vcBG, .75)
		-- card.iconMeleeBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
	card.iconTypeBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	card.iconTypeBG:SetPoint("left", card)
	card.iconTypeBG:SetHeight(GwentAddon.NUM_CARD_WIDTH/2)
	card.iconTypeBG:SetWidth(GwentAddon.NUM_CARD_WIDTH/2)
		
	card.iconType = card:CreateTexture(addonName.."_Card_".._CardNr.."_Type", "art")
	card.iconType:SetDrawLayer("ARTWORK", 2)
	card.iconType:SetTexture(self.cardList:GetTypeIcon(self))
	card.iconType:SetVertexColor(vc, vc, vc)
	card.iconType:SetWidth(GwentAddon.NUM_CARD_WIDTH*0.5)
	card.iconType:SetHeight(GwentAddon.NUM_CARD_WIDTH*0.5)
	card.iconType:SetPoint("center", card.iconTypeBG)
		-- card.iconMelee:SetPoint("bottomleft", card, "bottomleft", (GwentAddon.NUM_CARD_WIDTH/2)*count, 0)
	count = count + 1

end

-- Update the strength display of a card including buff/debuff color
function GwentAddon.Card:UpdateCardStrength()
	local frame = self.frame
	frame.strength:SetTextColor(0, 0, 0)
	if self.data.cardType.hero then
		frame.strength:SetTextColor(1, 1, 1)
	end
	frame.strength:SetText(self.data.calcStrength)
	
	if ( self.data.calcStrength > self.data.strength ) then -- buffed
		frame.strength:SetTextColor(0.2, 1, 0.2)
	elseif ( self.data.calcStrength < self.data.strength ) then -- nerfed
		frame.strength:SetTextColor(1, 0.7, 0.7)
	end
	
end

-- Select or deselect the card for discard at the start of the game
function GwentAddon.Card:SelectForDiscard()
	-- only allow during discard phase
	if GwentAddon.currentState ~= GwentAddon.states.playerDiscard and GwentAddon.currentState ~= GwentAddon.states.enemyDoneDiscarding then
		return
	end

	local nr = GwentAddon:NumberInList(self, _InitialDiscardSelected)
	if nr > -1 then
		-- Already selected
		self.frame.darken:Hide()
		table.remove(_InitialDiscardSelected, nr)
	else
		-- Not yet selected
		if #_InitialDiscardSelected < 2 then
			table.insert(_InitialDiscardSelected, self)
			self.frame.darken:Show()
		end
	end
end

-- Start dragging the card
function GwentAddon.Card:StartDragging()
	-- only allow during player's turn and when card is movable
	if not self.frame:IsMovable() or  GwentAddon.currentState ~= GwentAddon.states.playerTurn then
		return
	end
	
	self.frame:SetFrameLevel(self.frame:GetFrameLevel() + 1) 
	GwentAddon.cards.draggedCard = self
	self.frame:StartMoving()
end

-- Stop dragging the card and places in new area if needed
function GwentAddon.Card:StopDragging(card)
	-- only allow during player's turn and when card is movable
	if not self.frame:IsMovable() or GwentAddon.currentState ~= GwentAddon.states.playerTurn then 
		return
	end

	local drag = GwentAddon.cards.draggedCard
	
	local success, area, position, list = GwentAddon:DropCardArea(drag)
	if success and drag  ~= nil then
		

		SendAddonMessage(addonName, GwentAddon.messages.placeCard..string.format(GwentAddon.messages.placeInArea, area, self.data.Id, position), "whisper" , GwentAddon.challengerName)
		
		if drag.data.ability ~= nil and drag.data.ability.isOnPlay then
			drag.data.ability.funct(drag, list, GwentAddon.lists.playDeck, position, area)
		end
		
		drag  = nil
		
		-- don't end your turn if enemy passed
		if not GwentAddon.enemyPassed then
			GwentAddon:ChangeState(GwentAddon.states.enemyTurn)
			--GwentAddon:IsYourTurn(false)
		end
		
	end

	self.frame:SetFrameLevel(self.frame:GetFrameLevel() - 1) 
	GwentAddon.cards.draggedCard  = nil
	self.frame:StopMovingOrSizing()
	GwentAddon:PlaceAllCards()
	
	

end

function CardList.new()
	local self = setmetatable({}, CardList)
	self.list = {}
	self.factions = {["north"] = "Northern Realms"
				,["neutral"] = "Neutral"
				,["scoiatael"] = "Scoia’tael"
				,["nilf"] = "Nilfgaardian Empire"
				,["monster"] = "Monster"}
	self.typeTextures = {["agile"] = TEXTURE_CUSTOM_PATH.."TypeAgile"
						,["melee"] = TEXTURE_CUSTOM_PATH.."TypeMelee"
						,["ranged"] = TEXTURE_CUSTOM_PATH.."TypeRanged"
						,["siege"] = TEXTURE_CUSTOM_PATH.."TypeSiege"}	

	self.draggedCard = nil
	
	self:CreateCardsList()
	
	return self
end

function GwentAddon:CreateCardsClass()
	GwentAddon.cards = CardList()
end

function GwentAddon:CreateCard(id, cardList)
	return GwentAddon.Card(id, cardList)
end

-- Create a list containing the data of the card for later access
function CardList:CreateCardsDatalist(name, faction, strength, cardType, ability, texture, subText)
	local data = {name = "Name missing" ,faction = "Faction Missing" ,strength = 0 ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = false} 
					,ability = nil ,texture = "",subText = nil, calcStrength = 0}
	if name ~= nil then data.name = name end
	if faction ~= nil then data.faction = faction end
	if strength ~= nil and type(strength) == "number" then 
		data.strength = strength;
		data.calcStrength = strength;
	end
	if cardType ~= nil and type(cardType) == "table" then data.cardType = cardType end
	if ability ~= nil then data.ability = ability end
	if texture ~= nil then data.texture = texture end
	if subText ~= nil then data.subText = subText end
	
	return data
end

-- Add all the cards to the list and gives them an id
function CardList:CreateCardsList()
	
	self.list = {}

	self:AddNorthCards()
	self:AddScoiataelCards()
	self:AddNilfCards()
	self:AddMonsterCards()
	self:AddNeutralCards()
	

	for k, v in ipairs(self.list) do
		v.Id = k
	end

	
end

-- Adds all the Northern Realms cards
function CardList:AddNorthCards()
	-----------------------------------------------------------------------------------------------
	-- Northern Realms
	-----------------------------------------------------------------------------------------------
	
	local f = self.factions.north
	local t = "BlankNorthren"
	local tl = "Blank"
	
	table.insert(self.list, self:CreateCardsDatalist("Foltest, King of Temeria", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), "Leader01"))
	table.insert(self.list, self:CreateCardsDatalist("Foltest, Lord Commander Of The North", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Foltest The Steel-forged", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Foltest The Siegemaster", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Philippa Eilhart", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Hero), t))	
	table.insert(self.list, self:CreateCardsDatalist("Vernon Roche", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Hero), t))	
	table.insert(self.list, self:CreateCardsDatalist("Esterad Thyssen", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Hero), t))	
	table.insert(self.list, self:CreateCardsDatalist("John Natalis", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Hero), t))	
	table.insert(self.list, self:CreateCardsDatalist("Thaler", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))	
	table.insert(self.list, self:CreateCardsDatalist("Redanian Foot Soldier", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Redanian Foot Soldier", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), "peasant", "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), "peasant", "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), "peasant", "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Morale), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Morale), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Morale), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Yarpen Zigrin", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Sigismund Dijkstra", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Sheldon Skaggs", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Sabrina Gevissig", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Ves", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Siegfried of Denesle", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Siegfried of Denesle", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Prince Stennis", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Keira Metz", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Dun Banner Medic", f, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Dun Banner Medic", f, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Sile de Tansarville", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Siege Tower", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Siege Tower", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Trebuchet", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Trebuchet", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Ballista", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "Balista", "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Ballista", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "Balista", "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Catapult", f, 8, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Catapult", f, 8, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/2"))
end

-- Adds all the Scoia’tael cards
function CardList:AddScoiataelCards()

	-- GwentAddon:GetAbilitydataByName(ABILITY_Medic)
	local f = self.factions.scoiatael
	local t = "BlankScoiatael"
	local tl = "Blank"
	
	table.insert(self.list, self:CreateCardsDatalist("Francesca, Pureblood Elf", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Francesca The Beautiful", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Francesca, Daisy of The Valley", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Francesca, Queen of Dol Blathanna", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Saesenthessis", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Iorveth", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Isengrim Faoiltiarnah", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Morale), t))
	table.insert(self.list, self:CreateCardsDatalist("Eithne", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Healer", f, 0, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Healer", f, 0, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Healer", f, 0, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Riordain", f, 1, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Toruviel", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Elven Skirmisher", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Elven Skirmisher", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Elven Skirmisher", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Dwarven  Skirmisher", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Dwarven  Skirmisher", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Dwarven  Skirmisher", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Ciaran aep Easnillien", f, 3, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t))
	table.insert(self.list, self:CreateCardsDatalist("Vrihedd Brigade Recruit", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Dol Blathanna Archer", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	-- table.insert(self.list, self:CreateCardsDatalist("Hav’caaren Medic", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Smuggler", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Smuggler", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Havekar Smuggler", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Mahakaman Defender", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/5"))
	table.insert(self.list, self:CreateCardsDatalist("Mahakaman Defender", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/5"))
	table.insert(self.list, self:CreateCardsDatalist("Mahakaman Defender", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/5"))
	table.insert(self.list, self:CreateCardsDatalist("Mahakaman Defender", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "4/5"))
	table.insert(self.list, self:CreateCardsDatalist("Mahakaman Defender", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "5/5"))
	table.insert(self.list, self:CreateCardsDatalist("Vrihedd Brigade Veteran", f, 5, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Vrihedd Brigade Veteran", f, 5, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Dennis Cranmer", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Filavandrel", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t))
	table.insert(self.list, self:CreateCardsDatalist("Ida Emean", f, 6, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Yaevinn", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t))
	table.insert(self.list, self:CreateCardsDatalist("Barclay Els", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t))
	table.insert(self.list, self:CreateCardsDatalist("Dol Blathanna Scout", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Dol Blathanna Scout", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Dol Blathanna Scout", f, 6, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Milva", f, 10, {melee = false, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Morale), t))
	
	
end

-- Adds all the Nilfgaardian Empire cards
function CardList:AddNilfCards()
	local f = self.factions.nilf
	local t = "BlankNilfgaardian"
	local tl = "Blank"
	
	table.insert(self.list, self:CreateCardsDatalist("Emhyr var Emreis, His Imperial Majesty", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Emhyr var Emreis, Emperor of Nilfgaard", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Emhyr var Emreis, The White Flame Dancing on the Graves of His Foes", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Emhyr var Emreis, The Relentless", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Tibor Eggebracht", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Letho of Gulet", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Morvran Voorhis", f, 10, {melee = false, ranged = false, siege = true, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Menno Coehoorn", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Siege Technician", f, 0, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t))
	table.insert(self.list, self:CreateCardsDatalist("Etolian Auxiliary Archers", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Etolian Auxiliary Archers", f, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Albrich", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Sweers", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Nausicaa Cavalry Rider", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Nausicaa Cavalry Rider", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Nausicaa Cavalry Rider", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Vreemde", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Rotten Mangonel", f, 3, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Morteisen", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Puttkammer", f, 3, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Impera Brigade Guard", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/4"))
	table.insert(self.list, self:CreateCardsDatalist("Impera Brigade Guard", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/4"))
	table.insert(self.list, self:CreateCardsDatalist("Impera Brigade Guard", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "3/4"))
	table.insert(self.list, self:CreateCardsDatalist("Impera Brigade Guard", f, 3, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "4/4"))
	table.insert(self.list, self:CreateCardsDatalist("Vanhemar", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Vattier de Rideaux", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Rainfarn", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Cynthia", f, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Zerrikanian Fire Scorpion", f, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Young Emmisary", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Young Emmisary", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Bond), t, "2/2"))
	table.insert(self.list, self:CreateCardsDatalist("Renuald Aep Matsen", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Siege Engineer", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Cahir Mawr Dyffryn aep Ceallach", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Fringilla Vigo", f, 6, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Assire var Anahid", f, 6, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Shilard Fitz-Oesterlen", f, 7, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Stefan Skellen", f, 9, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Heavy Zerrikanian Fire Scorpion", f, 10, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Black Infantry Archer", f, 10, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t, "1/2"))
	table.insert(self.list, self:CreateCardsDatalist("Black Infantry Archer", f, 10, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t, "2/2"))
	
	
	
end

-- Adds all the Monster cards
function CardList:AddMonsterCards()
	local f = self.factions.monster
	local t = "BlankMonster"
	local tl = "Blank"
	
	table.insert(self.list, self:CreateCardsDatalist("Eredin, Commander of the Red Riders", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Eredin, Bringer of Death", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Eredin, Destroyer of Worlds", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Eredin, King of The Wild Hunt", f, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, GwentAddon:GetAbilitydataByName("NYI"), tl))
	table.insert(self.list, self:CreateCardsDatalist("Kayran", f, 8, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Leshen", f, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Imlerith", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Draug", f, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Ghoul", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Ghoul", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Ghoul", f, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Nekker", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Nekker", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Nekker", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Wyvern", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Foglet", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Celaeno Harpy", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Gargoyle", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Cockatrice", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Harpy", f, 2, {melee = true, ranged = true, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Agile), t))
	table.insert(self.list, self:CreateCardsDatalist("Endrega", f, 2, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Vampire: Bruxa", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Vampire: Fleder", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Vampire: Garkain", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Vampire: Ekimmara", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Arachas", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "1/3"))
	table.insert(self.list, self:CreateCardsDatalist("Arachas", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "2/3"))
	table.insert(self.list, self:CreateCardsDatalist("Arachas", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t, "3/3"))
	table.insert(self.list, self:CreateCardsDatalist("Botchling", f, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Forktail", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Plague Maiden", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Griffin", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Werewolf", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Frightener", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Ice Giant", f, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Grave Hag", f, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Vampire: Katakan", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Crone: Whispess", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Crone: Brewess", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Crone: Weavess", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Muster), t))
	table.insert(self.list, self:CreateCardsDatalist("Arachas Behemoth", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, t))
	table.insert(self.list, self:CreateCardsDatalist("Fire Elemental", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Fiend", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Earth Elemental", f, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, t))


end

-- Adds all the Neutral cards
function CardList:AddNeutralCards()
	-----------------------------------------------------------------------------------------------
	-- Neutral
	-----------------------------------------------------------------------------------------------
	
	local f = self.factions.neutral
	local t = "Blank"
	
	table.insert(self.list, self:CreateCardsDatalist("Zoltan Chivay", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Geralt of Rivia", f, 15, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Triss Merigold", f, 7, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Vesemir", f, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Yennefer of Vengerberg", f, 7, {melee = false, ranged = true, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Medic), t))
	table.insert(self.list, self:CreateCardsDatalist("Dandelion", f, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Command), t))
	table.insert(self.list, self:CreateCardsDatalist("Cirilla Fiona Elen Rianno", f, 15, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Avallac'h", f, 0, {melee = true, ranged = false, siege = false, hero = true, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_Spy), t))
	table.insert(self.list, self:CreateCardsDatalist("Emiel Regis Rohellec Terzieff", f, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, t))
	table.insert(self.list, self:CreateCardsDatalist("Villentretenmerth", f, 7, {melee = true, ranged = false, siege = false, hero = false, leader = false}, GwentAddon:GetAbilitydataByName(ABILITY_SCORCH), t))
	
end

-- Get the path of the combat type texture
function CardList:GetTypeIcon(card)
	local types = card.data.cardType
	
	if types.melee and types.ranged then
		return self.typeTextures.agile
	elseif types.melee then
		return self.typeTextures.melee
	elseif types.ranged then
		return self.typeTextures.ranged
	elseif types.siege then
		return self.typeTextures.siege
	end

	return nil
end

-- Get all the data of a card using an id
function CardList:GetCardDataOfId(id)

	for k, v in ipairs(self.list) do
		if v.Id == tonumber(id) then
			return v
		end
	end
	
	return nil
end

-- Thing we don't need this?
function CardList:CreateCardTypeIcons(card)
	local count = 0;
	local vcBG = 1
	local vc = 0
	if card.data.cardType.hero then
		vcBG = 0
		vc = 1
	end
	
	card.iconTypeBG = card:CreateTexture(addonName.."_Card_".._CardNr.."_TypeBG", "ARTWORK")
	card.iconTypeBG:SetDrawLayer("ARTWORK", 1)
	card.iconTypeBG:SetTexture(TEXTURE_CARD_ICONBG)
	card.iconTypeBG:SetVertexColor(vcBG, vcBG, vcBG, .75)
		-- card.iconMeleeBG:SetTexCoord(4/32, 28/32, 4/32, 28/32)
	card.iconTypeBG:SetTexCoord(0.3, 0.45,0.1, 0.4)
	card.iconTypeBG:SetPoint("left", card)
	card.iconTypeBG:SetHeight(GwentAddon.NUM_CARD_WIDTH/2)
	card.iconTypeBG:SetWidth(GwentAddon.NUM_CARD_WIDTH/2)
		
	card.iconType = card:CreateTexture(addonName.."_Card_".._CardNr.."_Type", "art")
	card.iconType:SetDrawLayer("ARTWORK", 2)
	card.iconType:SetTexture(self:GetTypeIcon(card))
	card.iconType:SetVertexColor(vc, vc, vc)
	card.iconType:SetWidth(GwentAddon.NUM_CARD_WIDTH*0.5)
	card.iconType:SetHeight(GwentAddon.NUM_CARD_WIDTH*0.5)
	card.iconType:SetPoint("center", card.iconTypeBG)
		-- card.iconMelee:SetPoint("bottomleft", card, "bottomleft", (GwentAddon.NUM_CARD_WIDTH/2)*count, 0)
	count = count + 1

end

-- Discard the selected cards at the beginning of the game
function CardList:RedrawSelectedCards() 

	for k, card in ipairs(_InitialDiscardSelected) do
		self:RemoveCardFromHand(card)
		GwentAddon.lists.playDeck:AddCardById(card.data.Id)
	end
	
	local discAmm = #_InitialDiscardSelected
	
	GwentAddon:DestroyCardsInList(_InitialDiscardSelected)
	
	GwentAddon.lists.playDeck:Shuffle()
	
	for i = 1, discAmm do
		table.insert(GwentAddon.lists.playerHand, GwentAddon.lists.playDeck:DrawCard())
	end
	
	GwentAddon:PlaceAllCards()

	GwentPlayFrame.discardButton:Hide()
	
	SendAddonMessage(addonName, GwentAddon.messages.discarded, "whisper" , GwentAddon.challengerName)

	if GwentAddon.currentState == GwentAddon.states.enemyDoneDiscarding then
		GwentAddon:ChangeState(GwentAddon.states.determinStart)
	else
		GwentAddon:ChangeState(GwentAddon.states.waitEnemyDiscard)
	end
	
end

-- Remove a card from the hand
function CardList:RemoveCardFromHand(card)
	local cardToRemove = nil
	
	for k, v in ipairs(GwentAddon.lists.playerHand) do
		if v.frame.nr == card.frame.nr then
			cardToRemove = k
			break
		end
	end
	
	if cardToRemove ~= nil then
		table.remove(GwentAddon.lists.playerHand, cardToRemove)
	end
	
end

-- Place all the cards in their areas on the board
function GwentAddon:PlaceAllCards()
	local playerPoints = 0
	GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.playerHand, GwentAddon.playFrame.playerHand)
	playerPoints = playerPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.playerSiege, GwentAddon.playFrame.playerSiege)
	playerPoints = playerPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.playerRanged, GwentAddon.playFrame.playerRanged)
	playerPoints = playerPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.playerMelee, GwentAddon.playFrame.playerMelee)
	GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.graveyard, GwentAddon.playFrame.graveyard)
	
	local enemyPoints = 0
	-- Place enemy hand
	enemyPoints = enemyPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.enemySiege, GwentAddon.playFrame.enemySiege)
	enemyPoints = enemyPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.enemyRanged, GwentAddon.playFrame.enemyRanged)
	enemyPoints = enemyPoints + GwentAddon:PlaceCardsOnFrame(GwentAddon.lists.enemyMelee, GwentAddon.playFrame.enemyMelee)
	
	GwentAddon:UpdateTotalPoints(playerPoints, enemyPoints)
	GwentAddon:UpdateTotalBorders(playerPoints, enemyPoints)

end

-- Change the left and right spacing for the card depending if a card is being dragged over
function CardList:UpdateCardSpaceing(card, mouseX, mouseY)
	

	local left, bottom, width, height = card.frame:GetBoundsRect()
	local hleft, hright, htop, hbottom = card.frame:GetHitRectInsets()
	local mouseX, mouseY = GetCursorPosition()
	local s = card.frame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s

	card.leftSpacing = 0
	card.rightSpacing = 0
	
	if mouseX < left + width/2 and mouseX >= left + hleft then
		--print("left card ".. card.nr)
		card.leftSpacing = width/2
		return true
	elseif mouseX > left + width/2  and mouseX <= left +width -hright  then
		card.rightSpacing = width/2
		--print("right card ".. card.nr)
		return true
	end

	return false
end

-- Draw a random card from the deck
-- TODO: Change to random shuffle and draw top card
function CardList:DrawCard()

	local deckCardNr = math.random(#GwentAddon.lists.playDeck)
	table.insert(GwentAddon.lists.playerHand, GwentAddon.Card(GwentAddon.lists.playDeck[deckCardNr].Id, self))--self:CreateCardOfId(GwentAddon.lists.baseDeck[deckCardNr].Id))
	
	table.remove(GwentAddon.lists.playDeck, deckCardNr)
	
	GwentAddon:PlaceAllCards()
end

-- Draw 10 cards as starter hand
function CardList:DrawStartHand()

	for i=1,10 do
		self:DrawCard()
	end
end

-- Add a card for the opponent depending on recieved message
function CardList:AddEnemyCard(message)
	--print(message, string.match(message, "(%a+)#(%d+)"))
	local areaType, id, pos = string.match(message, GwentAddon.messages.placeCard.."#(%a+)#(%d+)#(%d+)")

	--GwentAddon:DEBUGMessageSent(message .. " - ".. string.match(message, "(%a+)#(%d+)"))
	local card = GwentAddon:CreateCard(id, self) --self:CreateCardOfId(id)
	
	
	if areaType == TEXT_SIEGE then
		self:AddCardToNewList(card, "enemySiege", pos)
	elseif areaType == TEXT_RANGED then
		self:AddCardToNewList(card, "enemyRanged", pos)
	elseif areaType == TEXT_MELEE then
		self:AddCardToNewList(card, "enemyMelee", pos)
	end
	
	card.frame:SetScript("OnDragStart", function(self) end)
	card.frame:SetScript("OnDragStop", function(self)  end)
	card.frame:SetScript("OnEnter", function(self) GwentAddon:SetCardTooltip(self) end)
	card.frame:SetScript("OnLeave", function(self) GwentAddon.playFrame.cardTooltip:Hide() end)
	
	--if card.data.ability ~= nil and card.data.ability.isOnPlay then
	--	card.data.ability.funct(card, list, GwentAddon.lists.playDeck)
	--end
	
	GwentAddon:PlaceAllCards()
	
	-- trigger play abilities
	
end

-- Check if a card is being dropped on the left side of the area (for position in list)
local function DroppedOnLeftSideOfArea()
	local left, bottom, width, height = frame:GetBoundsRect()
	local mouseX, mouseY = GetCursorPosition()
	local s = frame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s

	if mouseX > left and mouseX < left + width/2 then
		return true
	end
	
	return false
end

-- Add a card to a new list in a specific position
function CardList:AddCardToNewList(card, name, position)
	
	local list = GwentAddon:GetListByName(name)
	local area = GwentAddon:GetAreaByName(name)
	
	card.frame:SetFrameLevel(area:GetFrameLevel() + 2)
	
	local pos = DroppedOnLeftSideOfArea() and 1 or #list+1
	-- check if it's first card in the list or not
	if GwentAddon.draggingOver.card == nil then
		-- put at position if given, else just throw it in
		
		
		if position ~= nil then
			pos = position
		end
		table.insert(list, pos, card);
		
	else
		pos = GwentAddon:NumberInList(GwentAddon.draggingOver.card, list)
		-- check if card should be added left or right
		if ( GwentAddon.draggingOver.card.rightSpacing > 0 ) then
			pos = pos + 1
		end
	
		
		table.insert(list, pos, card);

		GwentAddon.draggingOver.card = nil
		
	end
	
	card.frame:SetMovable(false)
	card.frame:SetScript("OnDragStart", function(self) end)
	card.frame:SetScript("OnDragStop", function(self)  end)
	--If card has an ability, use it

	--card:EnableMouse(false)
	
	return pos, list
end