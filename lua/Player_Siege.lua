--Kyle 'Avoca' Abent
local networkVars = {gravity = "private float (-5 to 5 by 1)",} 

local origcreate = Player.OnCreate
function Player:OnCreate()
   origcreate(self)
    self.gravity = 0
end
    local origGravity = Player.ModifyGravityForce
    function Player:ModifyGravityForce(gravityTable)
    
    if self.gravity == 0 then
    origGravity(self, gravityTable)
    else
        gravityTable.gravity = ConditionalValue(self:GetIsOnGround(), 0, self.gravity)
    end
    
        if self.gravity ~= 0 then
       
    end
end
function Player:SetGravity(value)
self.gravity = value
end
function Player:HookWithShineToBuyMist(player)
       self:Kill() //What a horrible Joke.. Oh Hey! Purchase Mist! ... *Dies
                   --11.15 well except for that this is replaced via shine to do the dirty work, ya dig. I digg.
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


if Server then

local origcopydata = Player.CopyPlayerDataFrom

function Player:CopyPlayerDataFrom(player)

origcopydata(self, player)

self.gravity = player.gravity


end


end