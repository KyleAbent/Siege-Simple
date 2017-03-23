Script.Load("lua/StunMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Additions/ExoWelder.lua")


class 'ExoSiege' (Exo)
ExoSiege.kMapName = "exosiege"

local networkVars = {}
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)

local kDualWelderModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
local kDualWelderAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")

local kAtomReconstructionTime = 3


function ExoSiege:OnCreate()
    Exo.OnCreate(self)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, LadderMoveMixin)
   

end
local origmodel = Exo.InitExoModel

function ExoSiege:InitExoModel()

    local hasWelders = false
    local modelName = kDualWelderModelName
    local graphName = kDualWelderAnimationGraph
    
  if self.layout == "WelderWelder" then
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

function ExoSiege:InitWeapons()
    local hasWelders = false
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)   
    end    
    
  
        if self.layout == "WelderWelder" then
        weaponHolder:SetWelderWeapons()
        self:SetHUDSlotActive(1)
        hasWelders = true
        end
        
        if hasWelders then
        
        else
        Exo.InitWeapons(self)
        end
    
end
local function HealSelf(self)

  local toheal = false
                for _, proto in ipairs(GetEntitiesForTeamWithinRange("PrototypeLab", 1, self:GetOrigin(), 4)) do
                    
                    if GetIsUnitActive(proto) then
                        toheal = true
                        break
                    end
                    
                end
          --  Print("toheal is %s", toheal)
    if toheal then
    self:SetArmor(self:GetArmor() + kNanoArmorHealPerSecond, true) 
    end
    
end
function ExoSiege:GetCanControl()
    return self.isMoveBlocked and self:GetIsAlive() and  not self.countingDown and not self.concedeSequenceActive
end
local oninit = Exo.OnInitialized
function ExoSiege:OnInitialized()

oninit(self)

    InitMixin(self, StunMixin)
   self:SetTechId(kTechId.Exo)
   self:AddTimedCallback(function() HealSelf(self) return true end, 1) 
end
        function ExoSiege:GetTechId()
         return kTechId.Exo
    end

function ExoSiege:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + 8 < Shared.GetTime() 
end

function ExoSiege:OnGetMapBlipInfo()
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


function ExoSiege:OnStun()
         if Server then
                local stunwall = CreateEntity(StunWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end


Shared.LinkClassToMap("ExoSiege", ExoSiege.kMapName, networkVars)