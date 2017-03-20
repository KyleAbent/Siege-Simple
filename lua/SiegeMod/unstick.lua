--anti unstuck exploit -.-


--
-- Modifies the shine unstuck plugin so that it 
--

Script.Load("lua/Player.lua")

-- Helper function to determine whether or not two position vectors are on the same side of a plane obstacle, such as a door
function SwappedSides(Obstacle, currentPosition, newPosition)

    -- Calculate the new/old positions relative to the obstacles's position
    local oldPos = Obstacle:GetOrigin() - currentPosition
    local newPos = Obstacle:GetOrigin() - newPosition

    -- Calculate a vector perpendicular to the door's plane
    local obstacleAngles = Obstacle:GetAngles()
    AnglesTo2PiRange(obstacleAngles)
    local obstacleVector = Vector(math.sin(obstacleAngles.yaw), 0, math.cos(obstacleAngles.yaw))

    -- Ignore any horizontal obstacles, we're mostly concerned with vertical obstacles such as doors
    if (obstacleAngles.pitch > 0.25 * math.pi and obstacleAngles.pitch < 0.75 * math.pi) or
       (obstacleAngles.pitch > 1.25 * math.pi and obstacleAngles.pitch < 1.75 * math.pi) then
        return false
    end

    -- Calculate which side of the door the old/new position are on
    local oldSide = GetSign(oldPos:DotProduct(obstacleVector))
    local newSide = GetSign(newPos:DotProduct(obstacleVector))

    return oldSide ~= newSide

end

function SiegeUnstickPlayer(self, Player, Pos)
	local TechID = kTechId.Skulk

	if Player:GetIsAlive() then
		TechID = Player:GetTechId()
	end

	local Bounds = LookupTechData( TechID, kTechDataMaxExtents )

	if not Bounds then
		return false
	end

	local Height, Radius = GetTraceCapsuleFromExtents( Bounds )
	
	local SpawnPoint
	local ResourceNear
	local i = 1

        -- Grab any nearby doors so we can make sure that the player isn't unstucking through them
        local nearbyDoors = #GetEntitiesWithinRange( "FrontDoor", Pos, 10 ) > 0 and not GetFrontDoorOpen()
        local Naughty = nearbyDoors

	repeat
		SpawnPoint = GetRandomSpawnForCapsule( Height, Radius, Pos, 2, 6, EntityFilterAll() )

                ResourceNear = false
                OtherSideOfObstacle = false

		if SpawnPoint then
		        ResourceNear = #GetEntitiesWithinRange( "ResourcePoint", SpawnPoint, 2 ) > 0
		end

                -- Check that the player haven't gone through any nearby closed doors or barriers
                if not ResourceNear and SpawnPoint then

                    if NearbyDoors then

                                 Naughty = true
                    end

                end

		i = i + 1
	until not ResourceNear or i > 100

        if Naughty then

              Player:GetTeam():ReplaceRespawnPlayer(Player)

        end

	if SpawnPoint then

		SpawnPlayerAtPoint( Player, SpawnPoint )

		return true

	end

	return false
end

if Shine and Shine:IsExtensionEnabled("unstuck") then

    Shine.Plugins["unstuck"].UnstickPlayer = SiegeUnstickPlayer

end