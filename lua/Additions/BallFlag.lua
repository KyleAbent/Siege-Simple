--Kyle 'Avoca' Abent
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'BallFlag' (ScriptActor)

BallFlag.kMapName = "ballflag"
BallFlag.kModelName = PrecacheAsset("models/dev/dev_sphere.model")
local networkVars =
{
}
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
function BallFlag:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, TeamMixin)
    
end
function BallFlag:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(BallFlag.kModelName)
    
end

if Client then
    
    function DropPack:OnUpdate(deltaTime)
        EquipmentOutline_UpdateModel(self)   
    end 
    
end

function BallFlag:SetExpireTime(func, time)
return
end
function BallFlag:OnTouch(recipient)

       if self:GetIsValidRecipient(recipient) then
        recipient:GiveBall()
        DestroyEntity(self)
        --StartSoundEffectAtOrigin(MedPack.kHealthSound, self:GetOrigin())
        end
    
end

function BallFlag:GetIsValidRecipient(recipient)
	
	--if not recipient:isa("Marine") then
	--	return false
	--end
		
    return recipient:GetIsAlive()
	
end
if Server then

    function BallFlag:OnUpdate(deltaTime)
    
        PROFILE("DropPack:OnUpdate")
    
        ScriptActor.OnUpdate(self, deltaTime)    
        
        -- update fall
        -- update pickup

        local playersNearby = GetEntitiesForTeamWithinXZRange( "Player", self:GetTeamNumber(), self:GetOrigin(), 1.3 )
        Shared.SortEntitiesByDistance(self:GetOrigin(), playersNearby)

        for _, player in ipairs(playersNearby) do
        
            if not player:isa("Commander") and self:GetIsValidRecipient(player) then
            
                self:OnTouch(player)
                DestroyEntity(self)
                break
                
            end
        
        end
        
    end

end

Shared.LinkClassToMap("BallFlag", BallFlag.kMapName, networkVars, false)