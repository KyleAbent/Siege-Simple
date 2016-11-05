
AchievementGiverMixin = CreateMixin(AchievementGiverMixin)
AchievementGiverMixin.type = "AchievementGiver"

function AchievementGiverMixin:__initmixin()
	self.lastSneak = 0
	self.lastAttacks = {}
	self.weldedUnits = {}
end
