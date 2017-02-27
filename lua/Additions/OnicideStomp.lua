Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Gore.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

local kRange = 1.4

class 'OnicideStomp' (Ability)

OnicideStomp.kMapName = "onocide"

-- after kDetonateTime seconds the skulk goes 'boom!'
local kDetonateTime = 2.0
local kXenocideSoundName = PrecacheAsset("sound/NS2.fev/alien/common/xenocide_start")


local networkVars = { }

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
        self.xenocideTimeLeft = kDetonateTime
        
    elseif Client and Client.GetLocalPlayer() == player then

        if not self.xenocideGui then
            self.xenocideGui = GetGUIManager():CreateGUIScript("GUIXenocideFeedback")
        end
    
        self.xenocideGui:TriggerFlash(kDetonateTime)
        player:SetCameraShake(.01, 15, kDetonateTime)
        
    end
    
end

local function CleanUI(self)

    if self.xenocideGui ~= nil then
    
        GetGUIManager():DestroyGUIScript(self.xenocideGui)
        self.xenocideGui = nil
        
    end
    
end
    
function OnicideStomp:OnDestroy()

    Gore.OnDestroy(self)
    
    if Client then
        CleanUI(self)
    end

end

function OnicideStomp:GetDeathIconIndex()
    return kDeathMessageIcon.Xenocide
end

function OnicideStomp:GetEnergyCost(player)

    if not self.xenociding then
        return kXenocideEnergyCost
    else
        return Gore.GetEnergyCost(self, player)
    end
    
end

function OnicideStomp:GetHUDSlot()
    return 4
end

function OnicideStomp:GetRange()
    return kRange
end

function OnicideStomp:OnPrimaryAttack(player)
    
    if player:GetEnergy() >= self:GetEnergyCost() then
    
        if not self.xenociding then

            TriggerXenocide(self, player)
            self.xenociding = true
            
        else
        
            if self.xenocideTimeLeft and self.xenocideTimeLeft < kDetonateTime * 0.8 then
                  local weapon = player:GetWeaponInHUDSlot(1)
                  if weapon then
                  weapon.OnPrimaryAttack(self, player)
                  end
            end
            
        end
        
    end
    
end

local function StopXenocide(self)

    CleanUI(self)
    
    self.xenociding = false

end

function OnicideStomp:OnProcessMove(input)

    Gore.OnProcessMove(self, input)
    
    local player = self:GetParent()
    if self.xenociding then
    
        if player:isa("Commander") then
            StopXenocide(self)
        elseif Server then
        
            CheckForDestroyedEffects( self )        
        
            self.xenocideTimeLeft = math.max(self.xenocideTimeLeft - input.time, 0)
            
            if self.xenocideTimeLeft == 0 and player:GetIsAlive() then
            
                player:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                local hitEntities = GetEntitiesWithMixinWithinRange("Live", player:GetOrigin(), kXenocideRange)
                RadiusDamage(hitEntities, player:GetOrigin(), kXenocideRange, kOnocideDamage, self)
                
                player.spawnReductionTime = 4
                
                player:SetBypassRagdoll(true)

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

    function OnicideStomp:GetDamageType()
    
        if self.xenocideTimeLeft == 0 then
            return kXenocideDamageType
        else
            return kGoreDamageType
        end
        
    end
    
end

Shared.LinkClassToMap("OnicideStomp", OnicideStomp.kMapName, networkVars)