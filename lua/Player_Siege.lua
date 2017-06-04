--Kyle 'Avoca' Abent
Script.Load("lua/GlowMixin.lua")
local networkVars = {gravity = "float (-5 to 5 by 1)", modelsize = "private float (-9 to 9 by 1)",} 
AddMixinNetworkVars(GlowMixin, networkVars)
local origcreate = Player.OnCreate
function Player:OnCreate()
   origcreate(self)
    self.gravity = 0
    self.modelsize = 1
end

local originit = Player.OnInitialized
function Player:OnInitialized()
    originit(self)
    InitMixin(self, GlowMixin)

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
function Player:AdjustModelSize(number)
self.modelsize = number
end
/*
local origsize = Player.OnAdjustModelCoords
function Player:OnAdjustModelCoords(modelCoords)
     if origsize then origsize(self, modelCoords) end
    local coords = modelCoords
    if self.modelsize ~= 1 then
        coords.xAxis = coords.xAxis * self.modelsize
        coords.yAxis = coords.yAxis * self.modelsize
        coords.zAxis = coords.zAxis * self.modelsize
    end
    return coords
    
end
*/
if Server then

local origcopydata = Player.CopyPlayerDataFrom

function Player:CopyPlayerDataFrom(player)

origcopydata(self, player)

self.gravity = player.gravity
self.modelsize = player.modelsize



end


end
Shared.LinkClassToMap("Player", Player.kMapName, networkVars)