ModLoader.SetupFileHook( "lua/CommAbilities/Alien/Contamination.lua", "lua/CommAbilities/Alien/Contamination_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/Marine_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/Clog_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Alien.lua", "lua/Alien_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/RoboticsFactory.lua", "lua/RoboticsFactory_Siege.lua", "replace" ) 
ModLoader.SetupFileHook( "lua/Sentry.lua", "lua/Sentry_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/JetpackMarine_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Crag.lua", "lua/Crag_Siege.lua", "post" )







ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/TechTreeConstants_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/TechData_Siege.lua", "post" )
