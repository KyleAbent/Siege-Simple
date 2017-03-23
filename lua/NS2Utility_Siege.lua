if Server then



    function UpdateAbilityAvailability(forAlien, tierOneTechId, tierTwoTechId, tierThreeTechId)
 return false
end


local function UnlockAbility(forAlien, mapName)
     --   Print("Unlocking ability") 
   -- Print("mapName is %s", mapName)
    if mapName and forAlien:GetIsAlive() then
    --  Print("just checking ya dig ") 
    
        local activeWeapon = forAlien:GetActiveWeapon()

        local tierWeapon = forAlien:GetWeapon(mapName)
        if not tierWeapon then
        
            forAlien:GiveItem(mapName)
          --   Print("GiveItem %s", mapName) 
            if activeWeapon then
                forAlien:SetActiveWeapon(activeWeapon:GetMapName())
            end
            
        end
    
    end

end

function UpdateAvailability(forAlien, tierOneTechId, tierTwoTechId, tierThreeTechId, tierFourTechId, tierFiveTechId)
        

        local team = forAlien:GetTeam()
        if team and team.GetTechTree then
   local t1 = false
   local t2 = false
   local t3 = false
   local t4 = false
   local t5 = false
     
             t1 = GetGamerules():GetAllTech() or (tierOneTechId ~= nil and tierOneTechId ~= kTechId.None and GetHasTech(forAlien, tierOneTechId))
            t2 = GetGamerules():GetAllTech() or (tierTwoTechId ~= nil and tierTwoTechId ~= kTechId.None and GetHasTech(forAlien, tierTwoTechId))
            t3 = GetGamerules():GetAllTech() or (tierThreeTechId ~= nil and tierThreeTechId ~= kTechId.None and GetHasTech(forAlien, tierThreeTechId))
            t4 = GetGamerules():GetAllTech() or (tierFourTechId ~= nil and tierFourTechId ~= kTechId.None and GetHasTech(forAlien, tierThreeTechId))
             t5 = GetGamerules():GetAllTech() or (tierFiveTechId ~= nil and tierFiveTechId ~= kTechId.None and GetHasTech(forAlien, tierThreeTechId))


            if t1 then      
                UnlockAbility(forAlien,  LookupTechData(tierOneTechId, kTechDataMapName))
            end

            if t2 then
                UnlockAbility(forAlien,   LookupTechData(tierTwoTechId, kTechDataMapName))
            end
            
            
            -- 4 and 5 come with 3
              if t3 then
                UnlockAbility(forAlien,   LookupTechData(tierThreeTechId, kTechDataMapName))
               if t4 then
               
               UnlockAbility(forAlien,   LookupTechData(tierFourTechId, kTechDataMapName))
            end
            
            if t5 then
               UnlockAbility(forAlien,   LookupTechData(tierFiveTechId, kTechDataMapName))
            end
            
            end
            
    --Print("t1 is %s", t1)
    --Print("t2 is %s", t2)
    --Print("t3 is %s", t3)
    --Print("t4 is %s", t4)
            
        end
          return false
end

end