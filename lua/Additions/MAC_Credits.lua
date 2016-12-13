Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/ConstructMixin.lua")


class 'MACCredit' (MAC)
MACCredit.kMapName = "maccredit"


local networkVars = {} --fuckbitchz
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(LevelsMixin, networkVars)
local origmac  = MAC.OnCreate
function MACCredit:OnCreate()


origmac(self)
InitMixin(self, ConstructMixin)


end
function MACCredit:OnInitialized()
MAC.OnInitialized(self)
InitMixin(self, LevelsMixin)
end
    function MACCredit:GetMaxLevel()
    return kDefaultLvl
    end
    function MACCredit:GetAddXPAmount()
     return 0.05 * 0.05
    end
function MACCredit:OnConstructionComplete()
local nearestplayer = GetNearest(self:GetOrigin(), "Marine", 1, function(ent) return ent:GetIsAlive() and ent:GetArmorScalar() < 1 end)
  if nearestplayer then
   self:ProcessFollowAndWeldOrder(Shared.GetTime(), nearestplayer, nearestplayer:GetOrigin()) 
   end
 end
 function MACCredit:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.MAC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function MACSiege:OnUpdate(deltaTime)

MAC.OnUpdate(self, deltaTime)

if self.welding or self.constructing then self:AddXP(self:GetAddXPAmount()) end

end
    Shared.LinkClassToMap("MACCredit", MACCredit.kMapName, networkVars)