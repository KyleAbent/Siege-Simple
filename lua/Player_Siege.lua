--Kyle 'Avoca' Abent
local networkVars = {hasball = "private boolean"} 
local kBallFlagAttachPoint = "Head"

local origcreate = Player.OnCreate
function Player:OnCreate()
   origcreate(self)
   self.hasball = false
end
    function Player:PreOnKill(attacker, doer, point, direction)
       self:ThrowBall()
    end
function Player:HookWithShineToBuyMist(player)
       self:Kill() //What a horrible Joke.. Oh Hey! Purchase Mist! ... *Dies
                   --11.15 well except for that this is replaced via shine to do the dirty work, ya dig. I digg.
end
function Player:GetBallFlagAttatchPoint(player)
       return kBallFlagAttachPoint
end

function Player:HookWithShineToBuyMed(player)
       self:Kill() 
       end
function Player:HookWithShineToBuyAmmo(player)
       self:Kill() 
end
function Player:RunCommand(string)
 self:GetClient():RunIt(string)
end
function Player:NotifyShineBallGiven(self)
end
function Player:GetHasBall()
 return GetBallForPlayerOwner(self)
end
function Player:GiveBall()
 self.hasball = true
  self:NotifyShineBallGiven(self)
end
function Player:ThrowBall()
   if self.hasball then
        FireBallProjectile(self)
        self.hasball = false
    end
end
local origbuttons = Player.HandleButtons
function Player:HandleButtons(input)
   origbuttons(self,input)
    if self.hasball and bit.band(input.commands, Move.Use) ~= 0 then
        self:ThrowBall()
     end
end