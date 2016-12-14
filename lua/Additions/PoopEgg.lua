Script.Load("lua/Egg.lua")

class 'PoopEgg' (Egg)

PoopEgg.kMapName = "poopegg"

local networkVars = { }


Shared.LinkClassToMap("PoopEgg", PoopEgg.kMapName, networkVars)