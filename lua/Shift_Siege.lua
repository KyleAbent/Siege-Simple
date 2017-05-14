--derp

function Shift:GetMinRangeAC()
return ShiftAutoCCMR    
end

local origbuttons = Shift.GetTechButtons
function Shift:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)
  if techId ~= kTechId.ShiftEcho then
 table[4] = kTechId.ShiftEnzyme
  end
 return table

end

local origact = Shift.PerformActivation
function Shift:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.ShiftEnzyme then
    success = self:TriggerEnzyme()
end

return success, true

end

function Shift:TriggerEnzyme()

         if Server then
             local enzyme = CreateEntity(EnzymeCloud.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
         end
              return true     
end