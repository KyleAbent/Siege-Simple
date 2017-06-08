Script.Load("lua/GlowMixin.lua")

local networkVars = {}

AddMixinNetworkVars(GlowMixin, networkVars)


local function HealSelf(self)


  local toheal = true
  /*
                for _, proto in ipairs(GetEntitiesForTeamWithinRange("PrototypeLab", 1, self:GetOrigin(), 4)) do
                    
                    if GetIsUnitActive(proto) then
                        toheal = true
                        break
                    end
                    
                end
           */
          --  Print("toheal is %s", toheal)
    if toheal then
    self:SetArmor(self:GetArmor() + kNanoArmorHealPerSecond, true) 
    end
    
end

local function SetColor(self)
 
self.color = 1
   if self.layout == "WelderWelder"  then
       self.color = 1
       Print("1")
   elseif self.layout == "FlamerFlamer" then
    self.color = 2
    Print("2")
   elseif self.layout == "MinigunMinigun" then
  self.color = 3
  Print("3")
   elseif self.layout == "RailgunRailgun" then
    self.color = 4
  Print("4")
    end
     Print("color is %s", self.color)
     self:GlowColor(self.color, 120)
     
    return false
end
local oninit = Exosuit.OnInitialized
    function Exosuit:OnInitialized()
    InitMixin(self, GlowMixin)
    oninit(self)
     self:AddTimedCallback(function() HealSelf(self) return true end, 1) 
     
    -- self:AddTimedCallback(function() SetColor(self) return false end, 4)         
    
    end
/*
  function Exosuit:GetUnitNameOverride(viewer)
  
  local unitName = GetDisplayName(self)   
     if self.layout == "WelderWelder"  then
        unitName = string.format(Locale.ResolveString("WelderWelder"))
   elseif self.layout == "FlamerFlamer" then
          unitName = string.format(Locale.ResolveString("FlamerFlamer"))
   elseif self.layout == "MinigunMinigun" then
          unitName = string.format(Locale.ResolveString("MinigunMinigun"))
   elseif self.layout == "RailgunRailgun" then
          unitName = string.format(Locale.ResolveString("RailgunRailgun"))
    end

   return unitName
   end 
*/

   if Server then


 function Exosuit:OnUseDeferred() 
       -- Print("Derp") 
        local player = self.useRecipient 
        self.useRecipient = nil
        
        if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
        
            local weapons = player:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)            
            end

            local exoPlayer = nil

            if self.layout == "MinigunMinigun" then
                exoPlayer = player:GiveDualExo()            
            elseif self.layout == "RailgunRailgun" then
                exoPlayer = player:GiveDualRailgunExo()
            elseif self.layout == "ClawRailgun" then
                exoPlayer = player:GiveClawRailgunExo()
            elseif self.layout == "WelderWelder" then
                exoPlayer = player:GiveDualWelder()
            elseif self.layout == "FlamerFlamer" then
                exoPlayer = player:GiveDualFlamer()
            else
                exoPlayer = player:GiveExo()
            end  

            if exoPlayer then
                           
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end 

                exoPlayer:SetMaxArmor(self:GetMaxArmor())  
                exoPlayer:SetArmor(self:GetArmor())
                exoPlayer:SetFlashlightOn(self:GetFlashlightOn())
                exoPlayer:TransferParasite(self)
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                -- the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                self:TriggerEffects("pickup")
                DestroyEntity(self)
                
            end
            
        end
    
    end
    
    end