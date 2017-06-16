Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Gore.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

local kRange = 1.4

class 'Onocide' (Ability)

Onocide.kMapName = "onocide"

-- after kDetonateTime seconds the skulk goes 'boom!'
local kDetonateTime = 2.0
local kXenocideSoundName = PrecacheAsset("sound/NS2.fev/alien/common/xenocide_start")


local networkVars = 

{
    timeFuelChanged = "private time",
    fuelAtChange = "private float (0 to 1 by 0.01)",
 }
AddMixinNetworkVars(StompMixin, networkVars)
function Onocide:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.timeFuelChanged = 0
    self.fuelAtChange = 1
    self.modelsize = 1
    self.durationofholdingdownmouse = 0

end
function Onocide:SetFuel(fuel)
   self.timeFuelChanged = Shared.GetTime()
   self.fuelAtChange = fuel
end
function Onocide:GetCooldownFraction()
    return 1 - self:GetFuel()
end
function Onocide:GetFuel()
    if self.primaryAttacking then
        return Clamp(self.fuelAtChange - (Shared.GetTime() - self.timeFuelChanged) / kOnocideMaxDuration, 0, 1)
    else
        return Clamp(self.fuelAtChange + (Shared.GetTime() - self.timeFuelChanged) / kOnocideOnoGrowCoolDown, 0, 1)
    end
end

function Onocide:GetEnergyCost()
    return kOnocideEnergyCost
end
local function CheckForDestroyedEffects(self)
    if self.XenocideSoundName and not IsValid(self.XenocideSoundName) then
        self.XenocideSoundName = nil
    end
end
    
local function TriggerXenocide(self, player)

    if Server then
        CheckForDestroyedEffects( self )
        
        if not self.XenocideSoundName then
            self.XenocideSoundName = Server.CreateEntity(SoundEffect.kMapName)
            self.XenocideSoundName:SetAsset(kXenocideSoundName)
            self.XenocideSoundName:SetParent(self)
            self.XenocideSoundName:Start()
        else     
            self.XenocideSoundName:Start()    
        end
        --StartSoundEffectOnEntity(kXenocideSoundName, player)
        
    elseif Client and Client.GetLocalPlayer() == player then

        if not self.xenocideGui then
            self.xenocideGui = GetGUIManager():CreateGUIScript("GUIXenocideFeedback")
        end
    
        self.xenocideGui:TriggerFlash(2)
        player:SetCameraShake(.01, 15, 2)
        
    end
    
end

local function CleanUI(self)

    if self.xenocideGui ~= nil then
    
        GetGUIManager():DestroyGUIScript(self.xenocideGui)
        self.xenocideGui = nil
        
    end
    
end
    
function Onocide:OnDestroy()

    Gore.OnDestroy(self)
    
    if Client then
        CleanUI(self)
    end

end

function Onocide:GetDeathIconIndex()
    return kDeathMessageIcon.Xenocide
end
function Onocide:IsOnCooldown()
     local boolean = self:GetFuel() < 0.9
    -- Print("IsOnCooldown is %s", boolean)
     return boolean
end
function Onocide:GetCanUseOnocide(player)
    local boolean = not self:IsOnCooldown() and not self.secondaryAttacking and not player.charging 
   -- Print("Canuse is %s", boolean)
    return boolean 
end
function Onocide:GetEnergyCost()
    return kOnocideEnergyCost
end

function Onocide:GetHUDSlot()
    return 4
end

function Onocide:GetRange()
    return kRange
end

function Onocide:OnPrimaryAttack(player)
    
     --Print("Umm123")
    if not self.primaryAttacking then
        if player:GetIsOnGround() and self:GetCanUseOnocide(player) and self:GetEnergyCost() < player:GetEnergy() then
                 --Print("Umm")
            player:DeductAbilityEnergy(self:GetEnergyCost())
            
            self:SetFuel( self:GetFuel() ) -- set it now, because it will go down from this point
            self.primaryAttacking = true
            self.xenociding = true 
        end
    end
    
    
end
local function StopXenocide(self)

    CleanUI(self)
    
    self.xenociding = false

end
function Onocide:OnPrimaryAttackEnd(player)
    
    if self.primaryAttacking then 
    
        self:SetFuel( self:GetFuel() ) -- set it now, because it will go up from this point
        self.primaryAttacking = false
        self.xenociding = false 
        StopXenocide(self)

    
    end
    
end

function Onocide:OnProcessMove(input)
   local parent = self:GetParent()
    if self.primaryAttacking then
        
        if self:GetFuel() > 0 then
        
                if  self.durationofholdingdownmouse == 0 then
                  self.durationofholdingdownmouse = Shared.GetTime() 
                  end
                 parent:DeductAbilityEnergy(.7)     
                 
                 if Client and Client.GetLocalPlayer() == parent then
               if not self.xenocideGui then
                self.xenocideGui = GetGUIManager():CreateGUIScript("GUIXenocideFeedback")
               end   
                 self.xenocideGui:TriggerFlash(3)
                 parent:SetCameraShake(.01, 15, 1.5)       
               end 
               
        else  
            self.primaryAttacking = false
            self.durationofholdingdownmouse = 0
               if Shared.GetTime() > self.durationofholdingdownmouse + 3 then
                     TriggerXenocide(self, player)
                     self:ExplodeYo()
                  
            end --shared.
        end -- orig
        
   else
       self.durationofholdingdownmouse = 0
              
              end
              
           

end
function Onocide:ExplodeYo()
    
    local player = self:GetParent()
    if self.xenociding then
    
        if player:isa("Commander") then
            StopXenocide(self)
        elseif Server then
        
            CheckForDestroyedEffects( self )        
            if player:GetIsAlive() then
            
                player:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                local hitEntities = GetEntitiesWithMixinWithinRange("Live", player:GetOrigin(), kXenocideRange)
                local healthScalar = Clamp(player:GetHealthScalar(), 0.3, 1)
                local damage = (kOnocideDamage * healthScalar)
                RadiusDamage(hitEntities, player:GetOrigin(), kXenocideRange, damage, self)
                
                player.spawnReductionTime = 4
                
                player:SetBypassRagdoll(true)
                if Server then CreateEntity(Rupture.kMapName, player:GetOrigin(), 2) end
                player:Kill()
               
                
                if self.XenocideSoundName then
                    self.XenocideSoundName:Stop()
                    self.XenocideSoundName = nil
                end
            end
            if Server and not player:GetIsAlive() and self.XenocideSoundName and self.XenocideSoundName:GetIsPlaying() == true then
                self.XenocideSoundName:Stop()
                self.XenocideSoundName = nil                    
            end    

        elseif Client and not player:GetIsAlive() and self.xenocideGui then
            CleanUI(self)
        end
        
    end
    
end

if Server then

    function Onocide:GetDamageType()
    
            return kXenocideDamageType
        
    end
    
end

Shared.LinkClassToMap("Onocide", Onocide.kMapName, networkVars)