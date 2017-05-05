function Armory:GetMinRangeAC()
return ArmoryAutoCCMR 
end
local origlist = Armory.GetItemList
function Armory:GetItemList(forPlayer)
    
    local list = origlist(self, forPlayer)
   
    if self:GetTechId() == kTechId.AdvancedArmory then
    
    list[10] = kTechId.ConcGrenade
     else

       list[6] = kTechId.ConcGrenade
    end
   
    
    return list
    
end
function Armory:GetShouldResupplyPlayer(player)
    if not player:GetIsAlive() then
        return false
    end
    
    
    local isVortexed = self:GetIsVortexed() or ( HasMixin(player, "VortexAble") and player:GetIsVortexed() )
    if isVortexed then
        return false
    end    
   
    
    local inNeed = false
    
    // Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) or (player:GetArmor() < player:GetMaxArmor() ) then
        inNeed = true
    else

        // Do any weapons need ammo?
        for i, child in ientitychildren(player, "ClipWeapon") do
        
            if child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
            
        end
        
    end
    
    if inNeed then
    
        // Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis
        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
        
            if self:GetTimeToResupplyPlayer(player) then
        
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

function Armory:ResupplyPlayer(player)
    
    local resuppliedPlayer = false
               local fullhealth = player:GetHealth() == player:GetMaxHealth()
           local fullarmor = player:GetArmor() == player:GetMaxArmor()
               if not fullhealth or not fullarmor then
               
               if fullhealth then
                if not fullarmor then local addarmoramount = player:GetMaxArmor() * .20 player:AddArmor(addarmoramount) end 
               else 
               player:AddHealth(Armory.kHealAmount, false, true, nil, nil, true) 
               end

           
        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        resuppliedPlayer = true
        /*
        if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
        
            player:RemoveParasite()
            
        end
        */
        
        if player:isa("Marine") and player.poisoned then
        
            player.poisoned = false
            
        end
        
    end
    // Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, false) then
            
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                resuppliedPlayer = true
                
                
                break
                
            end 
                   
        end
        
    end
        
    if resuppliedPlayer then
    
        // Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
        
        // Play effect
        //self:PlayArmoryScan(player:GetId())
    end
end


Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(LevelsMixin, networkVars)
    local origcreate = Armory.OnCreate
    function Armory:OnCreate()
        origcreate(self)
        InitMixin(self, AvocaMixin)
    end

    function Armory:GetMaxLevel()
    return kArmoryLvl
    end
    function Armory:GetAddXPAmount()
    return kArmoryAddXp
    end
    
    
 
Shared.LinkClassToMap("Armory", Armory.kMapName, networkVars)