Script.Load("lua/StunMixin.lua")

class 'ExoAvoca' (Exo)
ExoAvoca.kMapName = "exoavoca"

local networkVars = {}
AddMixinNetworkVars(StunMixin, networkVars)


local oninit = Exo.OnInitialized
function ExoAvoca:OnInitialized()

oninit(self)

    InitMixin(self, StunMixin)
   self:SetTechId(kTechId.Exo)

end
        function ExoAvoca:GetTechId()
         return kTechId.Exo
    end

function ExoAvoca:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + 8 < Shared.GetTime() 
end


function ExoAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Exo
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end


function ExoAvoca:OnStun()
         if Server then
                local stunwall = CreateEntity(StunWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end

Shared.LinkClassToMap("ExoAvoca", ExoAvoca.kMapName, networkVars)