if Server then

function Gamerules:GetDamageMultiplier()
    return ConditionalValue(not self:GetGameStarted(), 1,self.damageMultiplier)
end

--This seems like the least expensive method. Rather than computing damage checks every instance, for example. 
--Simply adjusting an already existing damage adjustment, that originally requires cheats. All i'm doing is using this
--pre existing method and reversing the complicity. Other than the ability of deciding who can take damage that the more calculative may cost.

end