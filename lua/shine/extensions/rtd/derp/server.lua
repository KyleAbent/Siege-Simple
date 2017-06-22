/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
Probably easier to have it more condense down - i know how in my head, such as just randomizing
the reward, and the offchance it spawns another with it - rather than definiting every reward - just define the
reward and roll the reward - erm... one day, lol
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"


function Plugin:Initialise()
self.rtd_succeed_cooldown = 90
self.rtdenabled = true
self.rtd_failed_cooldown = self.rtd_succeed_cooldown
self.Users = {}
self:CreateCommands()
self.Enabled = true
self.GameStarted = false

return true
end

function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] ",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[RTD] ", 144, 238, 144, String, Format, ... )
end

function Plugin:AddDelayToPlayer(Player)
 return true
 //self:RollPlayer(Player)
end
function Plugin:RefuelPlayerAmmo(Player)
    local weapons = Player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, true) then
                break
            end 
                   
        end
        
    end
end
function Plugin:RollPlayer(Player)

if Player:GetIsAlive() and Player:GetTeamNumber() == 1 and not Player:isa("Commander") then 
//self:NotifyMarine( nil, "%s Player is an alive marine, not commander. Could be marine, jetpack, or exo. Getting random number.", true, Player:GetName())
   local MarineorJetpackMarineorExoRoll = math.random(1, 3)
    //self:NotifyMarine( nil, "%s Random number calculated, now applying.", true, Player:GetName())

if MarineorJetpackMarineorExoRoll == 1 then
          local WinLoseResHealthArmor = math.random(1,7)
     //self:NotifyMarine( nil, "%s Random number is 1. Checking resource gain qualifications)", true, Player:GetName())
           if WinLoseResHealthArmor == 1 and Player:GetResources() >= 90 then self:RollPlayer(Player) return end //self:NotifyMarine( nil, "%s Resources are 90 or greater. No need to add. ReRolling.", true, Player:GetName()) self:RollPlayer(Player) return end
           if WinLoseResHealthArmor == 1 and Player:GetResources() <= 89 then
           self:AddDelayToPlayer(Player)
           local OnlyGiveUpToThisMuch = 100 - Player:GetResources()
           local GiveResRTD = math.random(9.0, OnlyGiveUpToThisMuch)
           Player:SetResources(Player:GetResources() + GiveResRTD) 
           self:NotifyMarine( nil, "%s won %s resource(s)", true, Player:GetName(), GiveResRTD)
          return
          end //end of WinResLoseres roll 1
            //self:NotifyMarine( nil, "%s roll number 2. Calcualting how much res the player has.", true, Player:GetName()) 
             if WinLoseResHealthArmor == 2 and Player:GetResources() <= 9 then self:RollPlayer(Player) return end //self:NotifyMarine( nil, "%s Player has 9 or less res. No need to remove. ReRolling Player.", true, Player:GetName()) self:RollPlayer(Player)  end
          if WinLoseResHealthArmor == 2 and Player:GetResources() >= 10 then  
             self:AddDelayToPlayer(Player) 
             //self:NotifyMarine( nil, "%s Player has 10 or greater res. Calculating how much to randomly take away. ", true, Player:GetName()) 
             local OnlyRemoveUpToThisMuch = Player:GetResources() 
             local LoseResRTD = math.random(9.0, OnlyRemoveUpToThisMuch) 
             Player:SetResources(Player:GetResources() - LoseResRTD)
             self:NotifyMarine( nil, "%s lost %s resource(s)", true, Player:GetName(),  LoseResRTD)
         return
         end // end of WinLoseResHealthArmor 2
          if WinLoseResHealthArmor == 3 and Player:isa("Exo") then self:RollPlayer(Player) return end
   if WinLoseResHealthArmor == 3 and not Player:isa("Exo") then 
         local playerhealth = Player:GetHealth()
         if playerhealth >= Player:GetMaxHealth() * (90/100) then self:RollPlayer(Player) return end
         if playerhealth <= Player:GetMaxHealth() * (89/100) then 
         self:AddDelayToPlayer(Player) 
         local GainHealth = 0
        GainHealth = Player:GetMaxHealth() - playerhealth
        local HealthToGive = math.random(Player:GetMaxHealth() * (10/100), GainHealth)
        StartSoundEffectAtOrigin(MedPack.kHealthSound, Player:GetOrigin())
        Player:SetHealth(Player:GetHealth() + HealthToGive)
        self:NotifyMarine( nil, "%s gained %s health", true, Player:GetName(), HealthToGive)
        return
        end // end of if player rhealth <=89 then
        end //End of if  WinLoseResHealthArmor == 3 not player is exo then
      if WinLoseResHealthArmor == 4 and Player:isa("Exo") then self:RollPlayer(Player) return end
         if WinLoseResHealthArmor == 4 and not Player:isa("Exo") then
        local playerhealth = Player:GetHealth()
         if playerhealth <= Player:GetMaxHealth() * (10/100) then self:RollPlayer(Player) return end
          if playerhealth >= Player:GetMaxHealth() * (11/100) then
          self:AddDelayToPlayer(Player) 
         local LoseHealth = 0
         LoseHealth = Player:GetHealth() - 1
         local TakeAwayHealth = math.random(Player:GetMaxHealth() * (10/100), LoseHealth)
         Player:SetHealth(Player:GetHealth() - TakeAwayHealth)
         self:NotifyMarine( nil, "%s lost %s health", true, Player:GetName(), TakeAwayHealth)
        return
         end // end of if player rhealth >= 11 then
         end //End of if not player is exo then

   if WinLoseResHealthArmor == 5 then
    //self:NotifyMarine( nil, "%s give armor roll start", true, Player:GetName())
    local playerarmor = Player:GetArmor()
    local playermaxarmor = Player:GetMaxArmor()
        if playerarmor >=  playermaxarmor * (90 / 100 ) then self:RollPlayer(Player) return end
        if playerarmor <=  playermaxarmor * (89 / 100 ) then 
        self:AddDelayToPlayer(Player) 
        local GiveArmor = math.random(playermaxarmor * (10 / 100 ), playermaxarmor)
        Player:SetArmor(playerarmor + GiveArmor)
        self:NotifyMarine( nil, "%s gained %s armor", true, Player:GetName(), math.round(GiveArmor, 1))
        return
        end //end of if player armor <=
         self:NotifyMarine( nil, "%s gained armor roll end", true, Player:GetName())
   end//end of if WinLoseResHealthArmor == 5 then
   if WinLoseResHealthArmor == 6 then
   local playerarmor = Player:GetArmor()
   local playermaxarmor = Player:GetMaxArmor()
       if playerarmor <= playermaxarmor * (10 / 100) then self:RollPlayer(Player) return end
       if playerarmor >= playermaxarmor * (11 / 100) then 
       self:AddDelayToPlayer(Player)
       local LoseArmor = 0
       LoseArmor = Player:GetArmor()
       local TakeAwayArmor = math.random(playerarmor * (10 / 100), LoseArmor)
       Player:SetArmor(playerarmor - TakeAwayArmor)
       self:NotifyMarine( nil, "%s lost %s armor", true, Player:GetName(), math.round(TakeAwayArmor, 1)) 
       return
       end //end of if playerarmor >=
   end//end of WinLoseResHealthArmor == 6
   if WinLoseResHealthArmor == 7 then
   /*
    CreateEntity(Rupture.kMapName, Player:GetOrigin(), 2)
    self:NotifyMarine( nil, "%s has been blinded by rupture", true, Player:GetName())
    */
    self:RollPlayer(Player)
    self:AddDelayToPlayer(Player) 
    return
   /*
     local Amount = math.random(-3.0,10.0)
     if Amount == 0 then self:RollPlayer(Player) return end
     if Amount >=1 then
     self:AddDelayToPlayer(Player) 
     self:NotifyMarine( nil, "%s attained %s credits", true, Player:GetName(), Amount)
    else
    self:NotifyMarine( nil, "%s lost %s credits", true, Player:GetName(), Amount * -1)
    end
     self.CreditUsers[ Player:GetClient() ] = self:GetPlayerCreditsInfo(Player:GetClient()) + Amount
     Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ), Player:GetClient()) 
    return
    */
   end //end of == 7
 end//End of roll 1

if MarineorJetpackMarineorExoRoll == 2 then
             //self:NotifyMarine( nil, "%s Rolled a 3. Determining Qualifications.", true, Player:GetName())
          if Player:isa("Exo") then self:RollPlayer(Player) return end //self:NotifyMarine( Player, "Rolled a 3, though is not eligable. Re-Rolling.") self:RollPlayer(Player)  end  //self:NotifyMarine( nil, "%s Player is an exo and not qualified for roll 3 (yet). ReRolling", true, Player:GetName()) self:RollPlayer(Player)  end 
      //if not Player:isa("Exo") then 
          //self:NotifyMarine( nil, "%s Player is not an exo, so is qualified for roll 3 (Maybe roll 3 WILL have exo alternative later :))", true, Player:GetName())             
           local WeaponRoll = math.random(1, 9) 
          // self:NotifyMarine( nil, "%s Attaining weapon to switch to", true, Player:GetName())       //Destroy the entity so it's not dropped, and can be picked up, which is espcially annoyign with ns2+ autopicking it up, rendering this useless unless deleted
           if WeaponRoll == 1 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("GrenadeLauncher") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) Player:GiveItem(GrenadeLauncher.kMapName) self:NotifyMarine( nil, "%s switched to a GrenadeLauncher", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                     if WeaponRoll == 1 and Player:GetWeaponInHUDSlot(1) == nil then Player:GiveItem(GrenadeLauncher.kMapName) self:NotifyMarine( nil, "%s switched to a GrenadeLauncher", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                     if WeaponRoll == 2 then self:RollPlayer(Player) return end
           if WeaponRoll == 2 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("HeavyRifle") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) Player:GiveItem(HeavyRifle.kMapName) self:NotifyMarine( nil, "%s switched to a HMG.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                      if WeaponRoll == 2 and Player:GetWeaponInHUDSlot(1) == nil then Player:GiveItem(HeavyRifle.kMapName) self:NotifyMarine( nil, "%s switched to a Onifle.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 3 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Flamethrower") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) Player:GiveItem(Flamethrower.kMapName) self:NotifyMarine( nil, "%s switched to a flamethrower.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                      if WeaponRoll == 3 and Player:GetWeaponInHUDSlot(1) == nil then Player:GiveItem(Flamethrower.kMapName) self:NotifyMarine( nil, "%s switched to a flamethrower.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 4 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Rifle") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) Player:GiveItem(Rifle.kMapName) self:NotifyMarine( nil, "%s switched to a rifle.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                      if WeaponRoll == 4 and Player:GetWeaponInHUDSlot(1) == nil then Player:GiveItem(Rifle.kMapName) self:NotifyMarine( nil, "%s switched to a rifle.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 5 and not Player:GetWeaponInHUDSlot(3):isa("Welder") then Player:GiveItem(Welder.kMapName) self:NotifyMarine( nil, "%s switched to a welder.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 6 and not Player:GetWeaponInHUDSlot(3):isa("Axe") then DestroyEntity(Player:GetWeaponInHUDSlot(3)) Player:GiveItem(Axe.kMapName) self:NotifyMarine( nil, "%s switched to a axe.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 7 and Player:GetWeaponInHUDSlot(2) ~= nil and not Player:GetWeaponInHUDSlot(2):isa("Pistol") then DestroyEntity(Player:GetWeaponInHUDSlot(2)) Player:GiveItem(Pistol.kMapName) self:NotifyMarine( nil, "%s switched to a pistol", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                     if WeaponRoll == 7 and Player:GetWeaponInHUDSlot(2) == nil then Player:GiveItem(Pistol.kMapName) self:NotifyMarine( nil, "%s switched to a pistol", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 8 and Player:GetWeaponInHUDSlot(1) ~= nil and not Player:GetWeaponInHUDSlot(1):isa("Shotgun") then DestroyEntity(Player:GetWeaponInHUDSlot(1)) Player:GiveItem(Shotgun.kMapName) self:NotifyMarine( nil, "%s switched to a shotgun.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
                     if WeaponRoll == 8 and Player:GetWeaponInHUDSlot(2) == nil then Player:GiveItem(Shotgun.kMapName) self:NotifyMarine( nil, "%s switched to a shotgun.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
          // if WeaponRoll == 9 then Player:GiveItem(GasGrenade.kMapName) self:NotifyMarine( nil, "%s dropped an active gas grenade.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
          // if WeaponRoll == 10 then Player:GiveItem(ClusterGrenade.kMapName) self:NotifyMarine( nil, "%s dropped an active cluster grenade.", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           //if WeaponRoll == 11 then Player:GiveItem(PulseGrenade.kMapName) self:NotifyMarine( nil, "%s dropped an activepulse grneade", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
           if WeaponRoll == 9 and Player:GetWeaponInHUDSlot(4) == nil then Player:GiveItem(LayMines.kMapName) self:NotifyMarine( nil, "%s attained mines", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
          //self:NotifyMarine( nil, "%s Rolled to switch to a weapon that's already owned. Therefore re-rolling.", true, Player:GetName())
          //if Weaponroll == 13 then Player:DestroyWeapons() self:NotifyMarine( nil, "%s destroyed all held weapons", true, Player:GetName()) self:AddDelayToPlayer(Player) return end
          self:RollPlayer(Player)
          return
      //end// end of player exo
end //end of rol 2  
      if MarineorJetpackMarineorExoRoll == 3 then
      local EffectsRoll = math.random(1,16)
            //self:NotifyMarine( nil, "%s Rolled a 4", true, Player:GetName())
            if EffectsRoll == 1 and Player:isa("Exo") or not Player:GetIsOnGround() then self:RollPlayer(Player) return end //self:NotifyMarine( nil, "%s Not qualified for roll 4. Re-rolling", true, Player:GetName()) self:RollPlayer(Player) return end
            if EffectsRoll == 1 and not Player:isa("Exo") and Player:GetIsOnGround() and not Player:GetIsStunned() then
            local kStunDuration = math.random(1,10)
             self:AddDelayToPlayer(Player)
            Player:SetStun(kStunDuration)
            //Timer: Set Camera distance to third person and back to first person
            //Add stun safeguard to either this roll or rtd in general? prohibit it?
            self:NotifyMarine( nil, "%s stun for %s seconds", true, Player:GetName(), kStunDuration)
           Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.80,Text = "Stunned for %s",Duration = kStunDuration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player ) 
            return 
            end//End of effects roll 1         
            if EffectsRoll == 2 then
            self:AddDelayToPlayer(Player) 
            local kCatPackAmounts = math.random(1,8)
            CreateEntity(CatPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber())
            Shine.ScreenText.Add( 51, {X = 0.20, Y = 0.80,Text = "Catpack: %s",Duration = kCatPackAmounts * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:NotifyMarine( nil, "%s won %s catpacks", true, Player:GetName(), kCatPackAmounts + 1)         
            self:CreateTimer(1, 8, kCatPackAmounts, function () if not Player:GetIsAlive() then self:DestroyTimer(1) self.ScreenText.End(53) return end  CreateEntity(CatPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end )
            return
            end//end of effects roll 2
            if EffectsRoll == 3 then
            self:AddDelayToPlayer(Player) 
            local kNanoShieldAmount = math.random (1, 8)
             Player:ActivateNanoShield()
            self:CreateTimer(2, 8, kNanoShieldAmount, function () if not Player:GetIsAlive() then self:DestroyTimer(2) self.ScreenText.End(53) return end Player:ActivateNanoShield()  end )
            self:NotifyMarine( nil, "%s emits nano %s times", true, Player:GetName(), kNanoShieldAmount + 1)
            Shine.ScreenText.Add( 52, {X = 0.20, Y = 0.80,Text = "Nano: %s",Duration = kNanoShieldAmount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            return
            end//end of effects roll 3
            if EffectsRoll == 4 then
            self:AddDelayToPlayer(Player) 
            local kScanAmount = math.random(1, 4)
            Shine.ScreenText.Add( 53, {X = 0.20, Y = 0.80,Text = "Scans: %s",Duration = kScanAmount * 4,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            CreateEntity(Scan.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
            StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player)
            self:NotifyMarine( nil, "%s won %s scans", true, Player:GetName(), kScanAmount + 1)
            self:CreateTimer(3, 4, kScanAmount, function () if not Player:GetIsAlive() then self:DestroyTimer(3) self.ScreenText.End(53) return end StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player) CreateEntity(Scan.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end )
            return
            end//end of effects roll 3
          /*
            if EffectsRoll == 5 then
            self:NotifyMarine( nil, "%s turning flashlight on/off for 30 seconds", true, Player:GetName())
            self:CreateTimer( self.FlashLightTimer, 1, 30, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists( self.FlashLightTimer ) then self:DestroyTimer( self.FlashLightTimer ) return end 
           Player:SetFlashlightOn(not Player:GetFlashlightOn())
            end )
            self:AddDelayToPlayer(Player) 
            return
            end//end of effects roll 5
         */
            if EffectsRoll == 5 then
            self:AddDelayToPlayer(Player) 
            local  kNanoShieldANDCatPackAmount = math.random(1,4)
            Shine.ScreenText.Add( 55, {X = 0.20, Y = 0.80,Text = "Catpack/Nano: %s",Duration = kNanoShieldANDCatPackAmount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            StartSoundEffectAtOrigin(CatPack.kPickupSound, Player:GetOrigin())
            CreateEntity(CatPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) 
            Player:ActivateNanoShield()
            self:CreateTimer(4, 8, kNanoShieldANDCatPackAmount, function () if not Player:GetIsAlive() then self:DestroyTimer(4) self.ScreenText.End(53) return end CreateEntity(CatPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) Player:ActivateNanoShield()  end )
            self:NotifyMarine( nil, "%s drops a catpack and emits nano %s times)", true, Player:GetName(), kNanoShieldANDCatPackAmount)
            return
            end //end of effects roll 6
            if EffectsRoll == 6 then
            self:NotifyMarine( nil, "%s has been Bonewall-ed", true, Player:GetName(), size) 
            local bonewall = CreateEntity(BoneWall.kMapName, Player:GetOrigin(), 2)    
            StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, Player)
            end//end of effects roll 7
         /*
            if EffectsRoll == 9 then
            Player:SetMarineNoReload(true)
            self:NotifyMarine( nil, "%s does not have to reload for 30 seconds", true, Player:GetName())
            self:CreateTimer( self.MarineNoReloadTimer, 30, 1, 
            function () 
           if not Player:GetIsAlive() then self:DestroyTimer( self.MarineNoReloadTimer ) return end 
            Player:SetMarineNoReload(false)
            end )
            self:AddDelayToPlayer(Player) 
            return
            end//end of effects roll 9
        */
            if EffectsRoll == 7 then
            self:AddDelayToPlayer(Player) 
            local  kWebTimer = math.random(5,30)
            Shine.ScreenText.Add( 56, {X = 0.20, Y = 0.80,Text = "Webbed: %s",Duration = kWebTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:NotifyMarine( nil, "%s is webbed for %s seconds", true, Player:GetName(), kWebTimer)
            Player:SetWebbed(kWebTimer)
            return
            end//end of effects roll 8
          
            if EffectsRoll == 8 then
            self:AddDelayToPlayer(Player) 
            self:NotifyMarine( nil, "%s fell under the effects of a parasite", true, Player:GetName())
            Player:SetParasited()
            return
            end//end of effects roll 9
          /*
            if EffectsRoll == 11 then
            self:NotifyMarine( nil, "%s is becoming paranoid", true, Player:GetName())
            self:CreateTimer( self.FoVTimer, 1, 29, function ()  if not Player:GetIsAlive() and self:TimerExists(  self.FoVTimer ) then self:DestroyTimer( self.FoVTimer ) return end Player:SetFov(Player:GetFov() + 3) end )
            self:CreateTimer( self.FoVRestoreTimer, 31, 1, function () if not Player:GetIsAlive() and self:TimerExists(   self.FoVRestoreTimer ) then self:DestroyTimer( self.FoVRestoreTimer ) return end Player:SetFov(Player:GetFov() - 87) end )
            self:AddDelayToPlayer(Player) 
            return
            end//end of effects roll 11
         */
           if EffectsRoll == 9 then
            self:AddDelayToPlayer(Player) 
           self:NotifyMarine( nil, "%s is being hit by a Slap Bomb", true, Player:GetName())
            self:CreateTimer(5, 0.5, 30, function () if not Player:GetIsAlive() then self:DestroyTimer(5) return end Player:SetVelocity(Player:GetVelocity() + Vector(math.random(-50, 50),math.random(-5, 10),math.random(-50, 50))) end )
            end//end of effectsroll 10
            if EffectsRoll == 11 then
            self:AddDelayToPlayer(Player) 
            local kZeroAmmoTimer = math.random(5,30)
            Shine.ScreenText.Add( 57, {X = 0.20, Y = 0.80,Text = "Zero Ammo: %s",Duration = kZeroAmmoTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:NotifyMarine( nil, "%s Zero ammo for %s seconds", true, Player:GetName(), kZeroAmmoTimer)
            
            self:CreateTimer(6, 1, kZeroAmmoTimer, function () 
            if not Player or not Player:GetIsAlive() then self:DestroyTimer(6) self.ScreenText.End(57) return end
               if Player:GetWeaponInHUDSlot(1) ~= nil then 
                Player:GetWeaponInHUDSlot(1):SetClip(0) 
                end 
                if Player:GetWeaponInHUDSlot(0) ~= nil then 
               Player:GetWeaponInHUDSlot(2):SetClip(0) 
                end  
             end )
             
            return
            end//end of effects roll 5
            if EffectsRoll == 10 then
            self:AddDelayToPlayer(Player) 
            local kNerveGasAmount = math.random(1,8)
            Shine.ScreenText.Add( 58, {X = 0.20, Y = 0.80,Text = "NerveGas: %s", Duration = kNerveGasAmount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
           self:NotifyMarine( nil, "%s won %s NerveGasClouds", true, Player:GetName(), kNerveGasAmount)  
       Player:GiveItem(GasGrenade.kMapName)
      self:CreateTimer(7, 8, kNerveGasAmount, function () if not Player:GetIsAlive() then self:DestroyTimer(7) self.ScreenTextEnd(58) return end Player:GiveItem(GasGrenade.kMapName) end )
      return 
      end // end of effects roll 12
     if EffectsRoll == 11 then
     self:AddDelayToPlayer(Player) 
      local size = math.random(10,200)
      if size == Player.modelsize then self:RollPlayer(Player) return end
     self:NotifyMarine( nil, "Adjusted %s's size %s percent to %s percent", true, Player:GetName(), math.round(Player.modelsize * 100,2), size  ) 
     Player.modelsize = size / 100
     Player:AdjustMaxHealth(Player:GetMaxHealth() * size / 100)
     Player:AdjustMaxArmor(Player:GetMaxArmor() * size / 100)
      return 
      end // end of effects roll 13
      if EffectsRoll == 12 then
           if not Player:isa("JetpackMarine") and not player:isa("Exo") then 
           //  self:RollPlayer(Player) return 
                 self:NotifyMarine( nil, "%s switched to a jetpack", true, Player:GetName())
                 self:AddDelayToPlayer(Player) 
                    local activeWeapon = Player:GetActiveWeapon()
                    local activeWeaponMapName = nil
                    local health = Player:GetHealth()
                    local armor = Player:GetArmor()
                    if activeWeapon ~= nil then
                   activeWeaponMapName = activeWeapon:GetMapName()
                    end
                local jetpackMarine = Player:Replace(JetpackMarine.kMapName, Player:GetTeamNumber(), true)
                  jetpackMarine:SetActiveWeapon(activeWeaponMapName)
                  jetpackMarine:SetHealth(health)
                  jetpackMarine:SetArmor(armor)
                  return
           end
      end // end of effects roll 14
   
   
               if EffectsRoll == 13 then
            self:AddDelayToPlayer(Player) 
            local  healthpacksamount = math.random(1,8)
            Shine.ScreenText.Add( 55, {X = 0.20, Y = 0.80,Text = "MedPacks: %s",Duration = healthpacksamount * 4,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:CreateTimer(9, 4, healthpacksamount, function () if not Player:GetIsAlive() then self:DestroyTimer(9) self.ScreenText.End(53) return end CreateEntity(MedPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber())   end )
            self:NotifyMarine( nil, "%s drops %s medpacks", true, Player:GetName(), healthpacksamount + 1)
            return
            end //end of effects roll 6
            
               if EffectsRoll == 14 then
            self:AddDelayToPlayer(Player) 
            local  ammopacksamount = math.random(1,8)
            Shine.ScreenText.Add( 55, {X = 0.20, Y = 0.80,Text = "Ammopacks: %s",Duration = ammopacksamount * 4,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:CreateTimer(10, 8, ammopacksamount, function () if not Player:GetIsAlive() then self:DestroyTimer(10) self.ScreenText.End(53) return end CreateEntity(AmmoPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber())   end )
            self:NotifyMarine( nil, "%s drops %s ammopacks ", true, Player:GetName(), ammopacksamount + 1)
            return
            end //end of effects roll 6
            
            
                        if EffectsRoll == 15 then
            self:AddDelayToPlayer(Player) 
            local  ammohppacksamount = math.random(1,8)
            CreateEntity(AmmoPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) CreateEntity(MedPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) 
            Shine.ScreenText.Add( 55, {X = 0.20, Y = 0.80,Text = "Healthpack/Ammopack: %s",Duration = ammohppacksamount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
            self:CreateTimer(11, 8, ammohppacksamount, function () if not Player:GetIsAlive() then self:DestroyTimer(11) self.ScreenText.End(53) return end CreateEntity(AmmoPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) CreateEntity(MedPack.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end )
            self:NotifyMarine( nil, "%s drops a healthpack AND ammopack %s times", true, Player:GetName(), ammohppacksamount + 1)
            return
            end //end of effects roll 16
            
            if EffectsRoll == 16 then
          self:AddDelayToPlayer(Player) 
          local kInfAmmoTimer = math.random(8, 64)
          Shine.ScreenText.Add( 54, {X = 0.20, Y = 0.80,Text = "Ammo: %s",Duration = kInfAmmoTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
          self:NotifyMarine( nil, "%s won infinite ammo for %s seconds", true, Player:GetName(), kInfAmmoTimer)
          self:RefuelPlayerAmmo(Player)
          self:CreateTimer(53, 1, kInfAmmoTimer, function () if not Player:GetIsAlive() then self:DestroyTimer(53) self.ScreenText.End(54) return end self:RefuelPlayerAmmo(Player)  end ) 
            end

      end//End of roll 3     
   
end //End of marine roll
 if Player:GetIsAlive() and Player:GetTeamNumber() == 2 and not Player:isa("Commander") then
  //self:NotifyAlien( nil, "%s Player is an alive alien, not commander.", true, Player:GetName())
      local AlienRoll = math.random(1,2)
      //self:NotifyAlien( nil, "%s Random number calculated, now applying.", true, Player:GetName())
  
      if AlienRoll == 1 then
      local WinLoseResHPArmor = math.random(1,7)
     //self:NotifyAlien( nil, "%s Random number is 1. Checking resource gain qualifications)", true, Player:GetName())
              if WinLoseResHPArmor == 1 and Player:GetResources() >= 90 then self:RollPlayer(Player) return end //self:NotifyAlien( nil, "%s Resources are 90 or greater. No need to add. ReRolling.", true, Player:GetName()) self:RollPlayer(Player) return end
              if WinLoseResHPArmor == 1 and Player:GetResources() <= 89 then
              self:AddDelayToPlayer(Player)
              local OnlyGiveUpToThisMuch = 100 - Player:GetResources()
              local GiveResRTD = math.random(10.0, OnlyGiveUpToThisMuch)
              Player:SetResources(Player:GetResources() + GiveResRTD)
              self:NotifyAlien( nil, "%s won %s resource(s)", true, Player:GetName(), GiveResRTD)
              return
              end//WinLoseResHPArmor 1
            //self:NotifyAlien( nil, "%s roll number 2. Calcualting how much res the player has.", true, Player:GetName()) 
             if WinLoseResHPArmor == 2 and Player:GetResources() <= 9 then self:RollPlayer(Player) return end //self:NotifyAlien( nil, "%s Player has 9 or less res. No need to remove. ReRolling Player.", true, Player:GetName()) self:RollPlayer(Player)  end
             if WinLoseResHPArmor == 2 and Player:GetResources() >= 10 then  
             self:AddDelayToPlayer(Player) 
             //self:NotifyAlien( nil, "%s Player has 10 or greater res. Calculating how much to randomly take away. ", true, Player:GetName()) 
             local OnlyRemoveUpToThisMuch = Player:GetResources() 
             local LoseResRTD = math.random(9.0, OnlyRemoveUpToThisMuch)  
             Player:SetResources(Player:GetResources() - LoseResRTD)
             self:NotifyAlien( nil, "%s lost %s resource(s)", true, Player:GetName(),  LoseResRTD)
             return
             end//end of WinLoseResHPArmor 2  
   if WinLoseResHPArmor == 3 then 
         local playerhealth = Player:GetHealth()
         local playermaxhealth = Player:GetMaxHealth()
        if playerhealth >=  playermaxhealth * (90 / 100 ) then self:RollPlayer(Player) return end
        if playerhealth <=  playermaxhealth * (89 / 100 ) then 
         self:AddDelayToPlayer(Player) 
         local GainHealth = Player:GetMaxHealth() - Player:GetHealth()
        local HealthToGive = math.random(playermaxhealth * (10 / 100 ),  GainHealth)
        Player:SetHealth(Player:GetHealth() + HealthToGive)
        self:NotifyAlien( nil, "%s gained %s health", true, Player:GetName(), math.round(HealthToGive,2))
        return
        end // end of if player rhealth <=89 then
   end //End of if WinLoseResHPArmor == 3 then
         if WinLoseResHPArmor == 4  then
        local playerhealth = Player:GetHealth()
        local playermaxhealth = Player:GetMaxHealth()
         if playerhealth <= playermaxhealth * (10 / 100) then self:RollPlayer(Player) return end
          if playerhealth >= playermaxhealth * (11 / 100) then
          self:AddDelayToPlayer(Player) 
         local LoseHealth = 0
         LoseHealth = Player:GetHealth() - 1
         local TakeAwayHealth = math.random(playermaxhealth * (11 / 100), LoseHealth)
         Player:SetHealth(Player:GetHealth() - TakeAwayHealth)
         self:NotifyAlien( nil, "%s lost %s health", true, Player:GetName(), math.round(TakeAwayHealth, 2))
        return
         end // end of if player rhealth >= 11 then
         end //End of if WinLoseResHPArmor == 4 then
   if WinLoseResHPArmor == 5 then
    //self:NotifyAlien( nil, "%s give armor roll start", true, Player:GetName())
    local playerarmor = Player:GetArmor()
    local playermaxarmor = Player:GetMaxArmor()
        if playerarmor >=  playermaxarmor * (90 / 100 ) or Player:isa("Skulk") then self:RollPlayer(Player) return end
        if playerarmor <=  playermaxarmor * (89 / 100 ) then 
        self:AddDelayToPlayer(Player) 
        local GiveArmor = math.random(playermaxarmor * (10 / 100 ), playermaxarmor)
        Player:SetArmor(playerarmor + GiveArmor)
        self:NotifyAlien( nil, "%s gained %s armor", true, Player:GetName(), math.round(GiveArmor, 1))
        return
        end //end of if player armor <=
         //self:NotifyAlien( nil, "%s gained armor roll end", true, Player:GetName())
   end//end of if WinLoseResHPArmor == 5 then
   if WinLoseResHPArmor == 6 then
   local playerarmor = Player:GetArmor()
   local playermaxarmor = Player:GetMaxArmor()
       if playerarmor <= playermaxarmor * (10 / 100) or Player:isa("Skulk") then self:RollPlayer(Player) return end
       if playerarmor >= playermaxarmor * (11 / 100) then 
       self:AddDelayToPlayer(Player) 
       local LoseArmor = 0
       LoseArmor = Player:GetArmor()
       local TakeAwayArmor = math.random(playermaxarmor * (11 / 100), LoseArmor)
       Player:SetArmor(playerarmor - TakeAwayArmor)
       self:NotifyAlien( nil, "%s lost %s armor", true, Player:GetName(), math.round(TakeAwayArmor, 1))
       return
       end //end of if playerarmor >=
   end//end of WinLoseResHPArmor 6
      if WinLoseResHPArmor == 7 then
      self:RollPlayer(Player)
   
   end //end of == 7
end//Alien roll 1
     if AlienRoll == 2 then 
      local EffectsRoll = math.random(1,16)
      if EffectsRoll == 1 then 
      self:AddDelayToPlayer(Player) 
      local amount = math.random(1,8)
      Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "EnzymeCloud: %s",Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s enzyme clouds", true, Player:GetName(), amount + 1)  
      Player:GiveItem(EnzymeCloud.kMapName)
      self:CreateTimer(12, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(12) self.ScreenText.End(64) return end Player:GiveItem(EnzymeCloud.kMapName) end ) 

      return 
      end//end of effects roll 1
      if EffectsRoll == 2 then
      self:AddDelayToPlayer(Player) 
      local kUmbraTimer = math.random(8, 64)
     Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "Umbra: %s",Duration = kUmbraTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won umbra for %s seconds", true, Player:GetName(), kUmbraTimer)
      Player:SetHasUmbra(true, 2)
      self:CreateTimer(13, 1, kUmbraTimer, function () if not Player:GetIsAlive() then self:DestroyTimer(13) self.ScreenText.End(64) return end Player:SetHasUmbra(true, 2) end ) 

      end//end of effects roll 2
      if EffectsRoll == 3 then
      self:AddDelayToPlayer(Player) 
      local kElectrifyTimer = math.random(5, 30)
     Shine.ScreenText.Add( 61, {X = 0.20, Y = 0.80,Text = "Electrified: %s",Duration = kElectrifyTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s electrified for %s seconds", true, Player:GetName(), kElectrifyTimer)
      Player:SetElectrified(kElectrifyTimer)

      return
      end//end of effects roll 3
      if EffectsRoll == 4 then
      self:AddDelayToPlayer(Player) 
      local amount = math.random(1,4)
      Shine.ScreenText.Add( 70, {X = 0.20, Y = 0.80,Text = "Hallucinations: %s", Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s hallucination clouds", true, Player:GetName(), amount +1)
      Player:GiveItem(HallucinationCloud.kMapName)
      self:CreateTimer(14, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(14) self.ScreenText.End(70) return end Player:GiveItem(HallucinationCloud.kMapName) end )
      end//end of effects roll 4
      if EffectsRoll == 5 then
       local neareststructure = GetNearestMixin(Player:GetOrigin(), "Construct", 2, function(ent) return ent:isa("Shade") or  ent:isa("Crag") or ent:isa("Whip") or ent:isa("Shift") and ent:GetIsBuilt() end )
        if neareststructure then
        neareststructure:SetOrigin(FindFreeSpace(Player:GetOrigin()))
         self:NotifyAlien( nil, "%s stole a %s", true, Player:GetName(), neareststructure:GetClassName())
        self:AddDelayToPlayer(Player) 
        else
        self:RollPlayer(Player)
        end
      end // end of effects roll 5
      if EffectsRoll == 6 then
        self:RollPlayer(Player)
      return 
      end // end of effects roll 6
      if EffectsRoll == 7 then
       self:AddDelayToPlayer(Player)
       local kWonBabblersAmount = math.random(3, 12)
      self:NotifyAlien( nil, "%s won %s babblers", true, Player:GetName(), kWonBabblersAmount)  
      for i = 1, kWonBabblersAmount do
            local babbler = CreateEntity(Babbler.kMapName, FindFreeSpace(Player:GetOrigin()), Player:GetTeamNumber())
            babbler:SetOwner(Player)
       end 
      return 
      end  //alien effects roll 7
      if EffectsRoll == 8 then
      self:AddDelayToPlayer(Player)
      local amount = math.random(1,8)
      Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "MucousMembrane: %s",Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s mucous membranes", true, Player:GetName(), amount +1)  
      Player:GiveItem(MucousMembrane.kMapName)
      self:CreateTimer(16, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(16) self.ScreenText.End(64) return end Player:GiveItem(MucousMembrane.kMapName) end ) 
      return 
      end  //alien effects roll 8
      if EffectsRoll == 9 then
      self:AddDelayToPlayer(Player) 
      local amount = math.random(1,4)
      Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "Contamination: %s",Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s contamination", true, Player:GetName(), amount + 1)  
      Player:GiveItem(Contamination.kMapName)
      self:CreateTimer(17, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(17) self.ScreenText.End(64) return end Player:GiveItem(Contamination.kMapName) end ) 


      return
      end//end of effects roll 9
      if EffectsRoll == 10 then
      self:AddDelayToPlayer(Player) 
      local amount = math.random(1,8)
      Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "Nutrientmist: %s",Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s Nutrientmist", true, Player:GetName(), amount +1)  
      Player:GiveItem(NutrientMist.kMapName)
      self:CreateTimer(18, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(18) self.ScreenText.End(64) return end Player:GiveItem(NutrientMist.kMapName) end ) 

      return
      end//end of effects roll 10
      if EffectsRoll == 11 then
      local amount = math.random(1,8)
      Shine.ScreenText.Add( 64, {X = 0.20, Y = 0.80,Text = "ShadeInk: %s",Duration = amount * 8,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
      self:NotifyAlien( nil, "%s won %s ShadeInk,", true, Player:GetName(), amount +1)  
      Player:GiveItem(ShadeInk.kMapName)
      self:CreateTimer(19, 8, amount, function () if not Player:GetIsAlive() then self:DestroyTimer(19) self.ScreenText.End(64) return end Player:GiveItem(ShadeInk.kMapName) end ) 

      end//end of effects roll 10
    /*
            if EffectsRoll == 12 then
            self:NotifyAlien( nil, "%s is becoming paranoid", true, Player:GetName())
            self:CreateTimer( self.FoVTimer, 1, 29, function ()  if not Player:GetIsAlive() and self:TimerExists(  self.FoVTimer ) then self:DestroyTimer( self.FoVTimer ) return end Player:SetFov(Player:GetFov() + 3) end )
            self:CreateTimer( self.FoVRestoreTimer, 31, 1, function () if not Player:GetIsAlive() and self:TimerExists( self.FoVRestoreTimer ) then self:DestroyTimer( self.FoVRestoreTimer ) return end Player:SetFov(Player:GetFov() - 87) end )
            self:AddDelayToPlayer(Player) 
            return
            end//end of effects roll 11
       */
           if EffectsRoll == 12 then
           self:AddDelayToPlayer(Player) 
           self:NotifyAlien( nil, "%s is being hit by a slap bomb", true, Player:GetName())
            self:CreateTimer(20, 0.5, 30, function () if not Player:GetIsAlive() then self:DestroyTimer(20) return end Player:SetVelocity(Player:GetVelocity() + Vector(math.random(-50, 50),math.random(-10, 10),math.random(-50, 50))) end )
            return
            end//end of effectsroll 12
           if EffectsRoll == 13 then
            self:AddDelayToPlayer(Player)
            if Player:GetIsOnFire() then self:RollPlayer(Player) return end
           Player:SetOnFire()
           self:NotifyAlien( nil, "%s has been set on fire", true, Player:GetName())
           return
          end//effects roll 14
          if EffectsRoll == 14 then
            self:AddDelayToPlayer(Player) 
            CreateEntity(Scan.kMapName, Player:GetOrigin(), 1)    
            StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player)
            self:NotifyAlien( nil, "%s has been scanned", true, Player:GetName())
            return
            end//end of effects roll 15
          if EffectsRoll == 15 then
            self:NotifyAlien( nil, "%s has been bonewall-ed", true, Player:GetName(), size)
            local bonewall = CreateEntity(BoneWall.kMapName, Player:GetOrigin(), 2)    
            StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, Player)
            end//end of effects roll 16
            ///effect roll 17
          if EffectsRoll == 16 then
          self:AddDelayToPlayer(Player) 
          local kInfEnergyTimer = math.random(8, 64)
          Shine.ScreenText.Add( 61, {X = 0.20, Y = 0.80,Text = "Umbra: %s",Duration = kInfEnergyTimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
          self:NotifyAlien( nil, "%s won infinite energy for %s seconds", true, Player:GetName(), kInfEnergyTimer)
          Player:SetEnergy(Player:GetMaxEnergy())
         self:CreateTimer(48, 1, kInfEnergyTimer, function () if not Player:GetIsAlive() then self:DestroyTimer(48) self.ScreenText.End(47) return end  Player:SetEnergy(Player:GetMaxEnergy()) end ) 
         end
     
   
end //end of alien roll 2


 end //end of alien roll
    /*
  if Player:isa("Commander") then
            local WinResLoseRes = math.random(1,2)
     //self:NotifyMarine( nil, "%s Random number is 1. Checking resource gain qualifications)", true, Player:GetName())
           if WinResLoseRes == 1 and Player:GetTeam():GetTeamResources() >= kMaxTeamResources  then self:RollPlayer(Player) return end //self:NotifyMarine( nil, "%s Resources are 90 or greater. No need to add. ReRolling.", true, Player:GetName()) self:RollPlayer(Player) return end
           if WinResLoseRes == 1 and Player:GetTeam():GetTeamResources() <= kMaxTeamResources - 1 then
           local OnlyGiveUpToThisMuch = kMaxTeamResources - Player:GetTeam():GetTeamResources()
           local GiveResRTD = math.random(9.0, OnlyGiveUpToThisMuch)
           Player:GetTeam():SetTeamResources(Player:GetTeam():GetTeamResources() + GiveResRTD)
         if Player:GetTeamNumber() == 1 then
           self:NotifyMarine( nil, "%s won %s team resource(s)", true, Player:GetName(), GiveResRTD)
         else
           self:NotifyAlien( nil, "%s won %s team resource(s)", true, Player:GetName(), GiveResRTD)
        end
           self:AddDelayToPlayer(Player)
          return
          end //end of WinResLoseres roll 1
            //self:NotifyMarine( nil, "%s roll number 2. Calcualting how much res the player has.", true, Player:GetName()) 
             if WinResLoseRes == 2 and Player:GetTeam():GetTeamResources() <= 9 then self:RollPlayer(Player) return end //self:NotifyMarine( nil, "%s Player has 9 or less res. No need to remove. ReRolling Player.", true, Player:GetName()) self:RollPlayer(Player)  end
          if WinResLoseRes == 2 and Player:GetTeam():GetTeamResources() >= 10 then   
             //self:NotifyMarine( nil, "%s Player has 10 or greater res. Calculating how much to randomly take away. ", true, Player:GetName()) 
             local OnlyRemoveUpToThisMuch = Player:GetTeam():GetTeamResources()
             local LoseResRTD = math.random(9.0, OnlyRemoveUpToThisMuch) 
              Player:GetTeam():SetTeamResources(Player:GetTeam():GetTeamResources()  - LoseResRTD)
             if Player:GetTeamNumber() == 1 then
             self:NotifyMarine( nil, "%s lost %s team resource(s)", true, Player:GetName(),  LoseResRTD)
            else
             self:NotifyAlien( nil, "%s lost %s team resource(s)", true, Player:GetName(),  LoseResRTD)
            end
         self:AddDelayToPlayer(Player)
         return
         end // end of WinLoseResHealthArmor 2
   end//end of if player is a commander
   */
 return false
end //End of rollplayer

function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()

local function RTDDelay(Client, Number)
local oldvalue = self.rtd_succeed_cooldown
self.rtd_succeed_cooldown = Number
if oldvalue > Number then self.Users = {} end //So that changing the convar mid game also updates those who rolled before hand rather than it not being updated after. 
                                              //Probably an alternate way that doesn't reset the playerlist, but rather subtract from the total based on the difference.
                                              //But until or if this becomes a problem, then..
if self.rtd_succeed_cooldown > 90 then
self:NotifyMarine( nil, "RTD has been disabled", true)
self.rtdenabled = false
else
self.rtdenabled = true
self:NotifyMarine( nil, "RTD has been enabled. Cooldown set at %s seconds. Type /rtd or press M to try it out", true, Number)
end
end

local RTDDelayCommand = self:BindCommand("sh_rtddelay", "rtddelay", RTDDelay)
RTDDelayCommand:Help("Sets the successful rtd delay cooldown with the failed cooldown 30 seconds less than that.")
RTDDelayCommand:AddParam{ Type = "number" }

local function RollTheDice( Client )
//Do something regarding pre-game?
local Player = Client:GetControllingPlayer()

         if Player:isa("Egg") or Player:isa("Embryo") then
         Shine:NotifyError( Player, "You cannot gamble while an egg/embryo (Yet)" )
         return
         end
         
         if Player:isa("ReadyRoomPlayer") or (Player:GetTeamNumber() ~= 1 and Player:GetTeamNumber() ~= 2) then
         Shine:NotifyError( Player, "You must be an alien or marine to gamble (In this version, atleast)" )
         return
         end
         
         if Player:isa("Commander") then
         Shine:NotifyError( Player, "You cannot gamble while a commander (Yet)" )
         return
         end
         
          if Player:isa("Spectator") then
         Shine:NotifyError( Player, "You cannot gamble while spectating (Yet)" )
         return
         end
         
         if not Player:GetIsAlive() then
         Shine:NotifyError( Player, "You cannot gamble when you are dead (Yet)" )
         return
         end
         
local Time = Shared.GetTime()
local NextUse = self.Users[ Client ]

      if not self.rtdenabled or self.rtd_succeed_cooldown > 90 then 
      Shine:NotifyError( Player, "Currently Disabled.", true )
      return
      end
      
      if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
       Shine:NotifyError( Player, "You must wait %s before gambling again.", true, string.TimeToString( NextUse - Time ) )
      return
       end
       //Weekends
       local Success = self:AddDelayToPlayer(Player)
       //local Success = self:NotifyGeneric(Player, "RollTheDice is currently disabled.") 
if Success then
//Weekends
local gameRules = GetGamerules()
 /*
  if gameRules then
    if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() then  
     self:RollFrontDoorsClosed(Player) 
    else
  */
    self:RollPlayer(Player) //Differentiate the Delay and the re-rolling to prevent duplicate chat messages of delay during the re-rolling process.
   // end
 //  end
  //   self:NotifyGeneric(Player, "RollTheDice is currently only enabled on weekends.") 
 //weekends
self.Users[ Client ] = Time + self.rtd_succeed_cooldown
else
Shine:NotifyError( Player, "Unable to gamble. Try again in %s.", true, string.TimeToString( self.rtd_failed_cooldown ) )
self.Users[ Client ] = Time + self.rtd_failed_cooldown
end

end

local RollTheDiceCommand = self:BindCommand( "sh_rtd", { "rollthedice", "rtd" }, RollTheDice, true)
RollTheDiceCommand:Help( "Gamble and emit a positive or negative effect") 


end