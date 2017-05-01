-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/

class 'SandCastle' (ScriptActor)
SandCastle.kMapName = "sandcastle"


if Server then

SandCastle.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")
SandCastle.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")


end


local networkVars = 

{
   SiegeTimer = "float",
   FrontTimer = "float",
   frontOpened = "boolean",
   siegeOpened = "boolean",
}
function SandCastle:TimerValues()
   if kSiegeTimer == nil then kSiegeTimer = 960 end
   if kFrontTimer == nil then kFrontTimer = 330 end
   if kPrimaryTimer == nil then kPrimaryTimer = 0 end
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
   self.siegeOpened = false
   self.frontOpened = false
end

function SandCastle:OnReset() 
   self:TimerValues()
end
function SandCastle:GetIsMapEntity()
return true
end
function SandCastle:ClearAttached()
return 
end
function SandCastle:OnCreate()
  self:TimerValues()
      self:SetUpdates(true)
end
local function DoubleCheckLocks(who)
               for index, door in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 door:CloseLock()
              end 
end
function SandCastle:OnRoundStart() 
  self:TimerValues()
  DoubleCheckLocks(self)
  GetGamerules():SetDamageMultiplier(0)
end
function SandCastle:GetSiegeLength()
 return self.SiegeTimer
end
function SandCastle:SetSiegeOpenBoolean(option)
 self.siegeOpened = option
end
function SandCastle:GetSiegeOpenBoolean()
  //Print("Sandcastle siege open is %s", self.siegeOpened)
 return self.siegeOpened 
end
function SandCastle:GetFrontOpenBoolean()
 return self.frontOpened
end
function SandCastle:GetFrontLength()
 return self.FrontTimer 
end
function SandCastle:GetPrimaryLength()
 return self.PrimaryTimer 
end
local function OpenEightTimes(who)

if not who then return end

for i = 1, math.max(kDoorMoveUpVect / 2, 16) do //more than 8
                who:Open()
                who.isvisible = false
end

end
function SandCastle:OpenSiegeDoors()
     self.SiegeTimer = 0
     if GetGameStarted() then GetImaginator():OnSiegeOpen() end
     -- Print("OpenSiegeDoors SandCastle")
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 if not siegedoor:isa("FrontDoor") then OpenEightTimes(siegedoor) end
              end 
              
              if GetGameStarted() then
              
                for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(SandCastle.kSiegeDoorSound, player)
              end
              
              end  
              
              self.siegeOpened = true
              
              
end

function SandCastle:OpenFrontDoors()
           GetGamerules():SetDamageMultiplier(1)
      self.FrontTimer = 0
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                      OpenEightTimes(frontdoor)
              end 
              
               if GetGameStarted() then 

              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(SandCastle.kFrontDoorSound, player)
              end

               end
               
               self.frontOpened = true
end
function SandCastle:OpenPrimaryDoors()
          GetGamerules():SetDamageMultiplier(1)
      self.PrimaryTimer = 0
               for index, Primarydoor in ientitylist(Shared.GetEntitiesWithClassname("SideDoor")) do
                      OpenEightTimes(Primarydoor)
              end 

             -- for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
             -- StartSoundEffectForPlayer(SandCastle.kFrontDoorSound, player)
             -- end


end
function SandCastle:GetIsSiegeOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.SiegeTimer
end
function SandCastle:GetIsFrontOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.FrontTimer
end
function SandCastle:GetIsPrimaryOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.PrimaryTimer
end
function SandCastle:CountSTimer()
       if  self:GetIsSiegeOpen() then
               self:OpenSiegeDoors()
       end
       
end
function SandCastle:CountPrimaryTimer()
       if  self:GetIsPrimaryOpen() then
               self:OpenPrimaryDoors()
       end
       
end
function SandCastle:ARCHitSiegeRoom()
   local inside = {}
   
   for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Live", 2, self:GetOrigin(), 99999)) do
      if not entity:isa("Player") and GetIsInSiege(entity) then
      table.insert(inside, entity) 
      end
    end
    local victim = nil
    if #inside == 0 then return end
    for i = 1, #inside do
     local ent = inside[i]
      local damage = math.random(100,400)
      ent:TakeDamage(damage, nil, nil, nil, nil, damage / 2, damage,  kDamageType.Normal)
     ent:TriggerEffects("arc_hit_secondary")
     
      GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = (ent:GetCoords() )})
      
    end
    
    

    
end
function SandCastle:OnUpdate(deltatime)
  if Server then
    local gamestarted = GetGamerules():GetGameStarted()
  if gamestarted then 
       if not self.timelasttimerup or self.timelasttimerup + 1 <= Shared.GetTime() then
       
       
       if self.FrontTimer ~= 0 then self:FrontDoorTimer() end
       
           if self. SiegeTimer ~= 0 then
           self:CountSTimer() 
           else
           
           if not self.timelastArcHIT or self.timelastArcHIT + math.random(8,12) <= Shared.GetTime() then
               self:ARCHitSiegeRoom()
               self.timelastArcHIT = Shared.GetTime()
            end
            
          end
          
          
      if self. PrimaryTimer ~= 0 then self:CountPrimaryTimer() end
        self.timeLastAutomations = Shared.GetTime()
         end
  
  end
  end
end
function SandCastle:FrontDoorTimer()
    if self:GetIsFrontOpen() then
         boolean = true
         self:OpenFrontDoors() -- Ddos!
       end

end
function SandCastle:OnPreGame()
   for i = 1, 4 do
     Print("SandCastle OnPreGame")
   end
   
   for i = 1, 8 do
   self:OpenSiegeDoors()
   self:OpenFrontDoors()
   self:OpenPrimaryDoors()
   end
   
end

Shared.LinkClassToMap("SandCastle", SandCastle.kMapName, networkVars)





