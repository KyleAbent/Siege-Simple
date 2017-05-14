
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kUpgrades = {
    kTechId.Crush,
    kTechId.Carapace,
    kTechId.Regeneration,
    kTechId.Redemption,
    
    kTechId.Rebirth,
        
    kTechId.Hunger,
    kTechId.ThickenedSkin,
    
    kTechId.Vampirism,
    kTechId.Aura,
    kTechId.Focus,
    
    kTechId.Silence,
    kTechId.Celerity,
    kTechId.Adrenaline,
}

------------------------------------------
--  More urgent == should really attack it ASAP
------------------------------------------



local function PerformAttackEntity( eyePos, bestTarget, bot, brain, move )

    assert( bestTarget )

    local marinePos = bestTarget:GetOrigin()

    local doFire = false
    bot:GetMotion():SetDesiredMoveTarget( marinePos )
    
    
    local aliens = GetEntitiesWithinRange("Alien", bot:GetOrigin(), 20)
    
         if #aliens >= 1 and GetHasTech(bot, kTechId.PrimalScream)  then
                 weight = math.random(1,100)
           end
           
           if weight >= 70 then
               botty:GiveItem(PrimalScream.kMapName)
               botty:SetActiveWeapon(PrimalScream.kMapName)  
               move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
              botty:SetActiveWeapon(LerkBite.kMapName) 
           end
           
    
    local distance = eyePos:GetDistance(marinePos)
    if distance < 18 and GetBotCanSeeTarget( bot:GetPlayer(), bestTarget ) then
        doFire = true
    end
                
    if doFire then

        bot:GetMotion():SetDesiredViewTarget( bestTarget:GetEngagementPoint() )
        
        if distance > 3 then
            move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
        else    
            move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        end

        -- Attacking a structure
        if GetDistanceToTouch(eyePos, bestTarget) < 8 then
            -- Stop running at the structure when close enough
            bot:GetMotion():SetDesiredMoveTarget(nil)
        end

    end
    
    -- Occasionally jump
    if math.random() < 0.1 and bot:GetPlayer():GetIsOnGround() then
    
        move.commands = AddMoveCommand( move.commands, Move.Jump )

        -- When approaching, try to jump sideways
        bot.timeOfJump = Shared.GetTime()
        bot.jumpOffset = nil

    end 
    
    if not bot:GetPlayer():GetIsOnGround() and bot.timeOfJump and bot.timeOfJump + 0.15 < Shared.GetTime() then
        move.commands = AddMoveCommand( move.commands, Move.Jump )
    end    
    
    if bot.timeOfJump ~= nil and Shared.GetTime() - bot.timeOfJump < 0.3 then
        
        if bot.jumpOffset == nil then
            
            local botToTarget = GetNormalizedVectorXZ(marinePos - eyePos)
            local sideVector = botToTarget:CrossProduct(Vector(0, 1, 0))                
            if math.random() < 0.5 then
                bot.jumpOffset = botToTarget + sideVector
            else
                bot.jumpOffset = botToTarget - sideVector
            end            
            bot:GetMotion():SetDesiredViewTarget( bestTarget:GetEngagementPoint() )
            
        end
        
        bot:GetMotion():SetDesiredMoveDirection( bot.jumpOffset )
        
    end    
    
end

local function PerformAttack( eyePos, mem, bot, brain, move )

    assert( mem )

    local target = mem

    if target ~= nil then

        PerformAttackEntity( eyePos, target, bot, brain, move )

    else
    
        -- mem is too far to be relevant, so move towards it
        bot:GetMotion():SetDesiredViewTarget(nil)
        bot:GetMotion():SetDesiredMoveTarget(mem.lastSeenPos)

    end
    
    brain.teamBrain:AssignBotToMemory(bot, mem)

end

------------------------------------------
--  Each want function should return the fuzzy weight,
-- along with a closure to perform the action
-- The order they are listed matters - actions near the beginning of the list get priority.
------------------------------------------
kLerkBrainActions =
{
    
    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        return { name = "debug idle", weight = 0.001,
                perform = function(move)
                    bot:GetMotion():SetDesiredMoveTarget(nil)
                    -- there is nothing obvious to do.. figure something out
                    -- like go to the marines, or defend
                end }
    end,

    ------------------------------------------
    --
    ------------------------------------------
    CreateExploreAction( 0.01, function(pos, targetPos, bot, brain, move)
    
                if math.random() < 0.1 and bot:GetPlayer():GetIsOnGround() then
                
                    move.commands = AddMoveCommand( move.commands, Move.Jump )

                    -- When approaching, try to jump sideways
                    bot.timeOfJump = Shared.GetTime()
                    bot.jumpOffset = nil
           
                end 
    
                if not bot:GetPlayer():GetIsOnGround() and bot.timeOfJump and bot.timeOfJump + 0.3 < Shared.GetTime() then
                    move.commands = AddMoveCommand( move.commands, Move.Jump )
                    
                    if bot.timeOfJump + 3 > Shared.GetTime() then
                        bot.timeOfJump = Shared.GetTime()
                    end    
                    
                end 
    
                bot:GetMotion():SetDesiredMoveTarget(targetPos)
                bot:GetMotion():SetDesiredViewTarget(nil)
                end ),

    function(bot, brain)
        local weight = 0
        local player = bot:GetPlayer()

        if player:GetVelocity():GetLength() < 5 and (bot.timeOfJump or 0) + 2 < Shared.GetTime() then
            weight = 15
            bot.timeOfJump = Shared.GetTime()
        end

        return { name = "flap", weight = weight,
            perform = function(move)
                move.commands = AddMoveCommand( move.commands, Move.Jump )
            end }
    end,
    ------------------------------------------
    --
    ------------------------------------------
    
    function(bot, brain)
        local name = "evolve"

        local weight = 0.0
        local player = bot:GetPlayer()
        local s = brain:GetSenses()
        local res = player:GetPersonalResources()

        local distanceToNearestThreat = s:Get("nearestThreat").distance
        local desiredUpgrades = {}

        if player:GetIsAllowedToBuy() and
                (distanceToNearestThreat == nil or distanceToNearestThreat > 15) and
                (player.GetIsInCombat == nil or not player:GetIsInCombat()) then

            -- Safe enough to try to evolve

            local existingUpgrades = player:GetUpgrades()

            local avaibleUpgrades = player.lifeformUpgrades

            if not avaibleUpgrades then
                avaibleUpgrades = {}

                for i = 0, 2 do
                    table.insert(avaibleUpgrades, kUpgrades[math.random(1,3) + i * 3])
                end

                if player.lifeformEvolution then
                    table.insert(avaibleUpgrades, player.lifeformEvolution)
                end

                player.lifeformUpgrades = avaibleUpgrades
            end

            for i = 1, #avaibleUpgrades do
                local techId = avaibleUpgrades[i]
                local techNode = player:GetTechTree():GetTechNode(techId)

                local isAvailable = false
                local cost = 0
                if techNode ~= nil then
                    isAvailable = techNode:GetAvailable(player, techId, false)
                    cost = LookupTechData(techId, kTechDataGestateName) and GetCostForTech(techId) or LookupTechData(kTechId.Lerk, kTechDataUpgradeCost, 0)
                end

                if not player:GetHasUpgrade(techId) and isAvailable and res - cost > 0 and
                        GetIsUpgradeAllowed(player, techId, existingUpgrades) and
                        GetIsUpgradeAllowed(player, techId, desiredUpgrades) then
                    res = res - cost
                    table.insert(desiredUpgrades, techId)
                end
            end

            if  #desiredUpgrades > 0 then
                weight = 100.0
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                player:ProcessBuyAction( desiredUpgrades )
            end }

    end,

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        local name = "attack"
        local skulk = bot:GetPlayer()
        local eyePos = skulk:GetEyePos()
        
       local nearestnonMarine = GetNearestMixin(skulk:GetOrigin(), "Live", 1,  function(ent) return not ent:isa("Weapon") and not ent:isa("Player") and ent:GetCanTakeDamage() and GetLocationForPoint(skulk:GetOrigin()) ==  GetLocationForPoint(ent:GetOrigin())  end )
       local nearestMarine = GetNearest(skulk:GetOrigin(), "Player", 1,  function(ent) return GetLocationForPoint(skulk:GetOrigin()) ==  GetLocationForPoint(ent:GetOrigin())  end )        
       local bestMem =  nil
              
        if not nearestMarine and nearestnonMarine then bestMem = nearestnonMarine end
        
        if nearestMarine then bestMem = nearestMarine end
       
        local weight = 0.0

        if bestMem ~= nil then

            local dist = 0.0
            if bestMem ~= nil then
                dist = GetDistanceToTouch( eyePos, bestMem )
            else
                dist = eyePos:GetDistance( bestMem )
            end

            weight = math.random(10,30)
        end

        return { name = name, weight = weight,
            perform = function(move)
                PerformAttack( eyePos, bestMem, bot, brain, move )
            end }
    end,    

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        local name = "pheromone"
        
        local skulk = bot:GetPlayer()
        local eyePos = skulk:GetEyePos()

        local pheromones = EntityListToTable(Shared.GetEntitiesWithClassname("Pheromone"))            
        local bestPheromoneLocation = nil
        local bestValue = 0
        
        for p = 1, #pheromones do
        
            local currentPheromone = pheromones[p]
            if currentPheromone then
                local techId = currentPheromone:GetType()
                            
                if techId == kTechId.ExpandingMarker or techId == kTechId.ThreatMarker then
                
                    local location = currentPheromone:GetOrigin()
                    local locationOnMesh = Pathing.GetClosestPoint(location)
                    local distanceFromMesh = location:GetDistance(locationOnMesh)
                    
                    if distanceFromMesh > 0.001 and distanceFromMesh < 2 then
                    
                        local distance = eyePos:GetDistance(location)
                        
                        if currentPheromone.visitedBy == nil then
                            currentPheromone.visitedBy = {}
                        end
                                        
                        if not currentPheromone.visitedBy[bot] then
                        
                            if distance < 5 then 
                                currentPheromone.visitedBy[bot] = true
                            else   
            
                                -- Value goes from 5 to 10
                                local value = 5.0 + 5.0 / math.max(distance, 1.0) - #(currentPheromone.visitedBy)
                        
                                if value > bestValue then
                                    bestPheromoneLocation = locationOnMesh
                                    bestValue = value
                                end
                                
                            end    
                            
                        end    
                            
                    end
                    
                end
                        
            end
            
        end
        
        local weight = EvalLPF( bestValue, {
            { 0.0, 0.0 },
            { 10.0, 1.0 }
            })

        return { name = name, weight = weight,
            perform = function(move)
                bot:GetMotion():SetDesiredMoveTarget(bestPheromoneLocation)
                bot:GetMotion():SetDesiredViewTarget(nil)
            end }
    end,

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        local name = "order"

        local skulk = bot:GetPlayer()
        local order = bot:GetPlayerOrder()

        local weight = 0.0
        if order ~= nil then
            weight = 10.0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if order then

                    local target = Shared.GetEntity(order:GetParam())

                    if target ~= nil and order:GetType() == kTechId.Attack then

                        PerformAttackEntity( skulk:GetEyePos(), target, bot, brain, move )
                        
                    else

                        if brain.debug then
                            DebugPrint("unknown order type: %s", ToString(order:GetType()) )
                        end

                        bot:GetMotion():SetDesiredMoveTarget( order:GetLocation() )
                        bot:GetMotion():SetDesiredViewTarget( nil )
                        
                        if math.random() < 0.1 and bot:GetPlayer():GetIsOnGround() then
                        
                            move.commands = AddMoveCommand( move.commands, Move.Jump )

                            -- When approaching, try to jump sideways
                            bot.timeOfJump = Shared.GetTime()
                            bot.jumpOffset = nil
                   
                        end 
            
                        if not bot:GetPlayer():GetIsOnGround() and bot.timeOfJump and bot.timeOfJump + 0.3 < Shared.GetTime() then
                            move.commands = AddMoveCommand( move.commands, Move.Jump )
                            
                            if bot.timeOfJump + 3 > Shared.GetTime() then
                                bot.timeOfJump = Shared.GetTime()
                            end    
                            
                        end

                    end
                end
            end }
    end,

    function(bot, brain)

        local name = "retreat"
        local player = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local hive = sdb:Get("nearestHive")
        local hiveDist = hive and player:GetOrigin():GetDistance(hive:GetOrigin()) or 0
        local healthFraction = sdb:Get("healthFraction")

        -- If we are pretty close to the hive, stay with it a bit longer to encourage full-healing, etc.
        -- so pretend our situation is more dire than it is
        if hiveDist < 4.0 and healthFraction < 0.9 then
            healthFraction = healthFraction / 3.0
        end

        local weight = 0.0

        if hive then

            weight = EvalLPF( healthFraction, {
                { 0.0, 25.0 },
                { 0.6, 0.0 },
                { 1.0, 0.0 }
            })
        end

        return { name = name, weight = weight,
            perform = function(move)
                if hive then

                    -- we are retreating, unassign ourselves from anything else, e.g. attack targets
                    brain.teamBrain:UnassignBot(bot)

                    local touchDist = GetDistanceToTouch( player:GetEyePos(), hive )
                    if touchDist > 1.5 then
                        bot:GetMotion():SetDesiredMoveTarget( hive:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredViewTarget( nil )
                    else
                        -- sit and wait to heal
                        bot:GetMotion():SetDesiredViewTarget( hive:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                    end
                end

            end }

    end,

}

------------------------------------------
--
------------------------------------------
function CreateLerkBrainSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("allThreats", function(db)
            local player = db.bot:GetPlayer()
            local team = player:GetTeamNumber()
            local memories = GetTeamMemories( team )
            return FilterTableEntries( memories,
                function( mem )                    
                    local ent = Shared.GetEntity( mem.entId )
                    
                    if ent:isa("Player") or ent:isa("Sentry") then
                        local isAlive = HasMixin(ent, "Live") and ent:GetIsAlive()
                        local isEnemy = HasMixin(ent, "Team") and ent:GetTeamNumber() ~= team                    
                        return isAlive and isEnemy
                    else
                        return false
                    end
                end)                
        end)

    s:Add("nearestHive", function(db)
        local player = db.bot:GetPlayer()
        local playerPos = player:GetOrigin()

        local hives = GetEntitiesForTeam("Hive", player:GetTeamNumber())

        local builtHives = {}

        -- retreat only to built hives
        for _, hive in ipairs(hives) do

            if hive:GetIsBuilt() and hive:GetIsAlive() then
                table.insert(builtHives, hive)
            end

        end

        Shared.SortEntitiesByDistance(playerPos, builtHives)

        return builtHives[1]
    end)

    s:Add("healthFraction", function(db)
        local player = db.bot:GetPlayer()
        return player:GetHealthFraction()
    end)

    s:Add("nearestThreat", function(db)
            local allThreats = db:Get("allThreats")
            local player = db.bot:GetPlayer()
            local playerPos = player:GetOrigin()
            
            local distance, nearestThreat = GetMinTableEntry( allThreats,
                function( mem )
                    local origin = mem.origin
                    if origin == nil then
                        origin = Shared.GetEntity(mem.entId):GetOrigin()
                    end
                    return playerPos:GetDistance(origin)
                end)

            return {distance = distance, memory = nearestThreat}
        end)

    return s
end
