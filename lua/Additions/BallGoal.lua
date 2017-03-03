--Kyle 'Avoca' Abent
--Creaste new hive at offset, Explode targethit hive, Teleport offset hive to old offset hive.

function MichaelBayThisBitch(targetHit)

     local who = targetHit
     local where = who:GetOrigin()
     
     if Server then
         if GetGamerules():GetGameStarted() then return end
         
         if targetHit:isa("CommandStructure") then
         local replacementStation = CreateEntity(targetHit:GetMapName(), where + Vector(0,10,0), targetHit:GetTeamNumber() )
         
         if replacementStation then
         
           who:Kill()
           replacementStation:SetConstructionComplete()
           replacementStation:AddTimedCallback(function()  replacementStation:SetOrigin(where) end, 4)
         
         end
         
         else
           who:Kill()
         end

     end

end