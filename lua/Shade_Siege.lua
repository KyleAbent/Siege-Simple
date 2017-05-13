--derp
function Shade:GetMinRangeAC()
return ShadeAutoCCMR     
end

local origbuttons = Shade.GetTechButtons
function Shade:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[4] = kTechId.ShadeHallucination
 
 return table

end

local origact = Shade.PerformActivation
function Shade:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.ShadeHallucination then
    success = self:TriggerHallucination()
end

return success, true

end

function Shade:TriggerHallucination()

         if Server then
             local hallucination = CreateEntity(HallucinationCloud.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
         end
             return true      
end