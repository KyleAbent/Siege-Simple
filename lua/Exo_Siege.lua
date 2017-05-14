Script.Load("lua/StunMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Additions/ExoWelder.lua")
Script.Load("lua/GlowMixin.lua")

local networkVars = {     isLockedEjecting = "private boolean", }
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)
AddMixinNetworkVars(GlowMixin, networkVars)

local kDualWelderModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
local kDualWelderAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")



local origcreate = Exo.OnCreate
function Exo:OnCreate()
    origcreate(self)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, LadderMoveMixin)
    self.isLockedEjecting = false
   

end
local function HealSelf(self)


  local toheal = true
  local stack = 1
  
                for _, proto in ipairs(GetEntitiesForTeamWithinRange("PrototypeLab", 1, self:GetOrigin(), 4)) do
                    
                    if GetIsUnitActive(proto) then
                        stack = stack + 1
                    end
                    
                end
           
          --  Print("toheal is %s", toheal)
    if toheal then
    local amt = kNanoArmorHealPerSecond
    amt = Clamp(amt * stack, 1, 3)
    self:SetArmor(self:GetArmor() + amt, true) 
    end
    return true
end

local oninit = Exo.OnInitialized
function Exo:OnInitialized()

oninit(self)
    InitMixin(self, GlowMixin)
    InitMixin(self, StunMixin)
   self:SetTechId(kTechId.Exo)
   self:AddTimedCallback(function() HealSelf(self) return true end, 1) 
end
local origmodel = Exo.InitExoModel

function Exo:InitExoModel()

    local hasWelders = false
    local modelName = kDualWelderModelName
    local graphName = kDualWelderAnimationGraph
    
  if self.layout == "WelderWelder" or self.layout == "FlamerFlamer" then
         modelName = kDualWelderModelName
        graphName = kDualWelderAnimationGraph
        self.hasDualGuns = true
        hasWelders = true
        self:SetModel(modelName, graphName)
    end
    
    
    if hasWelders then 
    else
    origmodel(self)
    end

     
  

  
end
local origweapons = Exo.InitWeapons
function Exo:InitWeapons()
     
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)   
    end    
    
  
        if self.layout == "WelderWelder" then
        weaponHolder:SetWelderWeapons()
        self:SetHUDSlotActive(1)
        return
        elseif self.layout == "FlamerFlamer" then
        weaponHolder:SetFlamerWeapons()
        self:SetHUDSlotActive(1)
        return
        end
        
        

        origweapons(self)

    
end
function Exo:GetCanControl()
    return not self.isLockedEjecting and not self.isMoveBlocked and self:GetIsAlive() and  not self.countingDown and not self.concedeSequenceActive
end

function Exo:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + 8 < Shared.GetTime() 
end

function Exo:OnStun()
         if Server then
                local stunwall = CreateEntity(StunWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end
    
function Exo:EjectExo()

    if self:GetCanEject() then
         
        if Server then
            self:PerformDelayedEject()
        end
    
    end

end
if Server then

    function Exo:PerformDelayedEject()
          self:SetCameraDistance(3)
          if Client then CreateSpinEffect(self) end
          self.isLockedEjecting = true
          self:AddTimedCallback(function() self.isLockedEjecting = false self:SetCameraDistance(0) Exo.PerformEject(self)  end, 1)
    
    end
end

Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars)