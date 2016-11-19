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
   SideTimer = "float",
}
function SandCastle:TimerValues()
   if kSiegeTimer == nil then kSiegeTimer = 960 end
   if kFrontTimer == nil then kFrontTimer = 330 end
   if kSideTimer == nil then kSideTimer = 0 end
   if kDoorMoveUpVect == nil then kDoorMoveUpVect = 6 end
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
   self.SideTimer = kSideTimer
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
local function MoveChairToAllowTwo(who)
               for index, CC in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
                 CC:SetOrigin(FindFreeSpace(CC:GetOrigin()))
                 break
              end 
end
function SandCastle:OnRoundStart() 


--if Server then  MoveChairToAllowTwo() end
  self:TimerValues()
  -- self:AutoBioMass()
  DoubleCheckLocks(self)
  GetGamerules():SetDamageMultiplier(0)
end
function SandCastle:GetSiegeLength()
 return self.SiegeTimer
end
function SandCastle:GetFrontLength()
 return self.FrontTimer 
end
function SandCastle:GetSideLength()
 return self.SideTimer 
end
local function OpenEightTimes(who)

if not who then return end

for i = 1, 8 do
                who:Open()
                who.isvisible = false
end

end
function SandCastle:OpenSiegeDoors()
     self.SiegeTimer = 0
     -- Print("OpenSiegeDoors SandCastle")
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 if not siegedoor:isa("FrontDoor") then OpenEightTimes(siegedoor) end
              end 
              
                for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(SandCastle.kSiegeDoorSound, player)
              end
              
end
function SandCastle:OpenFrontDoors()
           GetGamerules():SetDamageMultiplier(1)
      self.FrontTimer = 0
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                      OpenEightTimes(frontdoor)
              end 

              for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
              StartSoundEffectForPlayer(SandCastle.kFrontDoorSound, player)
              end


end
function SandCastle:OpenSideDoors()
          GetGamerules():SetDamageMultiplier(1)
      self.SideTimer = 0
               for index, sidedoor in ientitylist(Shared.GetEntitiesWithClassname("SideDoor")) do
                      OpenEightTimes(sidedoor)
              end 

             -- for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
             -- StartSoundEffectForPlayer(SandCastle.kFrontDoorSound, player)
             -- end


end
function SandCastle:GetIsSiegeOpen()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.SiegeTimer
end
function SandCastle:GetIsFrontOpen()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.FrontTimer
end
function SandCastle:GetIsSideOpen()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.SideTimer
end
function SandCastle:CountSTimer()
       if  self:GetIsSiegeOpen() then
               self:OpenSiegeDoors()
       end
       
end
function SandCastle:CountSideTimer()
       if  self:GetIsSideOpen() then
               self:OpenSideDoors()
       end
       
end
function SandCastle:OnUpdate(deltatime)
  if Server then
    local gamestarted = GetGamerules():GetGameStarted()
  if gamestarted then 
       if not self.timelasttimerup or self.timelasttimerup + 1 <= Shared.GetTime() then
       if self.FrontTimer ~= 0 then self:FrontDoorTimer() end
      if self. SiegeTimer ~= 0 then self:CountSTimer() end
      if self. SideTimer ~= 0 then self:CountSideTimer() end
        self.timeLastAutomations = Shared.GetTime()
         end
  
  end
  end
end
function SandCastle:AddSiegeTime(seconds)
  if not self:GetIsSiegeOpen() then self.SiegeTimer = self.SiegeTimer + seconds end
end
function SandCastle:FrontDoorTimer()
    if self:GetIsFrontOpen() then
         boolean = true
         self:OpenFrontDoors() -- Ddos!
       end

end
function SandCastle:OnPreGame()
  GetGamerules():SetDamageMultiplier(1)
   for i = 1, 4 do
     Print("SandCastle OnPreGame")
   end
   
   for i = 1, 8 do
   self:OpenSiegeDoors()
   self:OpenFrontDoors()
   self:OpenSideDoors()
   end
   
end

Shared.LinkClassToMap("SandCastle", SandCastle.kMapName, networkVars)





