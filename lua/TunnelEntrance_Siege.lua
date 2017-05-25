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