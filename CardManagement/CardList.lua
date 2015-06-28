local addonName, GwentAddon = ...

GwentAddon.CardList = {}

local faction_NORTH = "Northern Realms"
local faction_NEUTRAL = "Neutral"

local ABILITY_Spy = "Spy"
local ABILITY_Bond = "Tight Bond"
local ABILITY_Morale = "Morale Boost"
local ABILITY_Medic = "Medic"
local ABILITY_Command = "Commander's Horn"
local ABILITY_SCORCH = "Scorch"
local ABILITY_Hero = "Immune to special cards"

local function AddNorthCards()
	-----------------------------------------------------------------------------------------------
	-- Northern Realms
	-----------------------------------------------------------------------------------------------
	
	table.insert(GwentAddon.CardList, {
				name = "Foltest, King of Temeria"
				,faction = faction_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest, Lord Commander Of The North"
				,faction = faction_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Steel-forged"
				,faction = faction_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Siegemaster"
				,faction = faction_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Philippa Eilhart"
				,faction = faction_NORTH
				,strength = 10
				,cardType = {melee = false, ranged = true, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Vernon Roche"
				,faction = faction_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Esterad Thyssen"
				,faction = faction_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "John Natalis"
				,faction = faction_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Thaler"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
			name = "Redanian Foot Soldier"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
			name = "Redanian Foot Soldier"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
				,subText = "1/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
				,subText = "2/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
				,subText = "3/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Kaedweni Siege Expert"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Morale
				,texture = "balista"
				,subText = "1/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Kaedweni Siege Expert"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Morale
				,texture = "balista"
				,subText = "2/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Kaedweni Siege Expert"
				,faction = faction_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Morale
				,texture = "balista"
				,subText = "3/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Yarpen Zigrin"
				,faction = faction_NORTH
				,strength = 2
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sigismund Dijkstra"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sheldon Skaggs"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Blue Stripes Commando"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "1/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Blue Stripes Commando"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "2/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Blue Stripes Commando"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "3/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sabrina Gevissig"
				,faction = faction_NORTH
				,strength = 4
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Ves"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siegfried of Denesle"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siegfried of Denesle"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Prince Stennis"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Crinfrid Reavers Dragon Hunter"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "1/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Crinfrid Reavers Dragon Hunter"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "2/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Crinfrid Reavers Dragon Hunter"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
				,subText = "3/3"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Keira Metz"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Dun Banner Medic"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Medic
				,texture = "balista"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Dun Banner Medic"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Medic
				,texture = "balista"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sile de Tansarville"
				,faction = faction_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siege Tower"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siege Tower"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Trebuchet"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Trebuchet"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Ballista"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Ballista"
				,faction = faction_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
				,subText = "2/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Catapult"
				,faction = faction_NORTH
				,strength = 8
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
				,subText = "1/2"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Catapult"
				,faction = faction_NORTH
				,strength = 8
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
				,subText = "2/2"
			})
end

local function AddNeutralCards()
	-----------------------------------------------------------------------------------------------
	-- Neutral
	-----------------------------------------------------------------------------------------------
	
	table.insert(GwentAddon.CardList, {
				name = "Zoltan Chivay"
				,faction = faction_NEUTRAL
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Geralt of Rivia"
				,faction = faction_NEUTRAL
				,strength = 15
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Triss Merigold"
				,faction = faction_NEUTRAL
				,strength = 7
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Vesemir"
				,faction = faction_NEUTRAL
				,strength = 6
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Yennefer of Vengerberg"
				,faction = faction_NEUTRAL
				,strength = 7
				,cardType = {melee = false, ranged = true, siege = false, hero = true, leader = false}
				,ability = ABILITY_Medic
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Dandelion"
				,faction = faction_NEUTRAL
				,strength = 2
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Command
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Cirilla Fiona Elen Rianno"
				,faction = faction_NEUTRAL
				,strength = 15
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Avallac'h"
				,faction = faction_NEUTRAL
				,strength = 0
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Spy
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Emiel Regis Rohellec Terzieff"
				,faction = faction_NEUTRAL
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Villentretenmerth"
				,faction = faction_NEUTRAL
				,strength = 7
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_SCORCH
				,texture = "peasant"
			})
end

function GwentAddon:CreateCardsList()

	GwentAddon.CardList = {}

	AddNorthCards()
	AddNeutralCards()
	
	

	for k, v in ipairs(GwentAddon.CardList) do
		v.Id = k
	end

	
end





