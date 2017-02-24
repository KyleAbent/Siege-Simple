// NS2 - Classic -- Modified for siege ofc -- thanks dragon
// lua\Weapons\Alien\Umbra.lua
//

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/LerkBite.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

Shared.PrecacheSurfaceShader("materials/effects/mesh_effects/view_blood.surface_shader")

local kStructureHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_structure.cinematic")
local kMarineHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_marine.cinematic")

local kCinematic = PrecacheAsset("cinematics/alien/lerk/primal2.cinematic")
local kSound = PrecacheAsset("sound/NS2.fev/alien/lerk/taunt")

class 'Primal' (Ability)

Primal.kMapName = "primal"

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")
local attackEffectMaterial = nil
local kRange = 20

if Client then
    attackEffectMaterial = Client.CreateRenderMaterial()
    attackEffectMaterial:SetMaterial("materials/effects/mesh_effects/view_blood.material")
end

local networkVars =
{
    lastPrimaryAttackTime = "private time"
}

AddMixinNetworkVars(SpikesMixin, networkVars)
local function GetWeaponEffects()
local toreturn = {

           primal_scream =
    {
        primalScreamEffects =
        {
            {cinematic = kCinematic},
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = kSound},
        },    
    
    },
    
    }
    
       return toreturn
end

local function TriggerPrimal(self, lerk)

    local players = GetEntitiesForTeam("Alien", lerk:GetTeamNumber())
    for index, player in ipairs(players) do
        if player:GetIsAlive() and ((player:GetOrigin() - lerk:GetOrigin()):GetLength() < kPrimalScreamRange) then //and not player:GetIsOnFire() then
            if player ~= lerk then
                player:AddEnergy(kPrimalScreamEnergyGain)
                player.primaledID = self:GetParent():GetId()
            end
            if player.PrimalScream  then
                player:PrimalScream(kPrimalScreamDuration)
                player:TriggerEffects("primal")
                player:TriggerEffects("taunt")
            end            
        end
         self:TriggerEffects("taunt")
end

    
end

function Primal:OnCreate()

    Ability.OnCreate(self)
	
   InitMixin(self, SpikesMixin)
	
    self.primaryAttacking = false
    self.lastPrimaryAttackTime = 0
	
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function Primal:GetAnimationGraphName()
    return kAnimationGraph
end

function Primal:GetEnergyCost(player)
    return kPrimalScreamEnergyCost
end

function Primal:GetHUDSlot()
    return 4
end

function Primal:GetAttackDelay()
    return kPrimalScreamROF
end

function Primal:GetLastAttackTime()
    return self.lastPrimaryAttackTime
end

function Primal:GetDeathIconIndex()

    if self.secondaryAttacking then
        return kDeathMessageIcon.Spikes
    else
        return kDeathMessageIcon.Umbra
    end
    
end
function Primal:GetCanScream()
return Shared.GetTime() > self:GetLastAttackTime() + kPrimalScreamROF
end
function Primal:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() and self:GetCanScream() then
        self:TriggerEffects("primal_scream")
        if Server then        
            TriggerPrimal(self, player)
        end
        self:GetParent():DeductAbilityEnergy(self:GetEnergyCost())
        self.lastPrimaryAttackTime = Shared.GetTime()
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function Primal:OnPrimaryAttackEnd()
    
    Ability.OnPrimaryAttackEnd(self)
    self.primaryAttacking = false
    
end

if Client then

    function Primal:TriggerFirstPersonHitEffects(player, target)

        if player == Client.GetLocalPlayer() and target then
            
            local cinematicName = kStructureHitEffect
            if target:isa("Marine") then
                self:CreateBloodEffect(player)        
                cinematicName = kMarineHitEffect
            end
        
            local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            cinematic:SetCinematic(cinematicName)
        
        
        end

    end

    function Primal:CreateBloodEffect(player)
    
        if not Shared.GetIsRunningPrediction() then

            local model = player:GetViewModelEntity():GetRenderModel()

            model:RemoveMaterial(attackEffectMaterial)
            model:AddMaterial(attackEffectMaterial)
            attackEffectMaterial:SetParameter("attackTime", Shared.GetTime())

        end
        
    end

end
function Primal:OnUpdateAnimationInput(modelMixin)

    local abilityString = "umbra"
    local activityString = "none"
    
    if self.attackButtonPressed then
    
        activityString = "primary"
        
    end
   
    modelMixin:SetAnimationInput("ability", abilityString) 
    modelMixin:SetAnimationInput("activity", activityString)
    
end


Shared.LinkClassToMap("Primal", Primal.kMapName, networkVars)