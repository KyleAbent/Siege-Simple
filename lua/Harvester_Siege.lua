Script.Load("lua/Additions/SaltMixin.lua")

local networkVars = {}
AddMixinNetworkVars(SaltMixin, networkVars)

local origcreate = Harvester.OnCreate
function Harvester:OnCreate()
   origcreate(self)
        InitMixin(self, SaltMixin)
 end


Shared.LinkClassToMap("Harvester", Harvester.kMapName, networkVars)