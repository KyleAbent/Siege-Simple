if Server then
	
	local function RewardAchievement(player, name)
	end
	
	function AchievementReceiverMixin:CheckWeldedPowerNodes()
	end

	function AchievementReceiverMixin:CheckWeldedPlayers()
	end

	function AchievementReceiverMixin:CheckBuildResTowers()
	end

	function AchievementReceiverMixin:CheckKilledResTowers()
	end

	function AchievementReceiverMixin:CheckDefendedResTowers()

	end

	function AchievementReceiverMixin:CheckFollowedOrders()

	end

	function AchievementReceiverMixin:CheckParasitedPlayers()

	end

	function AchievementReceiverMixin:CheckStructureDamageDealt()
		
	end

	function AchievementReceiverMixin:CheckPlayerDamageDealt()

	end

	function AchievementReceiverMixin:CheckDestroyedRessources()

	end

	function AchievementReceiverMixin:OnPhaseGateEntry()
		
	end

	function AchievementReceiverMixin:OnUseGorgeTunnel()
	
	end

	function AchievementReceiverMixin:AddWeldedPowerNodes()
		
		

	end

	function AchievementReceiverMixin:AddWeldedPlayers()
       end
		function AchievementReceiverMixin:AddBuildResTowers()
		
	end

	function AchievementReceiverMixin:AddKilledResTowers()

	end

	function AchievementReceiverMixin:AddDefendedResTowers()

	end

	function AchievementReceiverMixin:AddParsitedPlayers()

	end

	function AchievementReceiverMixin:AddStructureDamageDealt(amount)

	end

	function AchievementReceiverMixin:AddPlayerDamageDealt(amount)

	end

	function AchievementReceiverMixin:AddDestroyedRessources(amount)

	end

	function AchievementReceiverMixin:CompletedCurrentOrder()

	end

	function AchievementReceiverMixin:ResetScores()

	end

	function AchievementReceiverMixin:CopyPlayerDataFrom(player)

	end

end

if Client then
	local kTimeNeededCaged = 3600 * 2 -- two hours of gametimes
	local kTimeNeededArcade = 3600


	function AchievementReceiverMixin:GetMaxPlayer()

		return 30
	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)

		end

end