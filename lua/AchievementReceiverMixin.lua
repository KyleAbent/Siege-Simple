
AchievementReceiverMixin = CreateMixin(AchievementReceiverMixin)
AchievementReceiverMixin.type = "AchievementReceiver"

function AchievementReceiverMixin:__initmixin()	
		self.weldedPowerNodes = 0
		self.weldedPlayers = 0
		self.buildResTowers = 0
		self.killedResTowers = 0
		self.defendedResTowers = 0
		self.followedOrders = 0
		self.parsitedPlayers = 0
		self.structureDamageDealt = 0
		self.playerDamageDealt = 0
		self.destroyedRessources = 0
end


if Client then



	function AchievementReceiverMixin:GetMaxPlayer()

		return 0
	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)
	
		end

end