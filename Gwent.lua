local addonName, BGS_TrackerClasses = ...
local AceGUI = LibStub("AceGUI-3.0")



function isInteger(x)
	return math.floor(x)==x
end


function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end


local L_FPS_LoadFrame = CreateFrame("FRAME", "FPS_LoadFrame"); 
FPS_LoadFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
FPS_LoadFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function FPS_LoadFrame:PLAYER_ENTERING_WORLD(loadedAddon)



end


SLASH_GWENTSLASH1 = '/gwent';
local function slashcmd(msg, editbox)
	if msg == 'log' then
		
	elseif msg == 'list' then
		
		--DEFAULT_CHAT_FRAME:AddMessage("0: |cFF" .. text .. text ..text .. "testing|r colors")
		
	elseif msg == 'info' then
	
	
	elseif msg == 'clear' then
	
	
	else
		--if ( not InterfaceOptionsFramePanelContainer.displayedPanel ) then
		--	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL);
		--end
		--InterfaceOptionsFrame_OpenToCategory(addonName) 
	  
   end
end
SlashCmdList["GWENTSLASH"] = slashcmd