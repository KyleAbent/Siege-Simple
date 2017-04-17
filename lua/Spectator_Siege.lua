--Kyle 'Avoca' Abent 
//Well I am copying everything, you know. But I like my name cause it's a good one.
local networkVars = {lastswitch = "private time", nextangle = "private integer (0 to 8)", lockedId = "entityid", lastzoom = "private time"} 
class 'AvocaSpectator' (Spectator)
AvocaSpectator.kMapName = "Spectator"

--AvocaSpectator.kModelName = PrecacheAsset("models/alien/fade/fade.model")

function AvocaSpectator:OnInitialized()

    Spectator.OnInitialized(self)

end
function AvocaSpectator:GetControllerPhysicsGroup()
    return PhysicsGroup.BigPlayerControllersGroup  
end
function AvocaSpectator:OnCreate()
 Spectator.OnCreate(self)
  self.lastswitch = Shared.GetTime()
       if Server then
         self:AddTimedCallback( AvocaSpectator.UpdateCamera, 1 )
        end
        self.nextangle = math.random(4,8)
         self.lockedId = Entity.invalidI 
          self.lastzoom = 0
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
function AvocaSpectator:OnEntityChange(oldId)

    if self.lockedId == oldId then
        self.lockedId = Entity.invalidId
       self.lastswitch = Shared.GetTime()
       self.nextangle = math.random(4,8)
     self:ChangeView(self, self.nextangle, self.lastswitch )
    end    
    

end
function AvocaSpectator:OverrideInput(input)

    ClampInputPitch(input)
     //Attempts of Zooming in when outside radius
          if  self.lockedId ~= Entity.invalidI then
            local target = Shared.GetEntity( self.lockedId ) 
              if target and  ( target.GetIsAlive and target:GetIsAlive() ) then
                 local distance = self:GetDistance(target)
                 if distance >= 5 and self.lastzoom + 1 <= Shared.GetTime() then
                    //  Print("Distance %s lastzoom %s", distance, self.lastzoom) //debug my ass
                      self.lastzoom = Shared.GetTime()   //java is leaking
                      input.move.z = input.move.z + 1
                      local scalar = distance - 4
                      local ymove = 0
                      local myY = self:GetOrigin().y
                      local urY = target:GetOrigin().y
                      local difference =  urY - myY
                            if difference == 0 then
                                ymove = difference
                            elseif difference <= -1 then
                               ymove = -1
                            elseif difference >= 1 then
                               ymove = 1
                            end
                       input.move.y = input.move.y + (ymove) 
                   elseif distance <= 1.8 and self.lastzoom + 1 <= Shared.GetTime() then
                   input.move.z = input.move.z - 1
                     // Print(" new distance is %s, new lastzoom is %s", distance, self.lastzoom)
                 end
              end
          
          end
    
    return input
    
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