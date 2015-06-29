local addonName, GwentAddon = ...

--self.list = {}
GwentAddon.popup = {}

local Popup = {}
Popup.__index = Popup
setmetatable(Popup, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Popup.new(parent)
	local self = setmetatable({}, Popup)
	self.parent = parent
	self.frame = self:CreateFrame(parent)
	self.time = 0
	self.showDuration = 2
	
	return self
end

function GwentAddon:CreatePopupClass(parent)
	GwentAddon.popup = Popup(parent)
end

function Popup:CreateFrame(parent)
	frame = CreateFrame("Frame", addonName.."Popup");
	frame:SetFrameLevel(parent:GetFrameLevel()+2)
	frame:ClearAllPoints();
	frame:SetHeight(100);
	frame:SetWidth(300);
	frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      edgeFile = nil,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
	  })
	frame:SetScript("OnUpdate", function() self:OnUpdate() end);
	-- frame:Hide();
	frame:SetPoint("center", parent);
	frame.text = frame:CreateFontString(nil, nil, "PVPInfoTextFont");
	--frame.text:SetDrawLayer("OVERLAY", 7)
	frame.text:SetPoint("topleft", frame);
	frame.text:SetPoint("bottomright", frame);
	--frame.text:SetAllPoints();
	frame.text:SetText("default text");
	
	--frame = 0;
	
	return frame
end
 
function Popup:OnUpdate()
	if (self.time < GetTime() - self.showDuration) then
		local alpha = self.frame:GetAlpha();
		if (alpha ~= 0) then 
			self.frame:SetAlpha(alpha - .01); 
			self.frame.text:SetAlpha(alpha - .01);
		end
		if (aplha == 0) then
			self.frame:Hide();
		end
		
	end
end
 
function Popup:ShowMessage(message, dur)
	self.showDuration = 2
	if dur ~= nil and type(dur) == "number" then
		self.showDuration = dur
	end
	self.frame.text:SetText(message);
	self.frame:SetAlpha(1);
	self.frame.text:SetAlpha(1);
	self.frame:Show();
	self.time = GetTime();
end

function Popup:SetTextLong(message)
	self.showDuration = 4
	self.frame.text:SetText(message);
	self.frame:SetAlpha(1);
	self.frame.text:SetAlpha(1);
	self.frame:Show();
	self.time = GetTime();
end
