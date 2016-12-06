  function ForceEvenTeams()
    
        local kTeamSign = { [1] = 1, [2] = -1 }
                
        local players = ForceEvenTeams_GetPlayers()
        table.sort( players, function( a, b )
                return ForceEvenTeams_GetPlayerSkill(b) < ForceEvenTeams_GetPlayerSkill(a)
                end )
        
        local teamCount = { ForceEvenTeams_GetNumPlayersOnTeam(kTeam1Index), ForceEvenTeams_GetNumPlayersOnTeam(kTeam2Index) }
        local maxTeamSize = math.ceil( #players / 2 )
        local skillDifference = 0
        
        local playersToAssign = {}
        
        local playerTeamNumber
        local playerTeamSign
        
        for round=1,3 do
            for _, player in ipairs(players) do
                playerTeamNumber = player:GetTeamNumber()
                playerTeamSign = kTeamSign[playerTeamNumber or 0]
                
                local shouldProcess = false 
                if playerTeamSign and player:isa("Commander") then
                    shouldProcess = round == 1
                elseif playerTeamSign then
                    shouldProcess = round == 2
                else
                    shouldProcess = round == 3
                end
                
                if shouldProcess then
                    if not playerTeamSign or not player:isa("Commander") and not player:isa("Spectator") then -- if not on a team or not a commander, player can be swapped later on
                        if not playerTeamSign then -- if not on a team yet, pick a team
                            if teamCount[1] == maxTeamSize then
                                playerTeamNumber = 2
                            elseif teamCount[2] == maxTeamSize then
                                playerTeamNumber = 1
                            elseif skillDifference > 0 then
                                playerTeamNumber = 2
                            elseif skillDifference < 0 then
                                playerTeamNumber = 1
                            else
                                playerTeamNumber = math.random(1,2)
                            end
                            
                            -- new player is being added to a team, accumulate the difference
                            teamCount[ playerTeamNumber ] = teamCount[ playerTeamNumber ] + 1
                        end
                        
                        playersToAssign[ #playersToAssign + 1 ] = 
                        { 
                            player = player; 
                            teamDestination = playerTeamNumber;
                            hadPreference = playerTeamSign;
                        };
                        
                    end
                    
                    -- accumulate the skill difference
                    skillDifference = skillDifference + kTeamSign[playerTeamNumber] * ForceEvenTeams_GetPlayerSkill(player)
                end
            end
        end
        
        -- Balance out teams if uneven by swapping the least skilled player (results in smallest delta)
        local otherTeamNumber
        for playerTeamNumber = 1,2 do
            otherTeamNumber = playerTeamNumber == 2 and 1 or 2
            if teamCount[playerTeamNumber] > maxTeamSize then
                for i=#playersToAssign,1,-1 do
                    if playersToAssign[i].teamDestination == playerTeamNumber then
                        teamCount[ playerTeamNumber ] = teamCount[ playerTeamNumber ] - 1                        
                        teamCount[ otherTeamNumber ] = teamCount[ otherTeamNumber ] + 1
                        playersToAssign[i].teamDestination = otherTeamNumber
                        skillDifference = skillDifference + 2 * kTeamSign[otherTeamNumber] * ForceEvenTeams_GetPlayerSkill(playersToAssign[i].player)
                    end
                    
                    if teamCount[playerTeamNumber] == maxTeamSize then
                        break
                    end
                end
            end
        end
        
        -- We break the optimization into two rounds, one where we optimize only the ambivalent players
        -- and one where we optimize everyone. This makes it more likely that we'll get into a local optima
        -- before we get to players that have already picked a team.
        -- To optimize, we greedily find the swap among all pairs of players that minimizes the skill difference
        
        local bestSwapI, bestSwapJ, bestSwapDelta
        local playerToAssignI,teamI        
        local playerToAssignJ,teamJ
        local delta
        
        for round = 0, 1 do            
            for swaps = 0, 20 do -- 20 swaps per round should be plenty
                bestSwapI = -1
                bestSwapJ = -1
                bestSwapDelta = skillDifference
                for i = 1, #playersToAssign do
                    playerToAssignI = playersToAssign[i]
                    teamI = playerToAssignI.teamDestination
                    -- In round 1 do everyone, in round 0 only the ambivalent players.
                    if round == 1 or not playerToAssignI.hasPreference then
                        for j = i + 1, #playersToAssign do
                            playerToAssignJ = playersToAssign[j]
                            local teamJ = playerToAssignJ.teamDestination
                            if teamI ~= teamJ and (round == 1 or not playerToAssignJ.hasPreference ) then
                                delta = 
                                    kTeamSign[teamI] * ForceEvenTeams_GetPlayerSkill(playerToAssignI.player) + 
                                    kTeamSign[teamJ] * ForceEvenTeams_GetPlayerSkill(playerToAssignJ.player)
                                if math.abs(skillDifference - 2*delta) < math.abs(bestSwapDelta) then
                                    bestSwapI = i
                                    bestSwapJ = j
                                    bestSwapDelta = skillDifference - 2*delta
                                    --RawPrint( "Good", ForceEvenTeams_GetPlayerSkill(playerToAssignI.player) , ForceEvenTeams_GetPlayerSkill(playerToAssignJ.player), delta, skillDifference - delta, bestSwapDelta )
                                else
                                    --RawPrint( "Bad", ForceEvenTeams_GetPlayerSkill(playerToAssignI.player) , ForceEvenTeams_GetPlayerSkill(playerToAssignJ.player), delta, skillDifference - delta, bestSwapDelta )
                                end
                            end
                        end
                    end
                end
                if bestSwapI ~= -1 then
                    playersToAssign[bestSwapI].teamDestination, playersToAssign[bestSwapJ].teamDestination 
                        = playersToAssign[bestSwapJ].teamDestination, playersToAssign[bestSwapI].teamDestination
                    --RawPrint( "Swapping", bestSwapI, bestSwapJ, skillDifference, bestSwapDelta )
                    skillDifference = bestSwapDelta
                else
                    break
                end
            end
        end

        local playerToAssign
        for i = 1, #playersToAssign do
            playerToAssign = playersToAssign[i]
            ForceEvenTeams_AssignPlayer( playerToAssign.player, playerToAssign.teamDestination )
        end
    end