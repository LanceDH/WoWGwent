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

local Cards = {}
Cards.__index = Cards
setmetatable(Cards, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local ABILITY_Spy = "Spy"
local ABILITY_Bond = "Tight Bond"
local ABILITY_Morale = "Morale Boost"
local ABILITY_Medic = "Medic"
local ABILITY_Command = "Commander's Horn"
local ABILITY_SCORCH = "Scorch"
local ABILITY_Hero = "Immune to special cards"



function Cards.new()
	local self = setmetatable({}, Cards)
	self.list = {}
	self.factions = {["north"] = "Northern Realms"
				,["neutral"] = "Neutral"}
	self.typeTextures = {["agile"] = TEXTURE_CUSTOM_PATH.."TypeAgile"
						,["melee"] = TEXTURE_CUSTOM_PATH.."TypeMelee"
						,["ranged"] = TEXTURE_CUSTOM_PATH.."TypeRanged"
						,["siege"] = TEXTURE_CUSTOM_PATH.."TypeSiege"}	

	self.draggedCard = nil
	
	self:CreateCardsList()
	
	return self
end

function GwentAddon:CreateCardsClass()
	GwentAddon.cards = Cards()
end

function Cards:CreateCardsDatalist(name, faction, strength, cardType, ability, texture, subText)
	local data = {name = "Name missing" ,faction = "Faction Missing" ,strength = 0 ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = false} ,ability = nil ,texture = "",subText = nil, changedStrength = 0}
	if name ~= nil then data.name = name end
	if faction ~= nil then data.faction = faction end
	if strength ~= nil and type(strength) == "number" then data.strength = strength end
	if cardType ~= nil and type(cardType) == "table" then data.cardType = cardType end
	if ability ~= nil then data.ability = ability end
	if texture ~= nil then data.texture = texture end
	if subText ~= nil then data.subText = subText end
	
	return data
end

function Cards:AddNorthCards()
	-----------------------------------------------------------------------------------------------
	-- Northern Realms
	-----------------------------------------------------------------------------------------------
	
	table.insert(self.list, self:CreateCardsDatalist("Foltest, King of Temeria", self.factions.north, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, "NYI", "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Foltest, King of Temeria"
				-- ,faction = self.factions.north
				-- ,strength = 0
				-- ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				-- ,ability = "NYI"
				-- ,texture = "peasant"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Foltest, Lord Commander Of The North", self.factions.north, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, "NYI", "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Foltest, Lord Commander Of The North"
				-- ,faction = self.factions.north
				-- ,strength = 0
				-- ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				-- ,ability = "NYI"
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Foltest The Steel-forged", self.factions.north, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, "NYI", "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Foltest The Steel-forged"
				-- ,faction = self.factions.north
				-- ,strength = 0
				-- ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				-- ,ability = "NYI"
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Foltest The Siegemaster", self.factions.north, 0, {melee = false, ranged = false, siege = false, hero = false, leader = true}, "NYI", "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Foltest The Siegemaster"
				-- ,faction = self.factions.north
				-- ,strength = 0
				-- ,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				-- ,ability = "NYI"
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Philippa Eilhart", self.factions.north, 10, {melee = false, ranged = true, siege = false, hero = true, leader = false}, ABILITY_Hero, "peasant"))	
		
	-- table.insert(self.list, {
				-- name = "Philippa Eilhart"
				-- ,faction = self.factions.north
				-- ,strength = 10
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Hero
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Vernon Roche", self.factions.north, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, ABILITY_Hero, "peasant"))	
			
	-- table.insert(self.list, {
				-- name = "Vernon Roche"
				-- ,faction = self.factions.north
				-- ,strength = 10
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Hero
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Esterad Thyssen", self.factions.north, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, ABILITY_Hero, "peasant"))	
	
	-- table.insert(self.list, {
				-- name = "Esterad Thyssen"
				-- ,faction = self.factions.north
				-- ,strength = 10
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Hero
				-- ,texture = "peasant"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("John Natalis", self.factions.north, 10, {melee = true, ranged = false, siege = false, hero = true, leader = false}, ABILITY_Hero, "peasant"))	
	
	-- table.insert(self.list, {
				-- name = "John Natalis"
				-- ,faction = self.factions.north
				-- ,strength = 10
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Hero
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Thaler", self.factions.north, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Spy, "peasant"))	
	
	-- table.insert(self.list, {
				-- name = "Thaler"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Spy
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Redanian Foot Soldier", self.factions.north, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant", "1/2"))
			
	-- table.insert(self.list, {
			-- name = "Redanian Foot Soldier"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "1/2"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Redanian Foot Soldier", self.factions.north, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant", "2/2"))
	
	-- table.insert(self.list, {
			-- name = "Redanian Foot Soldier"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "2/2"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", self.factions.north, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "1/3"))
	
	-- table.insert(self.list, {
				-- name = "Poor Fucking Infantry"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "peasant"
				-- ,subText = "1/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", self.factions.north, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "2/3"))
			
	-- table.insert(self.list, {
				-- name = "Poor Fucking Infantry"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "peasant"
				-- ,subText = "2/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Poor Fucking Infantry", self.factions.north, 1, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "3/3"))
			
	-- table.insert(self.list, {
				-- name = "Poor Fucking Infantry"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "peasant"
				-- ,subText = "3/3"
			-- })

	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", self.factions.north, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Morale, "peasant", "1/3"))
	
	-- table.insert(self.list, {
				-- name = "Kaedweni Siege Expert"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Morale
				-- ,texture = "balista"
				-- ,subText = "1/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", self.factions.north, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Morale, "peasant", "2/3"))
	
	-- table.insert(self.list, {
				-- name = "Kaedweni Siege Expert"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Morale
				-- ,texture = "balista"
				-- ,subText = "2/3"
			-- })

	table.insert(self.list, self:CreateCardsDatalist("Kaedweni Siege Expert", self.factions.north, 1, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Morale, "peasant", "3/3"))
	
	-- table.insert(self.list, {
				-- name = "Kaedweni Siege Expert"
				-- ,faction = self.factions.north
				-- ,strength = 1
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Morale
				-- ,texture = "balista"
				-- ,subText = "3/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Yarpen Zigrin", self.factions.north, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Yarpen Zigrin"
				-- ,faction = self.factions.north
				-- ,strength = 2
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Sigismund Dijkstra", self.factions.north, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Spy, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Sigismund Dijkstra"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Spy
				-- ,texture = "balista"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Sheldon Skaggs", self.factions.north, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Sheldon Skaggs"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", self.factions.north, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "1/3"))
	
	-- table.insert(self.list, {
				-- name = "Blue Stripes Commando"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "1/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", self.factions.north, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "2/3"))
			
	-- table.insert(self.list, {
				-- name = "Blue Stripes Commando"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "2/3"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Blue Stripes Commando", self.factions.north, 4, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "3/3"))
			
	-- table.insert(self.list, {
				-- name = "Blue Stripes Commando"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "3/3"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Sabrina Gevissig", self.factions.north, 4, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Sabrina Gevissig"
				-- ,faction = self.factions.north
				-- ,strength = 4
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Ves", self.factions.north, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Ves"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Siegfried of Denesle", self.factions.north, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant", "1/2"))
	
	-- table.insert(self.list, {
				-- name = "Siegfried of Denesle"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "1/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Siegfried of Denesle", self.factions.north, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant", "2/2"))
	
	-- table.insert(self.list, {
				-- name = "Siegfried of Denesle"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "2/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Prince Stennis", self.factions.north, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Spy, "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Prince Stennis"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Spy
				-- ,texture = "balista"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", self.factions.north, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "1/3"))
	
	-- table.insert(self.list, {
				-- name = "Crinfrid Reavers Dragon Hunter"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "1/3"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", self.factions.north, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "2/3"))
	
	-- table.insert(self.list, {
				-- name = "Crinfrid Reavers Dragon Hunter"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "2/3"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Crinfrid Reavers Dragon Hunter", self.factions.north, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, ABILITY_Bond, "peasant", "3/3"))
			
	-- table.insert(self.list, {
				-- name = "Crinfrid Reavers Dragon Hunter"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "balista"
				-- ,subText = "3/3"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Keira Metz", self.factions.north, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Keira Metz"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Dun Banner Medic", self.factions.north, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Medic, "peasant", "1/2"))
		
	-- table.insert(self.list, {
				-- name = "Dun Banner Medic"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Medic
				-- ,texture = "balista"
				-- ,subText = "1/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Dun Banner Medic", self.factions.north, 5, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Medic, "peasant", "2/2"))
	
	-- table.insert(self.list, {
				-- name = "Dun Banner Medic"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Medic
				-- ,texture = "balista"
				-- ,subText = "2/2"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Sile de Tansarville", self.factions.north, 5, {melee = false, ranged = true, siege = false, hero = false, leader = false}, nil, "peasant"))
		
	-- table.insert(self.list, {
				-- name = "Sile de Tansarville"
				-- ,faction = self.factions.north
				-- ,strength = 5
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Siege Tower", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "1/2"))
	
	-- table.insert(self.list, {
				-- name = "Siege Tower"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "1/2"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Siege Tower", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "2/2"))
			
	-- table.insert(self.list, {
				-- name = "Siege Tower"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "2/2"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Trebuchet", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "1/2"))
		
	-- table.insert(self.list, {
				-- name = "Trebuchet"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "1/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Trebuchet", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "2/2"))
	
	-- table.insert(self.list, {
				-- name = "Trebuchet"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
				-- ,subText = "2/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Ballista", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "1/2"))
	
	-- table.insert(self.list, {
				-- name = "Ballista"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
				-- ,subText = "1/2"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Ballista", self.factions.north, 6, {melee = false, ranged = false, siege = true, hero = false, leader = false}, nil, "peasant", "2/2"))
	
	-- table.insert(self.list, {
				-- name = "Ballista"
				-- ,faction = self.factions.north
				-- ,strength = 6
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "balista"
				-- ,subText = "2/2"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Catapult", self.factions.north, 8, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Bond, "peasant", "1/2"))
		
	-- table.insert(self.list, {
				-- name = "Catapult"
				-- ,faction = self.factions.north
				-- ,strength = 8
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "peasant"
				-- ,subText = "1/2"
			-- })
	
	table.insert(self.list, self:CreateCardsDatalist("Catapult", self.factions.north, 8, {melee = false, ranged = false, siege = true, hero = false, leader = false}, ABILITY_Bond, "peasant", "2/2"))
	
	-- table.insert(self.list, {
				-- name = "Catapult"
				-- ,faction = self.factions.north
				-- ,strength = 8
				-- ,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				-- ,ability = ABILITY_Bond
				-- ,texture = "peasant"
				-- ,subText = "2/2"
			-- })
end

function Cards:AddNeutralCards()
	-----------------------------------------------------------------------------------------------
	-- Neutral
	-----------------------------------------------------------------------------------------------
	
	table.insert(self.list, self:CreateCardsDatalist("Zoltan Chivay", self.factions.neutral, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant"))
	
	-- table.insert(self.list, {
				-- name = "Zoltan Chivay"
				-- ,faction = self.factions.neutral
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Geralt of Rivia", self.factions.neutral, 15, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Geralt of Rivia"
				-- ,faction = self.factions.neutral
				-- ,strength = 15
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Triss Merigold", self.factions.neutral, 7, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Triss Merigold"
				-- ,faction = self.factions.neutral
				-- ,strength = 7
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Vesemir", self.factions.neutral, 6, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Vesemir"
				-- ,faction = self.factions.neutral
				-- ,strength = 6
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Yennefer of Vengerberg", self.factions.neutral, 7, {melee = false, ranged = true, siege = false, hero = true, leader = false}, ABILITY_Medic, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Yennefer of Vengerberg"
				-- ,faction = self.factions.neutral
				-- ,strength = 7
				-- ,cardType = {melee = false, ranged = true, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Medic
				-- ,texture = "peasant"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Dandelion", self.factions.neutral, 2, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_Command, "peasant"))
		
	-- table.insert(self.list, {
				-- name = "Dandelion"
				-- ,faction = self.factions.neutral
				-- ,strength = 2
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_Command
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Cirilla Fiona Elen Rianno", self.factions.neutral, 15, {melee = true, ranged = false, siege = false, hero = true, leader = false}, nil, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Cirilla Fiona Elen Rianno"
				-- ,faction = self.factions.neutral
				-- ,strength = 15
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Avallac'h", self.factions.neutral, 0, {melee = true, ranged = false, siege = false, hero = true, leader = false}, ABILITY_Spy, "peasant"))
		
	-- table.insert(self.list, {
				-- name = "Avallac'h"
				-- ,faction = self.factions.neutral
				-- ,strength = 0
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				-- ,ability = ABILITY_Spy
				-- ,texture = "peasant"
			-- })
		
	table.insert(self.list, self:CreateCardsDatalist("Emiel Regis Rohellec Terzieff", self.factions.neutral, 5, {melee = true, ranged = false, siege = false, hero = false, leader = false}, nil, "peasant"))
		
	-- table.insert(self.list, {
				-- name = "Emiel Regis Rohellec Terzieff"
				-- ,faction = self.factions.neutral
				-- ,strength = 5
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = nil
				-- ,texture = "peasant"
			-- })
			
	table.insert(self.list, self:CreateCardsDatalist("Villentretenmerth", self.factions.neutral, 7, {melee = true, ranged = false, siege = false, hero = false, leader = false}, ABILITY_SCORCH, "peasant"))
			
	-- table.insert(self.list, {
				-- name = "Villentretenmerth"
				-- ,faction = self.factions.neutral
				-- ,strength = 7
				-- ,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				-- ,ability = ABILITY_SCORCH
				-- ,texture = "peasant"
			-- })
end

function Cards:CreateCardsList()
	
	self.list = {}

	
	self:AddNorthCards()
	self:AddNeutralCards()
	
	
	

	for k, v in ipairs(self.list) do
		v.Id = k
	end

	
end

function Cards:GetTypeIcon(card)
	local types = card.data.cardType
	
	if types.melee and types.siege then
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

function Cards:GetCardOfId(id)

	for k, v in ipairs(self.list) do
		if v.Id == tonumber(id) then
			return v
		end
	end
	
	return nil
end

function Cards:CreateCardTypeIcons(card)
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

function Cards:CreateCardOfId(id)

	local cardData = self:GetCardOfId(id)
	
	GwentAddon:DEBUGMessageSent("Trying to create card with id "..id)
	
	if not cardData then
		GwentAddon:DEBUGMessageSent("Could not create card with Id "..id)
		return
	end

	local card = CreateFrame("frame", addonName.."_Card_".._CardNr, GwentAddon.playFrame)
	card.data = cardData
	card.nr = _CardNr
	card.leftSpacing = 0
	card.rightSpacing = 0
	card:SetPoint("topleft", GwentAddon.playFrame, "topleft", 0, 0)
	card:SetHeight(GwentAddon.NUM_CARD_HEIGHT)
	card:SetWidth(GwentAddon.NUM_CARD_WIDTH)
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
	
	card.darken = card:CreateTexture(addonName.."_Card_".._CardNr.."_Darken", "ARTWORK")
	card.darken:SetDrawLayer("ARTWORK", 7)
	card.darken:SetTexture(TEXTURE_CARD_DARKEN)
	card.darken:SetVertexColor(0, 0, 0, 1)
	card.darken:SetPoint("topleft", card, 0, 0)
	card.darken:SetPoint("bottomright", card, 0, 0)
	card.darken:Hide()
	
	card:SetMovable(false)
	card:RegisterForDrag("LeftButton")
	card:SetScript("OnDragStart", function(c) self:StartDraggingCard(c) end)
	card:SetScript("OnDragStop", function(c) self:StopDraggingCard(c) end)
	card:SetScript("OnMouseDown", function(c)  self:SelectForDiscard(c) end)
	--card:SetScript("OnLeave", function(self) GwentAddon.playFrame.cardTooltip:Hide() end)
	card:SetScript("OnEnter", function(c) GwentAddon:SetCardTooltip(c) end)
	card:SetScript("OnLeave", function(c) GwentAddon.playFrame.cardTooltip:Hide() end)
	--card:EnableMouse(false)
	  
	
	local vc = 1
	local font = "GameFontBlack"
	if card.data.cardType.hero then
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
	
	if card.data.ability ~= nil then
		GwentAddon:SetAblityIcon(card)
	end
	
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
	card.strength:SetText(cardData.strength)
	--card.strength:SetTextColor(0,0,0)
	if card.data.cardType.hero then
		--card.strength:SetTextColor(1,1,1)
	end
	  
	self:CreateCardTypeIcons(card)
	  
	_CardNr = _CardNr + 1
	
	
	  
	return card
end

function Cards:SelectForDiscard(card)
	-- only allow during discard phase
	if GwentAddon.currentState ~= GwentAddon.states.playerDiscard and GwentAddon.currentState ~= GwentAddon.states.enemyDoneDiscarding then
		return
	end

	local nr = GwentAddon:NumberInList(card, _InitialDiscardSelected)
	if nr > -1 then
		-- Already selected
		card.darken:Hide()
		table.remove(_InitialDiscardSelected, nr)
	else
		-- Not yet selected
		if #_InitialDiscardSelected < 2 then
			table.insert(_InitialDiscardSelected, card)
			card.darken:Show()
		end
	end
end

function Cards:DiscardSelectedCards() 

	for k, card in ipairs(_InitialDiscardSelected) do
		self:RemoveCardFromHand(card)
	end
	
	local discAmm = #_InitialDiscardSelected
	
	GwentAddon:DestroyCardsInList(_InitialDiscardSelected)
	
	for i = 1, discAmm do
		self:DrawCard()
	end
	
	self:PlaceAllCards()

	GwentPlayFrame.discardButton:Hide()
	
	SendAddonMessage(addonName, GwentAddon.messages.discarded, "whisper" , GwentAddon.challengerName)

	if GwentAddon.currentState == GwentAddon.states.enemyDoneDiscarding then
		GwentAddon:ChangeState(GwentAddon.states.determinStart)
	else
		GwentAddon:ChangeState(GwentAddon.states.waitEnemyDiscard)
	end
	
end

function Cards:RemoveCardFromHand(card)
	local cardToRemove = nil
	for k, v in ipairs(GwentAddon.lists.player.hand) do
		if v.nr == card.nr then
			cardToRemove = k
			break
		end
	end
	
	if cardToRemove ~= nil then
		table.remove(GwentAddon.lists.player.hand, cardToRemove)
	end
	
end

--function Cards:RemoveAll()

--end

function Cards:PlaceAllCards()
	local playerPoints = 0
	GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.player.hand, GwentAddon.playFrame.playerHand)
	playerPoints = playerPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.player.siege, GwentAddon.playFrame.playerSiege)
	playerPoints = playerPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.player.ranged, GwentAddon.playFrame.playerRanged)
	playerPoints = playerPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.player.melee, GwentAddon.playFrame.playerMelee)
	
	local enemyPoints = 0
	-- Place enemy hand
	enemyPoints = enemyPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.enemy.siege, GwentAddon.playFrame.enemySiege)
	enemyPoints = enemyPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.enemy.ranged, GwentAddon.playFrame.enemyRanged)
	enemyPoints = enemyPoints + GwentAddon:PlayerPlaceCardsOnFrame(GwentAddon.lists.enemy.melee, GwentAddon.playFrame.enemyMelee)
	
	GwentAddon:UpdateTotalPoints(playerPoints, enemyPoints)
	GwentAddon:UpdateTotalBorders(playerPoints, enemyPoints)

end

function Cards:UpdateCardSpaceing(card, mouseX, mouseY)
	

	local left, bottom, width, height = card:GetBoundsRect()
	local hleft, hright, htop, hbottom = card:GetHitRectInsets()
	local mouseX, mouseY = GetCursorPosition()
	local s = card:GetEffectiveScale();
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

function Cards:DrawCard()

	local deckCardNr = math.random(#GwentAddon.lists.player.deck)
	table.insert(GwentAddon.lists.player.hand, self:CreateCardOfId(GwentAddon.lists.player.deck[deckCardNr].Id))
	
	table.remove(GwentAddon.lists.player.deck, deckCardNr)
	
	self:PlaceAllCards()
end

function Cards:DrawStartHand()

	for i=1,10 do
		self:DrawCard()
	end
end

function Cards:StartDraggingCard(card)
	-- only allow during player's turn and when card is movable
	if not card:IsMovable() or  GwentAddon.currentState ~= GwentAddon.states.playerTurn then
		return
	end
	
	self.draggedCard = card
	card:StartMoving()
end

function Cards:StopDraggingCard(card)
	-- only allow during player's turn and when card is movable
	if not card:IsMovable() or GwentAddon.currentState ~= GwentAddon.states.playerTurn then 
		return
	end

	local success, area = GwentAddon:DropCardArea(self.draggedCard)
	if success and self.draggedCard  ~= nil then
		self.draggedCard  = nil

		SendAddonMessage(addonName, string.format(GwentAddon.messages.placeInArea, area, card.data.Id), "whisper" , GwentAddon.challengerName)
		
		-- don't end your turn if enemy passed
		if not GwentAddon.enemyPassed then
			GwentAddon:ChangeState(GwentAddon.states.enemyTurn)
			--GwentAddon:IsYourTurn(false)
		end
		
	end

	self.draggedCard  = nil
	card:StopMovingOrSizing()
	self:PlaceAllCards()
	
	

end

function Cards:AddEnemyCard(message)
	--print(message, string.match(message, "(%a+)#(%d+)"))
	local areaType, id = string.match(message, "(%a+)#(%d+)")
	--GwentAddon:DEBUGMessageSent(message .. " - ".. string.match(message, "(%a+)#(%d+)"))
	local card = self:CreateCardOfId(id)
	if areaType == TEXT_SIEGE then
		self:AddCardToNewList(card, GwentAddon.lists.enemy.siege)
	elseif areaType == TEXT_RANGED then
		self:AddCardToNewList(card, GwentAddon.lists.enemy.ranged)
	elseif areaType == TEXT_MELEE then
		self:AddCardToNewList(card, GwentAddon.lists.enemy.melee)
	end
	
	card:SetScript("OnDragStart", function(self) end)
	card:SetScript("OnDragStop", function(self)  end)
	card:SetScript("OnEnter", function(self) GwentAddon:SetCardTooltip(self) end)
	card:SetScript("OnLeave", function(self) GwentAddon.playFrame.cardTooltip:Hide() end)
	
	self:PlaceAllCards()
end

function Cards:AddCardToNewList(card, list)
	
	print((GwentAddon.draggingOver.card == nil and  "nope" or GwentAddon.draggingOver.card:GetName()))
	-- check if it's first card in the list or not
	if GwentAddon.draggingOver.card == nil then

		table.insert(list, card);
	else
	
		local pos = GwentAddon:NumberInList(GwentAddon.draggingOver.card, list)
		-- check if card should be added left or right
		if ( GwentAddon.draggingOver.card.rightSpacing > 0 ) then
			pos = pos + 1
		end
	
		
		table.insert(list, pos, card);

	end
	
	card:SetMovable(false)
	card:SetScript("OnDragStart", function(self) end)
	card:SetScript("OnDragStop", function(self)  end)
	--card:EnableMouse(false)
end