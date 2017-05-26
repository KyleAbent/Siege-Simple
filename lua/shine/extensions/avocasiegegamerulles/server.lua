--Kyle 'Avoca' Abent
Script.Load("lua/Additions/SandCastle.lua") -- to load sandcastle hook opensiege onopensiege otherwise wont hook
Script.Load("lua/Additions/Imaginator.lua")
local Shine = Shine
local Plugin = Plugin

local kAutoCommTimer = 300

local OldPerformAttack

local function NewPerformAttack(self)

    if self.targetPosition then
    
        self:TriggerEffects("arc_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", 2, self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamageAliens(hitEntities, self.targetPosition, ARC.kSplashRadius, self.kAttackDamage, self, true)

        -- Play hit effect on each
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
        
    end
    
    -- reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId
    
end

OldPerformAttack = Shine.Hook.ReplaceLocalFunction( ARC.OnTag, "PerformAttack", NewPerformAttack )

local OldGetDestinationGate

local function NewGetDestinationGate(self)

    // Find next phase gate to teleport to
    local phaseGates = {}    
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) and phaseGate.channel == self.channel then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    if table.count(phaseGates) < 2 then
        return nil
    end
    
    // Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.count(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil
    
end

OldGetDestinationGate = Shine.Hook.ReplaceLocalFunction( PhaseGate.Update, "GetDestinationGate", NewGetDestinationGate )

local OldBurnSporesAndUmbra

local function NewBurnSporesAndUmbra(self, startPoint, endPoint)
  local toTarget = endPoint - startPoint
    local distanceToTarget = toTarget:GetLength()
    toTarget:Normalize()
    
    local stepLength = 2

    for i = 1, 5 do
    
        // stop when target has reached, any spores would be behind
        if distanceToTarget < i * stepLength then
            break
        end
    
        local checkAtPoint = startPoint + toTarget * i * stepLength   
        local spores = GetEntitiesWithinRange("SporeCloud", checkAtPoint, kSporesDustCloudRadius)
        table.copy(GetEntitiesWithinRange("SporeMeleeCloud", checkAtPoint, kMeleeSporesDustCloudRadius), spores, true)
        

        local umbras = GetEntitiesWithinRange("CragUmbra", checkAtPoint, CragUmbra.kRadius)
        table.copy(GetEntitiesWithinRange("StormCloud", checkAtPoint, StormCloud.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("MucousMembrane", checkAtPoint, MucousMembrane.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("EnzymeCloud", checkAtPoint, EnzymeCloud.kRadius), umbras, true)
        
        local bombs = GetEntitiesWithinRange("Bomb", checkAtPoint, 1.6)
        table.copy(GetEntitiesWithinRange("WhipBomb", checkAtPoint, 1.6), bombs, true)
        table.copy(GetEntitiesWithinRange("Rocket", checkAtPoint, 1.6), bombs, true)
        
        for index, bomb in ipairs(bombs) do
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) } )
            DestroyEntity(bomb)
        end
        
        for index, spore in ipairs(spores) do
            self:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) } )
            DestroyEntity(spore)
        end
        
        for index, umbra in ipairs(umbras) do
            self:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(umbra:GetOrigin()) } )
            DestroyEntity(umbra)
        end
    
end
end

OldBurnSporesAndUmbra = Shine.Hook.ReplaceLocalFunction( Flamethrower.FirePrimary, "BurnSporesAndUmbra", NewBurnSporesAndUmbra )

local OldUpdGestation

local function NewHpdateGestation(self)
    // Cannot spawn unless alive.
    if self:GetIsAlive() and self.gestationClass ~= nil then
    
        if not self.gestateEffectsTriggered then
        
            self:TriggerEffects("player_start_gestate")
            self.gestateEffectsTriggered = true
            
        end
        
        // Take into account catalyst effects
        local kUpdateGestationTime = 0.1
        local amount = GetAlienCatalystTimeAmount(kUpdateGestationTime, self)
        self.evolveTime = self.evolveTime + kUpdateGestationTime + amount
        
        self.evolvePercentage = Clamp((self.evolveTime / self.gestationTime) * 100, 0, 100)
        
        if self.evolveTime >= self.gestationTime then
        
            // Replace player with new player
            local newPlayer = self:Replace(self.gestationClass)
            newPlayer:SetCameraDistance(0)

            local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
            local newAlienExtents = LookupTechData(newPlayer:GetTechId(), kTechDataMaxExtents)

            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            --validate the spawn point before using it
            if self.validSpawnPoint and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self.validSpawnPoint + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, newPlayer)) then
                newPlayer:SetOrigin(self.validSpawnPoint)
            else
                for index = 1, 100 do

                    local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

                    if spawnPoint then

                        newPlayer:SetOrigin(spawnPoint)
                        break

                    end

                end

            end

            newPlayer:DropToFloor()
            
            self:TriggerEffects("player_end_gestate")
            
            // Now give new player all the upgrades they purchased
            local upgradesGiven = 0
            
            for index, upgradeId in ipairs(self.evolvingUpgrades) do

                if newPlayer:GiveUpgrade(upgradeId) then
                    upgradesGiven = upgradesGiven + 1
                end
                
            end
            
            local healthScalar = self.storedHealthScalar or 1
            local armorScalar = self.storedArmorScalar or 1

            newPlayer:SetHealth(healthScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth))
            newPlayer:SetArmor(armorScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxArmor))
           if  newPlayer.OnGestationComplete then newPlayer:OnGestationComplete() end
            newPlayer:SetHatched()
            newPlayer:TriggerEffects("egg_death")
           
            
           if  GetHasRebirthUpgrade(newPlayer) then
               if self.triggeredrebirth then
                  newPlayer:SetHealth(newPlayer:GetHealth() * 0.7)
                  newPlayer:SetArmor(newPlayer:GetArmor() * 0.7)
               end
          newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
           end
          


        if GetHasRedemptionUpgrade(newPlayer) then
          newPlayer:TriggerRedeemCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
         end
            
            if self.resOnGestationComplete then
                newPlayer:AddResources(self.resOnGestationComplete)
            end
            
            local newUpgrades = newPlayer:GetUpgrades()
            if #newUpgrades > 0 then            
                newPlayer.lastUpgradeList = newPlayer:GetUpgrades()
            end

            // Notify team

            local team = self:GetTeam()

            if team and team.OnEvolved then

                team:OnEvolved(newPlayer:GetTechId())

                for _, upgradeId in ipairs(self.evolvingUpgrades) do

                    if team.OnEvolved then
                        team:OnEvolved(upgradeId)
                    end
                    
                end

            end
            
            // Return false so that we don't get called again if the server time step
            // was larger than the callback interval
            return false
            
        end
        
    end
    
    return true

end

OldUpdGestation = Shine.Hook.ReplaceLocalFunction( Embryo.OnInitialized, "UpdateGestation", NewHpdateGestation )

local OldConfused

local function NewConfused(self)
return 
end

local OldUpdateBatteryState

local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

local function NewUpdateBatteryState( self )
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 1) then
        
           local location = GetLocationForPoint(self:GetOrigin())
           local powerpoint = location ~= nil and GetPowerPointForLocation(location:GetName())   
            self.attachedToBattery = false
           if powerpoint then 
            self.attachedToBattery = (powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled()) or GetHasSentryBatteryInRadius(self)
            end
            self.lastBatteryCheckTime = time
        end
end

OldUpdateBatteryState = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateBatteryState", NewUpdateBatteryState )

OldConfused = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateConfusedState", NewConfused )



local OldUpdateWaveTime


local function DynamicWaveTime( self )
    if self:GetIsDestroyed() then
        return false
    end
    
    if self.queuePosition <= self:GetTeam():GetEggCount() then
        local entryTime = self:GetRespawnQueueEntryTime() or 0
        local waveSpawnTime = Clamp(  ( kAlienSpawnTime - (GetRoundLengthToSiege()/1.5) * kAlienSpawnTime ) * 1.5, 4, kAlienSpawnTime)
       -- Print("Alien Spawn time is %s", waveSpawnTime)
        self.timeWaveSpawnEnd = entryTime + waveSpawnTime
    else
        self.timeWaveSpawnEnd = 0
    end
    
    Server.SendNetworkMessage(Server.GetOwner(self), "SetTimeWaveSpawnEnds", { time = self.timeWaveSpawnEnd }, true)
    
    if not self.sentRespawnMessage then
    
        Server.SendNetworkMessage(Server.GetOwner(self), "SetIsRespawning", { isRespawning = true }, true)
        self.sentRespawnMessage = true
        
    end
    
    return true
end

OldUpdateWaveTime = Shine.Hook.ReplaceLocalFunction( AlienSpectator.OnInitialized, "UpdateWaveTime", DynamicWaveTime )

local OldGetIsWeldedByOtherMAC

OldGetIsWeldedByOtherMAC = Shine.Hook.ReplaceLocalFunction( AlienSpectator.OnInitialized, "GetIsWeldedByOtherMAC", NotGetIsWeldedByOtherMAC )


local function NotGetIsWeldedByOtherMAC(self)
 return false
end

local OldUpdateHealing 

OldUpdateHealing = Shine.Hook.ReplaceLocalFunction( AlienSpectator.OnInitialized, "UpdateHealing", UpdateCertainHealing )

local function UpdateCertainHealing(self)

    if GetIsUnitActive(self) and not self:GetGameEffectMask(kGameEffect.OnFire) then
    
        if self.timeOfLastHeal == nil or Shared.GetTime() > (self.timeOfLastHeal + Hive.kHealthUpdateTime) then
            
            local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
            
            for index, player in ipairs(players) do
            
                if player:GetIsAlive() and ( not GetIsInSiege(player) or player:isa("Fade") )  and ((player:GetOrigin() - self:GetOrigin()):GetLength() < Hive.kHealRadius) then   
                    -- min healing, affects skulk only
                    player:AddHealth(math.max(10, player:GetMaxHealth() * Hive.kHealthPercentage), true )                
                end
                
            end
            
            self.timeOfLastHeal = Shared.GetTime()
            
        end
        
    end
    
end
local function AddSuddenDeathTimer(who)
      local NowToSuddendeath = (kTimeAfterSiegeOpeningToEnableSuddenDeath) - (Shared.GetTime() - GetSandCastle():GetSDTimer() )
      local SuddenDeathLength =  math.ceil( Shared.GetTime() +  NowToSuddendeath - Shared.GetTime() )
      Print("SuddenDeathLength is %s", SuddenDeathLength)
	  Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.95,Text = "Sudden Death activates in %s",Duration = SuddenDeathLength,R = 255, G = 255, B = 0,Alignment = 0,Size = 4,FadeIn = 0,}, who )
end
  function Plugin:OnOpenSiegeDoors() 
  if not GetGamerules():GetGameStarted()  then return end
         Print("Shine open siege doors 1")
                local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Print("Shine open siege doors 2")
                  AddSuddenDeathTimer(Player)
                  end
               end
  end
local function AddSDEnabledDisplay(who) 
	  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.95,Text = "Sudden Death is ACTIVE! (No Respawning, No CC/Hive Healing)",Duration = 300,R = 255, G = 255, B = 0,Alignment = 0,Size = 4,FadeIn = 0,}, who )
end
    function Plugin:OnEnableSD() 
      if not GetGamerules():GetGameStarted()  then return end
        for i = 1, math.random(4,8) do
       self:NotifySuddenDeath( nil, "SuddenDeath Activated ! No more respawning! No more hive/cc healing/dropping. IF you don't like it post on forums or discord?", true)
       end
                local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddSDEnabledDisplay(Player)
                  end
               end
  end
  
Shine.Hook.SetupClassHook( "SandCastle", "OpenSiegeDoors", "OnOpenSiegeDoors", "PassivePost" )

Shine.Hook.SetupClassHook( "SandCastle", "EnableSD", "OnEnableSD", "PassivePre" )


Shine.Hook.SetupClassHook( "Marine", "AdjustDisplayRessuply", "ShowResupply", "PassivePre" )
Shine.Hook.SetupClassHook( "Alien", "TriggerRedeemCountDown", "OnRedemedHook", "PassivePre" )
Shine.Hook.SetupClassHook( "Alien", "TriggerRebirthCountDown", "TriggerRebirthCountDown", "PassivePre" )


Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
self.AutoCCtimer = false
return true
end

function Plugin:MapPostLoad()
      self:StartAutoCommTimer()
      Server.CreateEntity(SandCastle.kMapName)
      Server.CreateEntity(Imaginator.kMapName)
end

local function AddFrontTimer(who)
    local Client = who
    local NowToFront = GetSandCastle():GetFrontLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.75,Text = "FrontDoor: %s",Duration = FrontLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function AddPayLoadPercent(who)
    local Client = who
    local time, speed, isReverse = GetPayloadPercent()
    local ycoord = ConditionalValue(who:isa("Spectator"), 0.70, 0.85)
    if isReverse then
    Shine.ScreenText.Add( 3, {X = 0.40, Y = ycoord,Text = string.format("Payload(%sx): Reversing!",  speed-1 ) , Duration = 4,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    return
    end
    
     if time > 1 then
    Shine.ScreenText.Add( 3, {X = 0.40, Y = ycoord,Text = string.format("Payload(%sx): %s seconds",  speed-1, time ) , Duration = 4,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    else
     Shine.ScreenText.Add( 3, {X = 0.40, Y = ycoord,Text = "Payload: Deployed!", Duration = 4,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    end
end
local function AddSiegeTimer(who)
    local Client = who
    local NowToSiege = GetSandCastle():GetSiegeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    local ycoord = ConditionalValue(who:isa("Spectator"), 0.85, 0.95)
    Shine.ScreenText.Add( 2, {X = 0.40, Y = ycoord,Text = "SiegeDoor: %s",Duration = SiegeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function AddPrimaryTimer(who)
    local Client = who
    local NowToPrimary = GetSandCastle():GetPrimaryLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local PrimaryLength =  math.ceil( Shared.GetTime() + NowToPrimary - Shared.GetTime() )
    Shine.ScreenText.Add( 3, {X = 0.40, Y = 0.65,Text = "PrimaryDoor: %s",Duration = PrimaryLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function GivePayloadInfoToAll(self)
       self:CreateTimer( 1, 4, -1, function() 
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddPayLoadPercent(Player)
                  end
               end
        end)
end
local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddFrontTimer(Player)
                  AddSiegeTimer(Player) --DownPrimary is the 30 min expiration date. UpPrimary is no timer goes beyond 20.
                    if kPrimaryTimer ~= 0 then  AddPrimaryTimer(Player) end
                  end
              end
end
function Plugin:SendMessageToMods(string)
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Shine:GetUserImmunity(Player:GetClient()) >= 10 then --isamod 
                  self:NotifyMods( Player, "%s", true, string)
                  end
               end
end
function Plugin:ClientDisconnect(Client)
 if Client:GetIsVirtual() then return end
 
        if GetGamerules():GetGameStarted() and GetImaginator():GetAlienEnabled() or GetImaginator():GetMarineEnabled() then
 
        local playercount = #Shine.GetAllPlayers()
        local  humancount = #Shine.GetHumanPlayerCount()
        local bots = math.abs(humancount - playercount)

         if (NumPlayers<10 and bots <10) then 
                        Shared.ConsoleCommand("addbot")      
         end
      end
      
  
end
function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
        /*
                   self:SimpleTimer( 4, function() 
                  if not Client then return end
                   Shine.ScreenText.Add( 27, {X = 0.80, Y = 0.20,Text = "Server Rules:",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                 end)
                   self:SimpleTimer( 8, function() 
                  if not Client then return end
 Shine.ScreenText.Add( 28, {X = 0.80, Y = 0.25,Text = "No Exploiting",Duration = 24,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                   end)
                   self:SimpleTimer( 12, function() 
                  if not Client then return end
 Shine.ScreenText.Add( 29, {X = 0.80, Y = 0.30,Text = "No Bullying",Duration = 16,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                 end)
        */
 
      
if GetGamerules():GetGameStarted() then
         
--local frontlength = GetSandCastle():GetFrontLength()
--local siegelength = GetSandCastle:GetSiegeLength()
if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kFrontTimer then
     AddFrontTimer(Client)
   end
   
 if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSiegeTimer then
         AddSiegeTimer(Client)
   end
   

   
    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kPrimaryTimer then
         AddPrimaryTimer(Client)
   end
   
    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) >  kSiegeTimer  then
         AddSuddenDeathTimer(Client)
   end
   
   if GetSandCastle():GetSDBoolean() then
   Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.95,Text = "Sudden Death is ACTIVE! (No Respawning, No CC/Hive Healing)",Duration = 300,R = 255, G = 255, B = 0,Alignment = 0,Size = 4,FadeIn = 0,}, Client )
   end
   
          if GetImaginator():GetAlienEanbled() or GetImaginator():GetMarineEnabled() then
        local players, numplayers = Shine.GetAllPlayers()
        local humans, numhumans = Shine.GetHumanPlayerCount()
        local bots = math.abs(humans - players)

         if (numplayers>10 and bots >=1) then 
         
                        Shared.ConsoleCommand("removebot")
                       
         end
      end
   
else
                   --      self:CreateTimer( 27, 1,  self.autoCommTime, function() 
                   --      if GetGamerules():GetGameStarted() then Plugin:DestroyTimer( 27 ) end
                   --       Shine.ScreenText.Add( 14, {X = 0.40, Y = 0.90,Text = string.format( "AutoComm will start in %s", self.autoCommTime ),Duration = 1,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
                   --     end)

end

end
local function OpenAllBreakableDoors()
 for _, door in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do 
           door.open = true
       door.timeOfDestruction = Shared.GetTime() 
       door:SetHealth(door:GetHealth() - 10)
 end
end
function Plugin:SetGameState( Gamerules, State, OldState )

 if State == kGameState.Started then 
    GiveTimersToAll()
     if string.find(Shared.GetMapName(), "pl_") then GivePayloadInfoToAll(self) end
     OpenAllBreakableDoors()
  else
 Shine.ScreenText.End(1) 
 Shine.ScreenText.End(2)
 Shine.ScreenText.End(3)


                       
  end 
    if State ==  kGameState.Team1Won  or State ==  kGameState.Team2Won   then
    
                       for i = 1, 10 do
                        Shared.ConsoleCommand("removebot")
                       end
                       

           elseif State == kGameState.Countdown then
             GetSandCastle():OnRoundStart()
             GetImaginator():OnRoundStart()
       elseif State == kGameState.NotStarted then
                --GetImaginator():OnPreGame()
             GetSandCastle():OnPreGame()
            self:StartAutoCommTimer()
             self.autoCommTime = kAutoCommTimer
             self.AutoCCtimer = false
          end
          
    
end
function Plugin:StartAutoCommTimer()
 self.autoCommTime = kAutoCommTimer

                    self:SimpleTimer( self.autoCommTime, function() 
              
                    local  numplayers = #Shine.GetAllPlayers()
                    local gameRules = GetGamerules()
                    if self.stopped or gameRules:GetGameStarted() or numplayers > 10 then return end
                     /*
                    if numplayers <= 10 then
                        for i = 1, 10 - numplayers do
                        Shared.ConsoleCommand("addbot")
                       end
                   end
                   
           Shared.ConsoleCommand("sh_randomrr")
           Shared.ConsoleCommand("sh_forceroundstart")
           Shared.ConsoleCommand("sh_imaginator 1 true")
           Shared.ConsoleCommand("sh_imaginator 2 true")
           */
           self:NotifyAutoComm( nil, "Usually the AutoComm timer would start here however I think it's best to leave auto enable disabled until after 5.30.17. Type sh_autocomm if you want to play. (Mod command)", true)
                 end)
    

                 
 
 self:CreateTimer( 41, 1,  self.autoCommTime, function() 
 if self.stopped or GetGamerules():GetGameStarted() then Plugin:DestroyTimer( 41 ) end
  self.autoCommTime = Clamp(self.autoCommTime - 1, 0, kAutoCommTimer)
 end)


                         self:CreateTimer( 84, 1,  -1, function() 
                         local  numplayers = #Shine.GetAllPlayers()
                         if self.stopped or GetGamerules():GetGameStarted() or numplayers>= 10 then Plugin:DestroyTimer( 84 ) end
                         
                            if  self.autoCommTime <=10 or  self.autoCommTime == 30 or  self.autoCommTime == 60 or  self.autoCommTime == 90
                            or  self.autoCommTime == 120 or  self.autoCommTime == 150 then
                            self:NotifyAutoComm( nil, "AutoComm will start in %s seconds if playercount<10. say /extend to extend the timer or /stop to stop it.", true, self.autoCommTime)
                         -- Shine.ScreenText.Add( 33, {X = 0.40, Y = 0.90,Text = string.format( "AutoComm will start in %s", self.autoCommTime ),Duration = 1,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
                         end
                         
                        end)
             

end
function Plugin:NotifySuddenDeath( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[SuddenDeath]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGiveRes( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[GiveRes]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyAutoComm( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[AutoComm]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyMods( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Moderator Chat]",  255, 0, 0, String, Format, ... )
end
function Plugin:GiveCyst(Player)
            local ent = CreateEntity(CystSiege.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  
             ent:SetConstructionComplete()
end

  function Plugin:ShowResupply(player, left, has) 
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text =  string.format( "Resupplies left: %s ", has ),Duration = 4 or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
 end
  function Plugin:OnRedemedHook(player) 
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Redemption Cooldown: %s",Duration = derp:GetRedemptionCoolDown() or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
 end
  function Plugin:OnBallGiven(player)
   if  player and player:GetIsAlive() and player:GetHasBall() then
             self:CreateTimer( 69, 1,  -1, function() 
             if not player or not player:GetIsAlive() or not player:GetHasBall() then Plugin:DestroyTimer( 69 ) end
            Shine.ScreenText.Add( 42, {X = 0.20, Y = 0.90,Text = "You have the ball!",Duration = 1 or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
             end)
   end

end
function Plugin:TriggerRebirthCountDown(player)
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Rebirth Cooldown: %s",Duration = derp:GetRedemptionCoolDown() or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
end


function Plugin:CreateCommands()


local function Pres( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            Player:SetResources(Number)
           	 Shine:CommandNotify( Client, "set %s's resources to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local PresCommand = self:BindCommand( "sh_pres", "pres", Pres)
PresCommand:AddParam{ Type = "clients" }
PresCommand:AddParam{ Type = "number" }
PresCommand:Help( "sh_pres <player> <number> sets player's pres to the number desired." )


local function  AddScore( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if HasMixin(Player, "Scoring") then
            Player:AddScore(Number, 0, false)
           	 Shine:CommandNotify( Client, "%s's score increased by %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local AddScoreCommand = self:BindCommand( "sh_addscore", "addscore", AddScore)
AddScoreCommand:AddParam{ Type = "clients" }
AddScoreCommand:AddParam{ Type = "number" }
AddScoreCommand:Help( "sh_addscore <player> <number> adds number to players score" )





local function RandomRR( Client )
        local rrPlayers = GetGamerules():GetTeam(kTeamReadyRoom):GetPlayers()
        for p = #rrPlayers, 1, -1 do
            JoinRandomTeam(rrPlayers[p])
        end
           Shine:CommandNotify( Client, "randomized the readyroom", true)  
end
local RandomRRCommand = self:BindCommand( "sh_randomrr", "randomrr", RandomRR )
RandomRRCommand:Help( "randomize's the ready room.") 


local function Stalemate( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
Gamerules:DrawGame()
end 


local StalemateCommand = self:BindCommand( "sh_stalemate", "stalemate", Stalemate )
StalemateCommand:Help( "declares the round a draw." )




local function Slap( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()


  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           self:NotifyGeneric( nil, "slapping %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 13, 1, Number, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(13) then self:DestroyTimer( 13 ) return end
            Player:SetVelocity(  Player:GetVelocity() + Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900)  ) )
            end )
end
end
end
local SlapCommand = self:BindCommand( "sh_slap", "slap", Slap)
SlapCommand:Help ("sh_slap <player> <time> Slaps the player once per second random strength")
SlapCommand:AddParam{ Type = "clients" }
SlapCommand:AddParam{ Type = "number" }




local function PHealth( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
            if Number > defaulthealth then Player:AdjustMaxHealth(Number) end
              Player:SetHealth(Number)
              
           	 Shine:CommandNotify( Client, "set %s's health to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end --
     end--
end--
local PHealthCommand = self:BindCommand( "sh_phealth", "phealth", PHealth)
PHealthCommand:AddParam{ Type = "clients" }
PHealthCommand:AddParam{ Type = "number", Min = 1, Max = 8191, Error = "1 min 8191 max" }
PHealthCommand:Help( "sh_phealth <player> <number> sets player's health to the number desired." )

local function PArmor( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            local defaultarmor = LookupTechData(Player:GetTechId(), kTechDataMaxArmor, 1)
            if Number > defaultarmor then Player:AdjustMaxArmor(Number) end
              Player:SetArmor(Number)
              
           	 Shine:CommandNotify( Client, "set %s's armor to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end--
     end--
end--
local PArmorCommand = self:BindCommand( "sh_parmor", "parmor", PArmor)
PArmorCommand:AddParam{ Type = "clients" }
PArmorCommand:AddParam{ Type = "number", Min = 1, Max = 2045, Error = "1 min 2045 max" }
PArmorCommand:Help( "sh_parmor <player> <number> sets player's armor to the number desired." )


local function SHealth( Client, String, Number  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  local defaulthealth = LookupTechData(entity:GetTechId(), kTechDataMaxHealth, 1)
                   if entity.SetMature then entity:SetMature() end
                  if Number > defaulthealth then entity:AdjustMaxHealth(Number) end
                  entity:SetHealth(Number)
                  self:NotifyGeneric( nil, "set %s health to %s (%s)", true, entity:GetMapName(), Number,entity:GetLocationName())
             end--
         end--
end--
local SHealthCommand = self:BindCommand( "sh_shealth", "shealth", SHealth )
SHealthCommand:AddParam{ Type = "string" }
SHealthCommand:AddParam{ Type = "number", Min = 1, Max = 8191, Error = "1 min 8191 max" }
SHealthCommand:Help( "shealth <string> <number> within 8 radius sets this classname's health to X" )

local function Sarmor( Client, String, Number  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  local defaultarmor = LookupTechData(entity:GetTechId(), kTechDataMaxArmor, 1)
                  if Number > defaultarmor then entity:AdjustMaxArmor(Number) end
                  entity:SetArmor(Number)
                  self:NotifyGeneric( nil, "set %s armor to %s (%s)", true, entity:GetMapName(), Number,entity:GetLocationName())
             end--
         end--
end--
local SarmorCommand = self:BindCommand( "sh_sarmor", "sarmor", Sarmor )
SarmorCommand:AddParam{ Type = "string" }
SarmorCommand:AddParam{ Type = "number", Min = 1, Max = 2045, Error = "1 min 2045 max" }
SarmorCommand:Help( "sarmor <string> <number> within 8 radius sets this classname's armor to X" )


local function Respawn( Client, Targets )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Shine:CommandNotify( Client, "respawned %s.", true,
				Player:GetName() or "<unknown>" )  
         Player:GetTeam():ReplaceRespawnPlayer(Player)
                 Player:SetCameraDistance(0)
     end--
end--
local RespawnCommand = self:BindCommand( "sh_respawn", "respawn", Respawn )
RespawnCommand:AddParam{ Type = "clients" }
RespawnCommand:Help( "<player> respawns said player" )


local function RunCMD( Client, Targets, String )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Player:RunCommand(String)
     end--
end--
local RunCMDCommand = self:BindCommand( "sh_runcmd", "runcmd", RunCMD )
RunCMDCommand:AddParam{ Type = "clients" }
RunCMDCommand:AddParam{ Type = "string" }
RunCMDCommand:Help( "<player> <string> makes the client type something in console of which you choose." )




local function ModelSize( Client, Targets, Number )
  if Number > 10 then return end
    self:NotifyGeneric( nil, "Adjusted %s players size to %s percent", true, #Targets, Number * 100)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize and Player:GetIsAlive() then
                Player:AdjustModelSize(Number)
             end
     end
end

local ModelSizeCommand = self:BindCommand( "sh_modelsize", "modelsize", ModelSize )
ModelSizeCommand:AddParam{ Type = "clients" }
ModelSizeCommand:AddParam{ Type = "number" }
ModelSizeCommand:Help( "sh_playergravity <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )


local function TeamSize( Client, Number, NumberTwo )
  if NumberTwo > 10 or (Number ~= 1 and Number ~= 2) then return end
   if Number == 1 then
    self:NotifyGeneric( nil, "Adjusted Marines team size to %s", true, NumberTwo * 100)
    elseif Number == 2 then
        self:NotifyGeneric( nil, "Adjusted Aliens team size to %s", true, NumberTwo * 100)
    end
    
    local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and Player:GetTeamNumber() == Number and not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize then
                       Player:AdjustModelSize(NumberTwo)
                  end
              end
end
local TeamSizeCommand = self:BindCommand( "sh_teamsize", "teamsize", TeamSize )
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:Help( "sh_teamsize." )

local function Bury( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           Player:SetOrigin(Player:GetOrigin() - Vector(0, .5, 0))
         self:NotifyGeneric( nil, "Burying %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 14, Number, 1, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(14) then self:DestroyTimer( 14 ) return end
            Player:SetOrigin(Player:GetOrigin() + Vector(0, .5, 0))
            end )
end
end
end

local BuryCommand = self:BindCommand( "sh_bury", "bury", Bury)
BuryCommand:Help ("sh_bury <player> <time> Buries the player for the given time")
BuryCommand:AddParam{ Type = "clients" }
BuryCommand:AddParam{ Type = "number" }

local function Destroy( Client, String  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  self:NotifyGeneric( nil, "destroyed %s in %s", true, entity:GetMapName(), entity:GetLocationName())
                  DestroyEntity(entity)
             end
         end
end
local DestroyCommand = self:BindCommand( "sh_destroy", "destroy", Destroy )
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:Help( "Destroy <string> Destroys all entities with this name within 8 radius" )

local function ThirdPerson( Client )
local Player = Client:GetControllingPlayer()
if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(3) //* ConditionalValue(not Player:isa("ReadyRoomPlayer") and Player.modelsize > 1, Player.modelsize * .5, 1))
end

local ThirdPersonCommand = self:BindCommand( "sh_thirdperson", { "thirdperson", "3rdperson" }, ThirdPerson, true)
ThirdPersonCommand:Help( "Triggers third person view" )
	
local function FirstPerson( Client )
local Player = Client:GetControllingPlayer()
if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(0)
end

local FirstPersonCommand = self:BindCommand( "sh_firstperson", { "firstperson", "1stperson" }, FirstPerson, true)
FirstPersonCommand:Help( "Triggers first person view" )

local function GiveRes( Client, TargetClient, Number )
local Giver = Client:GetControllingPlayer()
local Reciever = TargetClient:GetControllingPlayer()
//local TargetName = TargetClient:GetName()
 //Only apply this formula to pres non commanders // If trying to give a number beyond the amount currently owned in pres, do not continue. Or If the reciever already has 100 resources then do not bother taking resources from the giver
  if Giver:GetTeamNumber() ~= Reciever:GetTeamNumber() or Giver:isa("Commander") or Reciever:isa("Commander") or Number > Giver:GetResources() or Reciever:GetResources() == 100 then
  self:NotifyGiveRes( Giver, "Unable to donate any amount of resources to %s", true, Reciever:GetName())
 return end 

 
            //If giving res to a person and that total amount exceeds 100. Only give what can fit before maxing to 100, and not waste the rest.
            if Reciever:GetResources() + Number > 100 then // for example 80 + 30 = 110
            local GiveBack = 0 //introduce x
            GiveBack = Reciever:GetResources() + Number // x = 80 + 30 (110)
            GiveBack = GiveBack - 100  // 110 = 110 - 100 (10)
            Giver:SetResources(Giver:GetResources () - Number + GiveBack) // Sets resources to the value wanting to donate + the portion to give back that's above 100
            local Show = Number - GiveBack
            Reciever:SetResources(100) // Set res to 100 anyway because the check above says if getres + num > 100. Therefore it would be 100 anyway.
              self:NotifyGiveRes( Giver, "%s has reached 100 res, therefore you've only donated %s resource(s)", true, Reciever:GetName(), Show)
              self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Show)
            return //prevent from going through the process of handing out res again down below(?)
            end
            ////
 //Otherwise if the giver has the amount to give, and the reciever amount does not go beyond 100, complete the trade. (pres)     
 //Shine:Notify(Client, Number, TargetClient, "Successfully donated %s resource(s) to %s", nil)
Giver:SetResources(Giver:GetResources() - Number)
Reciever:SetResources(Reciever:GetResources() + Number)
self:NotifyGiveRes( Giver, "Succesfully donated %s resource(s) to %s", true, Number, Reciever:GetName())
self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Number)
//Notify(StringFormat("[GiveRes] Succesfully donated %s resource(s) to %s.",  Number, TargetName) )


//Now for some fun and to expand on the potential of giveres within ns2 that ns1 did not reach?
//In particular, team res and commanders. 

//If the giver is a commander to a recieving teammate then take the resources out of team resources rather than personal.

//if Giver:GetTeamNumber() == Reciever:GetTeamNumber() and Giver:isa(Commander) then
end

local GiveResCommand = self:BindCommand( "sh_giveres", "giveres", GiveRes, true)
GiveResCommand:Help( "giveres <name> <amount> ~ (No commanders)" )
GiveResCommand:AddParam{ Type = "client",  NotSelf = true, IgnoreCanTarget = true }
GiveResCommand:AddParam{ Type = "number", Min = 1, Max = 100, Round = true }


local function Gravity( Client, Number )
 for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do 
    player:SetGravity(Number)
 end
   self:NotifyGeneric( nil, "Set Gravity to %s (0=off)", true, Number)  
end
local GravityCommand = self:BindCommand( "sh_gravity", "gravity", Gravity )
GravityCommand:AddParam{ Type = "number" }
GravityCommand:Help( "sh_gravity <number> (0 = default) applies to all players and copies values on respawn, meaning new players may not be affected?" )

local function Gbd( Client )
local Player = Client:GetControllingPlayer()
 Player:GiveLayStructure(kTechId.Door, BreakableDoor.kMapName)
end
local GbdCommand = self:BindCommand( "sh_gbd", "gbd", Gbd )
GbdCommand:Help( "gives self laystructure breakabledoor placeable anywhere without limit - aboos" )

local function Give( Client, Targets, String, Number )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Player and Player:GetIsAlive() and String ~= "alien" and not (Player:isa("Alien") and String == "armory") and not (Player:isa"ReadyRoomTeam" and String == "CommandStation" or String == "Hive") and not Player:isa("Commander") then
/*
Player:GiveItem(String)
        for index, target in ipairs(GetEntitiesWithMixinWithinRangeAreVisible("Construct", Player:GetOrigin(), 3, true )) do
              if not target:GetIsBuilt() then target:SetConstructionComplete() end
          end
 */
           
 local teamnum = Number and Number or Player:GetTeamNumber()
 local ent = CreateEntity(String, Player:GetOrigin(), teamnum)  
if HasMixin(ent, "Construct") then  ent:SetConstructionComplete() end
             Shine:CommandNotify( Client, "gave %s an %s", true,
			 Player:GetName() or "<unknown>", String )  
end
end
end
local GiveCommand = self:BindCommand( "sh_give", "give", Give )
GiveCommand:AddParam{ Type = "clients" }
GiveCommand:AddParam{ Type = "string" }
GiveCommand:AddParam{ Type = "number", Optional = true }
GiveCommand:Help( "<player> Give item to player(s)" )


local function Chat( Client, String )
           
      self:SendMessageToMods(String)
end
local ChatCommand = self:BindCommand( "sh_chat", "chat", Chat )
ChatCommand:AddParam{ Type = "string" }
ChatCommand:Help( "for mods to talk in private. Only mods can see and use this chat." )



local function Cyst( Client, Targets )
     for i = 1, #Targets do
     local Player = Targets[ i ]:GetControllingPlayer()
         if Player and Player:GetIsAlive() and Player:isa("Alien") and not Player:isa("Commander") then
             self:GiveCyst(Player)
           self:NotifyGeneric( nil, "Gave %s an Cyst", true, Player:GetName())
          end
     end
end
local CystCommand = self:BindCommand( "sh_cyst", "cyst", Cyst )
CystCommand:AddParam{ Type = "clients" }
CystCommand:Help( "<player> Give cyst to player(s)" )


local function Imaginator( Client, Number, Boolean )
GetImaginator():SetImagination(Boolean, Number)
if Number == 1 then 
GetImaginator().marineenabled = Boolean
elseif Number == 2 then
GetImaginator().alienenabled = Boolean
end
 self:NotifyGeneric( nil, "%s Imaginator set to %s (No Comm Required)", true, Number, Boolean)
  
end

local ImaginatorCommand = self:BindCommand( "sh_imaginator", "imaginator", Imaginator )
ImaginatorCommand:Help( "sh_Imaginator - 1/2 - true/false - Automated structure placement system (No Comm Required) " )
ImaginatorCommand:AddParam{ Type = "team" }
ImaginatorCommand:AddParam{ Type = "boolean" }


local function OpenFrontDoors()
           for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
                sandcastle:OpenFrontDoors() 
                end

end
local function OpenPrimaryDoors()
           for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
                sandcastle:OpenPrimaryDoors() 
                end

end
local function OpenBreakableDoors()
           for index, breakabledoor in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do
               if breakabledoor.health ~= 0 then breakabledoor.health = 0 end 
                end

end

local function Open( Client, String )
local Gamerules = GetGamerules()
     if String == "Front" or String == "front" then
       OpenFrontDoors()
        Shine.ScreenText.End(1) 
     elseif String == "Primary" or String == "primary" then
       OpenPrimaryDoors()
       Shine.ScreenText.End(3)
     elseif String == "Siege" or String == "siege" then
       GetSandCastle():OpenSiegeDoors()
         Shine.ScreenText.End(2) 
        -- self:OnOpenSiegeDoors()
     elseif String == "Breakable" or String == "breakable" then
        OpenBreakableDoors()
    end  --
  self:NotifyGeneric( nil, "Opened the %s doors", true, String)  
  
end --

local OpenCommand = self:BindCommand( "sh_open", "open", Open )
OpenCommand:AddParam{ Type = "string" }
OpenCommand:Help( "Opens <type> doors (Front/Primary/Siege) (not case sensitive) - timer will still display." )

local function TestFilm( Client )
           for i = 1, 10 do
          Shared.ConsoleCommand("addbot")
         end
         Shared.ConsoleCommand("sh_randomrr")
            Shared.ConsoleCommand("sh_forceroundstart")
            Shared.ConsoleCommand("sh_imaginator 1 true")
          Shared.ConsoleCommand("sh_imaginator 2 true")

  
   self:NotifyGeneric( nil, "%s Test Film ", true)
  
end

local TestFilmCommand = self:BindCommand( "sh_testfilm", "testfilm", TestFilm )
TestFilmCommand:Help( "sh_testfilm adds bots forces round and enables imaginator  " )


local function AutoComm( Client )


     if not GetGamerules():GetGameStarted() then
            Shared.ConsoleCommand("sh_forceroundstart")
     end
         local boolean = GetImaginator():GetAlienEnabled()
            Shared.ConsoleCommand(string.format("sh_imaginator 2 %s", not boolean )  )
            Shared.ConsoleCommand(string.format("sh_imaginator 1 %s", not boolean )  )
            
            self:NotifyAutoComm( nil, "AutoComm toggle offswitch set to %s", true, boolean)
           
end

local AutoCommCommand = self:BindCommand( "sh_autocomm", "autocomm", AutoComm )
AutoCommCommand:Help( "sh_testfilm forces autocomm (disables if human comm) and forces round to start  " )

local function StopAutoComm( Client )
      local Player = Client:GetControllingPlayer()
      if Shine:GetUserImmunity(Client) < 10 then return end--isamod 
      self.stopped = true
      self:NotifyAutoComm( nil, "%s Stopped AutoComm pregame countdown forceroundstart (offswitch is off unless sh_autocomm is toggled during round)", true, Player:GetName() )
end

local StopAutoCommCommand = self:BindCommand( "sh_stop", "stop", StopAutoComm, true )
StopAutoCommCommand:Help( "sh_stop stops auto comm  timer" )

local function ExtendAutoComm( Client )
   local Player = Client:GetControllingPlayer()
   if not self.lastExtend or Shared.GetTime() > self.lastExtend + 90 then
      self.autoCommTime = self.autoCommTime + 60
      self:NotifyAutoComm( nil, "%s Extended AutoComm by 60s. Now at %s seconds left", true, Player:GetName(), self.autoCommTime )
      self.lastExtend = Shared.GetTime()
     self.nextUse = Shared.GetTime() + 90
      else
      self:NotifyAutoComm( Player, "%s seconds until extension allowed", true, string.TimeToString( self.nextUse - Shared.GetTime() ) )
   end
  
 
  
end

local ExtendAutoCommCommand = self:BindCommand( "sh_extend", "extend", ExtendAutoComm, true )
ExtendAutoCommCommand:Help( "sh_extend forces autocomm (disables if human comm) and forces round to start  " )



local function BringAll( Client )
    self:NotifyGeneric( nil, "Brought everyone to one locaiton/area", true)
    
        local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and not Player:isa("Commander") and not Player:isa("Spectator") then
                       local where = FindFreeSpace(Client:GetControllingPlayer():GetOrigin())
                       Player:SetOrigin(where)
                  end
              end
end

local BringAllCommand = self:BindCommand( "sh_bringall", "bringall", BringAll )
BringAllCommand:Help( "sh_bringall - teleports everyone to the same spot" )





end