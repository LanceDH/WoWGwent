local addonName, GwentAddon = ...

GwentAddon.CardList = {}

local DECK_NORTH = "Northern Realms"

local ABILITY_Spy = "Spy"
local ABILITY_Bond = "Tight Bond"
local ABILITY_Morale = "Morale Boost"
local ABILITY_Medic = "Medic"
local ABILITY_Hero = "Immune to special cards"

function GwentAddon:CreateCardsList()

	GwentAddon.CardList = {}

	table.insert(GwentAddon.CardList, {
				name = "Foltest, King of Temeria"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest, Lord Commander Of The North"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Steel-forged"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Siegemaster"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = false, ranged = false, siege = false, hero = false, leader = true}
				,ability = "NYI"
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Philippa Eilhart"
				,deck = DECK_NORTH
				,strength = 10
				,cardType = {melee = false, ranged = true, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Vernon Roche"
				,deck = DECK_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Esterad Thyssen"
				,deck = DECK_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "John Natalis"
				,deck = DECK_NORTH
				,strength = 10
				,cardType = {melee = true, ranged = false, siege = false, hero = true, leader = false}
				,ability = ABILITY_Hero
				,texture = "peasant"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Thaler"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
			name = "Redanian Foot Soldier"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Kaedweni Siege Expert"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Morale
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Yarpen Zigrin"
				,deck = DECK_NORTH
				,strength = 2
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sigismund Dijkstra"
				,deck = DECK_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sheldon Skaggs"
				,deck = DECK_NORTH
				,strength = 4
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Blue Stripes Commando"
				,deck = DECK_NORTH
				,strength = 4
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sabrina Gevissig"
				,deck = DECK_NORTH
				,strength = 4
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Ves"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siegfried of Denesle"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Prince Stennis"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = true, ranged = false, siege = false, hero = false, leader = false}
				,ability = ABILITY_Spy
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Crinfrid Reavers Dragon Hunter"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Keira Metz"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Dun Banner Medic"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Medic
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Sile de Tansarville"
				,deck = DECK_NORTH
				,strength = 5
				,cardType = {melee = false, ranged = true, siege = false, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Siege Tower"
				,deck = DECK_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Trebuchet"
				,deck = DECK_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "peasant"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Ballista"
				,deck = DECK_NORTH
				,strength = 6
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = nil
				,texture = "balista"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Catapult"
				,deck = DECK_NORTH
				,strength = 8
				,cardType = {melee = false, ranged = false, siege = true, hero = false, leader = false}
				,ability = ABILITY_Bond
				,texture = "peasant"
			})

	for k, v in ipairs(GwentAddon.CardList) do
		v.Id = k
	end

	
end





