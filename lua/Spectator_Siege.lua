--Kyle 'Avoca' Abent 
local networkVars = {lastswitch = "private time", nextangle = "private integer (0 to 8)", lockedId = "entityid"} 
class 'AvocaSpectator' (Spectator)
AvocaSpectator.kMapName = "Spectator"

function AvocaSpectator:OnCreate()
 Spectator.OnCreate(self)
  self.lastswitch = Shared.GetTime()
       if Server then
         self:AddTimedCallback( AvocaSpectator.UpdateCamera, 1 )
        end
        self.nextangle = math.random(4,8)
         self.lockedId = Entity.invalidI 
end
function AvocaSpectator:SetLockOnTarget(userid)
   self.lockedId = userid
end
function AvocaSpectator:BreakChains()
  self.lockedId = Entity.invalidI 
end
function AvocaSpectator:LockAngles()
  local playerOfLock = Shared.GetEntity( self.lockedId ) 
    if playerOfLock ~= nil then
            if (playerOfLock.GetIsAlive and playerOfLock:GetIsAlive())  then
             local dir = GetNormalizedVector(playerOfLock:GetOrigin() - self:GetOrigin())
             local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
             self:SetOffsetAngles(angles)
            end
  end
end
function AvocaSpectator:ChangeView(self, untilNext, betweenLast)
--Shine
end
function AvocaSpectator:LockAnglesTarget(who)

end
function AvocaSpectator:UnlockAngles()

end
function AvocaSpectator:UpdateCamera()
         self:LockAngles()
         if GetIsTimeUp(self.lastswitch, self.nextangle ) then
             -- Print("AvocaSpectator ChangeView")
              self.nextangle = math.random(4,8)
              self.lastswitch = Shared.GetTime()
              self:ChangeView(self, self.nextangle, self.lastswitch )
          end
          return true
end
Shared.LinkClassToMap("AvocaSpectator", AvocaSpectator.kMapName, networkVars)