local addonName, GwentAddon = ...

GwentAddon.Abilities = {}

--[[
Spy 
- Tight Bond 
- Morale Boost 
- Medic 
- Muster 
- Agile 
- Scorch
]]--

local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local TEXTURE_ICONS = {["path"]="Interface\\GUILDFRAME\\GUILDEMBLEMSLG_01", ["width"]=1024, ["height"]=1024}
local NUM_SIZE_ICON = 64
local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_SPY = {["path"]="Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-14", ["width"]=128, ["height"]=128}

function GwentAddon:CreateAbilities()

	GwentAddon.Abilities = {}

	table.insert(GwentAddon.Abilities, {
				name = "Spy"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilitySpy"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	table.insert(GwentAddon.Abilities, {
				name = "Tight Bond"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityBond"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	table.insert(GwentAddon.Abilities, {
				name = "Morale Boost"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityBoost"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	table.insert(GwentAddon.Abilities, {
				name = "Medic"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityMedic"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	table.insert(GwentAddon.Abilities, {
				name = "Muster"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityMuster"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	table.insert(GwentAddon.Abilities, {
				name = "Agile"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityAgile"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
	
	table.insert(GwentAddon.Abilities, {
				name = "Scorch"
				,isLeader = false
				,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityScorch"
				,coords = {left = 0
							,right = 1
							,top = 0
							,bottom = 1}
			})
			
	for k, v in ipairs(GwentAddon.Abilities) do
		v.Id = k
	end

	
end

function GwentAddon:GetAbilitydataByName(name)
	
	for k, v in pairs(GwentAddon.Abilities) do
		--GwentAddon:DEBUGMessageSent(name .. " - ".. v.name)
		if v.name == name then
			return v
		end
	end
	return nil
end

function GwentAddon:SetAblityIcon(card)

	local ability = GwentAddon:GetAbilitydataByName(card.data.ability)
		
	if ability == nil then return end
	
	local vc = 0
	if card.data.cardType.hero then
		vc = 1
	end
	
	card.iconAbility:SetVertexColor(vc, vc, vc)
	card.abilityBG:Show()
	card.iconAbility:SetTexture(ability.texture)
	card.iconAbility:SetTexCoord(ability.coords.left, ability.coords.right, ability.coords.top, ability.coords.bottom)

end





