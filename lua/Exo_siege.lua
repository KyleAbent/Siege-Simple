Script.Load("lua/StunMixin.lua")

InitMixin(self, StunMixin)

local origscreate = Exo.OnCreate
function Exo:OnCreate()
local origspeed = Exo.GetMaxSpeed
end

function Exo:OnStun()
         if Server then
                local bonewall = CreateEntity(ExoWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end