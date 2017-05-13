Script.Load("lua/ElectrifyMixin.lua")

local networkVars = {}

AddMixinNetworkVars(ElectrifyMixin, networkVars)

local orig = Extractor.OnInitialized
function Extractor:OnInitialized()

     orig(self)
    InitMixin(self, ElectrifyMixin)
    
end

local origbuttons = Extractor.GetTechButtons
function Extractor:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

   if not self:GetIsElectrified() then
  table[2] = kTechId.ElectrifyStructure
  end
 
 return table

end

if Server then


function Extractor:OnResearchComplete(researchId)

    if researchId == kTechId.ElectrifyStructure then


       self:ElectrifyStructure()
       --Server mismatches client for networkvar and grasping material
        
    end
    
end


end

Shared.LinkClassToMap("Extractor", Extractor.kMapName, addonNetworkVars)
