Script.Load("lua/Additions/SandMixin.lua")

local networkVars = {}
AddMixinNetworkVars(SandMixin, networkVars)

local origcreate = Harvester.OnCreate
function Harvester:OnCreate()
   origcreate(self)
        InitMixin(self, SandMixin)
 end


Shared.LinkClassToMap("Harvester", Harvester.kMapName, networkVars)