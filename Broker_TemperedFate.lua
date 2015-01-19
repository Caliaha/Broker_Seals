Broker_TemperedFate = LibStub("AceAddon-3.0"):NewAddon("Broker_TemperedFate", "AceConsole-3.0", "AceEvent-3.0")

local LQT = LibStub("LibQTip-1.0")

Broker_TemperedFate.LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_TemperedFate", {
 type = "data source",
 label = "Broker_TemperedFate",
 icon = "Interface\\Icons\\ability_animusorbs",
 text = "Seals",
})

local function QC(id)
 if IsQuestFlaggedCompleted(id) then
  return "Yes"
 else
  return "No"
 end
end


function Broker_TemperedFate:OnInitialize()
 self:RegisterChatCommand("bseals", "Chat")
end

function Broker_TemperedFate:OnEnable()
 self:RegisterEvent("CHAT_MSG_CURRENCY", "Update")
 self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
end

function Broker_TemperedFate:OnDisable()
 self:UnregisterAllEvents()
end

function Broker_TemperedFate:Count()
 -- 36058 Bunker
 -- 36060 Apexis?
 local QuestIDs = { 36055, 37452, 37453, 36056, 37456, 37457, 36054, 37454, 37455, 36057, 37458, 37459, 36058 }
 local count = 0
 for key, value in ipairs(QuestIDs) do
  if (QC(value) == "Yes") then
   count = count + 1
  end
 end
 return count
end

function Broker_TemperedFate:Update()
 local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(994)
 Broker_TemperedFate.LDB.text = "Seals - " .. "Total: " .. currentAmount .. "/" .. totalMax .. " Weekly: " .. self:Count() .. "/3"
end

function Broker_TemperedFate.LDB.OnEnter(self)
 local tooltip = LQT:Acquire("Broker_TemperedFate", 4, "LEFT", "RIGHT", "RIGHT", "RIGHT")
 self.tooltip = tooltip
 if _G.TipTac and _G.TipTac.AddModifiedTip then
  _G.TipTac:AddModifiedTip(self.tooltip, true)
 end
 
 local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(994)
 
 tooltip:AddHeader('Type','Rank 1','Rank 2', 'Rank 3')
 tooltip:AddSeparator()
 tooltip:AddLine("Apexis", QC(36055), QC(37452), QC(37453))
 tooltip:AddLine("Garrison", QC(36056), QC(37456), QC(37457))
 tooltip:AddLine("Gold", QC(36054), QC(37454), QC(37455))
 tooltip:AddLine("Honor", QC(36057), QC(37458), QC(37459))
 tooltip:AddLine("Bunker", QC(36058))
 tooltip:SmartAnchorTo(self)
 tooltip:Show()
end

function Broker_TemperedFate:Chat()
 local _, currentAmount, _, earnedThisWeek, weeklyMax, totalMax, _, _ = GetCurrencyInfo(994)
 self:Print("Seals - " .. "Total: " .. currentAmount .. "/" .. totalMax .. " Weekly: " .. self:Count() .. "/3")
 self:Print("Type Rank 1 Rank 2 Rank 3")
 self:Print("Apexis: ", QC(36055), QC(37452), QC(37453))
 self:Print("Garrison: " .. QC(36056) .. " " .. QC(37456) .. " " .. QC(37457))
 self:Print("Gold: " .. QC(36054) .. " " .. QC(37454) .. " " .. QC(37455))
 self:Print("Honor: " .. QC(36057) .. " " .. QC(37458) .. " " .. QC(37459))
 self:Print("Bunker: ", QC(36058))
end

function Broker_TemperedFate.LDB.OnLeave(self)
 LQT:Release(self.tooltip)
 self.tooltip = nil
end