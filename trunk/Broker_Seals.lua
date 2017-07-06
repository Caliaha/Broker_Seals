Broker_Seals = LibStub("AceAddon-3.0"):NewAddon("Broker_Seals", "AceConsole-3.0", "AceEvent-3.0")

local LQT = LibStub("LibQTip-1.0")

local ORDERHALLSEALEXCLUSION = { }
ORDERHALLSEALEXCLUSION["DEATH KNIGHT"] = true
ORDERHALLSEALEXCLUSION["WARLOCK"] = true
ORDERHALLSEALEXCLUSION["WARRIOR"] = true

Broker_Seals.LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_Seals", {
 type = "data source",
 label = "Broker_Seals",
 icon = "Interface\\Icons\\inv_misc_azsharacoin",
 text = "Seals",
})

local function QC(id)
 if IsQuestFlaggedCompleted(id) then
  return "Yes"
 else
  return "No"
 end
end

function Broker_Seals:OnInitialize()
 local defaults = {
  profile = {
   size = 1,
   older = true,
  },
 }
 self.db = LibStub("AceDB-3.0"):New("Broker_SealsDB", defaults, true)
 self:RegisterChatCommand("bseals", "Chat")
 
 self.currentSeal = 1273
 self.sealOrder = { "Seal of Broken Fate", "Seal of Inevitable Fate", "Seal of Tempered Fate", "Warforged Seal", "Mogu Rune of Fate", "Elder Charm" }
 self.seals = { }
 self.seals["Seal of Broken Fate"] = 1273
 self.seals["Seal of Tempered Fate"] =  994
 self.seals["Seal of Inevitable Fate"] = 1129
 self.seals["Elder Charm"] = 697
 self.seals["Mogu Rune of Fate"] = 752
 self.seals["Warforged Seal"] = 776
 
end


function Broker_Seals:OnEnable()
 self:RegisterEvent("CHAT_MSG_CURRENCY", "Update")
 self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
 self:RegisterEvent("BONUS_ROLL_RESULT", "Update")
 self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "Update")
end

function Broker_Seals:OnDisable()
 self:UnregisterAllEvents()
end

function Broker_Seals:Count()
 local QuestIDs = { 43892, 43893, 43894, 43895, 43896, 43897, 43510, 47851, 47864, 47865 }
 local count = 0
 
 for key, value in ipairs(QuestIDs) do
  if (QC(value) == "Yes") then
   count = count + 1
  end
 end
 return count
end

function Broker_Seals:Update()
 local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(self.currentSeal)
 if (self.db.profile.size == 1) then
  Broker_Seals.LDB.text = "Total: " .. currentAmount .. "/" .. totalMax .. " Weekly: " .. self:Count() .. "/3"
 elseif (self.db.profile.size == 2) then
  Broker_Seals.LDB.text = currentAmount .. "/" .. totalMax .. ":" .. self:Count() .. "/3"
 else
  Broker_Seals.LDB.text = ""
 end
end

function Broker_Seals.LDB.OnEnter(self)
 local tooltip = LQT:Acquire("Broker_Seals", 4, "LEFT", "RIGHT", "RIGHT", "RIGHT")
 self.tooltip = tooltip
 if _G.TipTac and _G.TipTac.AddModifiedTip then
  _G.TipTac:AddModifiedTip(self.tooltip, true)
 end
 
 local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(Broker_Seals.currentSeal)
 
 tooltip:AddHeader('Type','Rank 1','Rank 2', 'Rank 3')
 tooltip:AddSeparator()
 tooltip:AddLine("Order", QC(43892), QC(43893), QC(43894))
 tooltip:AddLine("Gold", QC(43895), QC(43896), QC(43897))
 tooltip:AddLine("Honor", QC(47851), QC(47864), QC(47865))
 local _, class = UnitClass("player")
 if (not ORDERHALLSEALEXCLUSION[class]) then
  tooltip:AddLine("Class Hall", QC(43510))
 end
 if (Broker_Seals.db.profile.older) then
  tooltip:AddSeparator()
  local header = false
  for key, value in pairs(Broker_Seals.sealOrder) do
   local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(Broker_Seals.seals[value])
   if (currentAmount ~= 0) then
    if (not header) then
	 tooltip:AddHeader('Name', 'Amount')
	 header = true
	end
    tooltip:AddLine(value, currentAmount .. "/" .. totalMax)
   end
  end
 end
 
 tooltip:SmartAnchorTo(self)
 tooltip:Show()
end

function Broker_Seals:Chat(input)
 if not input then
  return
 end

 local command, nextposition = self:GetArgs(input, 1, 1)
 
 if (command == "normal") then
  self.db.profile.size = 1
  self:Update()
  return
 end
 if (command == "small") then
  self.db.profile.size = 2
  self:Update()
  return
 end
 --[[if (command == "both") then
  self.db.profile.size = 3
  self:Update()
  return
 end]]--
 if (command == "none") then
  self.db.profile.size = 0
  self:Update()
  return
 end
 
 if (command == "older") then
  if (self.db.profile.older) then
   self.db.profile.older = false
  else
   self.db.profile.older = true
  end
  return
 end
 
 local _, currentAmount, _, _, _, totalMax = GetCurrencyInfo(self.currentSeal)
 self:Print("Seals - " .. "Total: " .. currentAmount .. "/" .. totalMax .. " Weekly: " .. self:Count() .. "/3")
 self:Print("Type Rank 1 Rank 2 Rank 3")
 self:Print("Gold: " .. QC(43895) .. " " .. QC(43896) .. " " .. QC(43897))
 self:Print("Order: " .. QC(43892) .. " " .. QC(43893) .. " " .. QC(43895))
 self:Print("Honor: " .. QC(47851) .. " " .. QC(47864) .. " " .. QC(47865))
 local _, class = UnitClass("player")
 if (not ORDERHALLSEALEXCLUSION[class]) then
  self:Print("Class Hall", QC(43510))
 end
 
 --self:Print("Bunker: ", QC(36058))
 if (self.db.profile.older) then
  for key, value in pairs(self.sealOrder) do
   local _, currentAmount, _, _, _, totalMax = GetCurrencyInfo(self.seals[value])
   if (currentAmount ~= 0) then
    self:Print(value, currentAmount .. "/" .. totalMax)
   end
  end
 end
end

function Broker_Seals.LDB.OnLeave(self)
 LQT:Release(self.tooltip)
 self.tooltip = nil
end
