Script.Load("lua/Additions/DigestMixin.lua")
local networkVars = {}
AddMixinNetworkVars(DigestMixin, networkVars)

local origcreate = Shade.OnCreate
function Shade:OnCreate()
    origcreate(self)
    InitMixin(self, DigestMixin)
 end
 
  
function Shade:GetMinRangeAC()
return ShadeAutoCCMR     
end

local origbuttons = Shade.GetTechButtons
function Shade:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[4] = kTechId.ShadeHallucination
 table[8] = kTechId.Digest
 return table

end

local origact = Shade.PerformActivation
function Shade:PerformActivation(techId, position, normal, commander)
local success = origact(self, techId, position, normal, commander)


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

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)