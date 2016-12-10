Script.Load("lua/StunMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")

class 'ExoAvoca' (Exo)
ExoAvoca.kMapName = "exoavoca"

local networkVars = {}
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)

function ExoAvoca:OnCreate()
    Exo.OnCreate(self)
    InitMixin(self, PhaseGateUserMixin)

end


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
function ExoAvoca:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Rocket") then
    
        damageTable.damage = damageTable.damage * 0.7
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end

Shared.LinkClassToMap("ExoAvoca", ExoAvoca.kMapName, networkVars)