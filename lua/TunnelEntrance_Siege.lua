
/*
    function TunnelEntrance:DestroyOther()
    for _, tunnelent in ipairs( GetEntitiesForTeam("TunnelEntrance", 2)) do
        if tunnelent:GetOwner() == self:GetOwner() and tunnelent ~= self then
        DestroyEntity(tunnelent)
        end
    end
end

    function TunnelEntrance:GetMaxLevel()
    return 100
    end
    
    function TunnelEntrance:OnCreatedByGorge(gorge)
     
      // if not self.connected and not self:IsInRangeOfHive() then
      self:DestroyOther()
             local origin = FindFreeSpace(self:GetTeam():GetHive():GetOrigin())
               if origin then
                    local tunnelent = CreateEntity(TunnelEntrance.kMapName, origin, 2)   
                    tunnelent:SetOwner(self:GetOwner())
                    tunnelent:SetConstructionComplete()
                    self:GetOwner():TunnelGood(self:GetOwner())
                 return tunnelent
               end
           self:GetOwner():TunnelFailed(self:GetOwner())
     //  end
        
    
end

*/


function TunnelEntrance:GetMax()

    local orig = kMatureTunnelEntranceHealth
    local bySiege = orig * 2
    local val = Clamp(orig * (GetRoundLengthToSiege()/1) + orig, orig, bySiege)
    self.level = self:GetMaxLevel() * GetRoundLengthToSiege()
 --  self.level = self.level * 
 
  --  local byFive = val * 2
    --local builttime = Clamp(Shared.GetTime() -  self.builtTime, 0, 300)
 --   val = Clamp(val * (builttime/300) + val, val, byFive)
    --self.level = (self.level * 2) * builttime
     --Print("builttime is %s, val is %s", builttime, val)
    return val

end 

function TunnelEntrance:GetMaxA()
    local orig = kMatureTunnelEntranceArmor
    local bySiege = orig * 2
    return Clamp(bySiege * GetRoundLengthToSiege(), orig, bySiege)
end 
function TunnelEntrance:ArtificialLeveling()
  if Server and GetIsTimeUp(self.timeMaturityLastUpdate, 8 )  then
   self:AdjustMaxHealth(self:GetMax())
   self:AdjustMaxArmor(self:GetMaxA())
   end
end

if Server then

    function TunnelEntrance:SuckinEntity(entity)
    
        if entity and entity:GetTeamNumber() == 2 and HasMixin(entity, "TunnelUser") and self.tunnelId then
        
            local tunnelEntity = Shared.GetEntity(self.tunnelId)
            if tunnelEntity then 
            
            local exitA = tunnelEntity:GetExitA()
            local exitB = tunnelEntity:GetExitB()
            local oppositeExit = ((exitA and exitA ~= self) and exitA) or ((exitB and exitB ~= self) and exitB)
               if oppositeExit then
             --   tunnelEntity:MovePlayerToTunnel(entity, self)
              --  entity:SetVelocity(Vector(0, 0, 0))
             local kExitOffset = Vector(0, 0.2, 0)
             entity:SetOrigin( oppositeExit:GetOrigin() + kExitOffset )
                  --Print("derp")
                end
                
                if entity.OnUseGorgeTunnel then
                    entity:OnUseGorgeTunnel()
                end
                 entity:TriggerEffects("tunnel_exit_3D")

            end
            
        end
    
    end
end