DigestMixin = CreateMixin(DigestMixin)
DigestMixin.type = "Digest"

local kRecycleEffectDuration = 2

DigestMixin.expectedCallback =
{
}

DigestMixin.optionalCallbacks =
{
    GetCanDigestOverride = "Return custom restrictions for recycling."
}

DigestMixin.expectedMixins =
{
    Research = "Required for recycle progress / cancellation."
}    

DigestMixin.networkVars =
{
    digested = "boolean"
}

function DigestMixin:__initmixin()
    self.digested = false
end

function DigestMixin:GetDigestActive()
    return self.researchingId == kTechId.Digest
end

function DigestMixin:OnRecycled()
end

function DigestMixin:GetCanRecycle()

    local canRecycle = true
    
    if self.GetCanRecycleOverride then
        canRecycle = self:GetCanDigestOverride()
    end

    return canRecycle and not self:GetDigestActive()    

end

function DigestMixin:OnResearchComplete(researchId)

    if researchId == kTechId.Digest then
        
        -- Do not display new killfeed messages during concede sequence
        if GetConcedeSequenceActive() then
            return
        end
        
        self:TriggerEffects("death")
        
        -- Amount to get back, accounting for upgraded structures too
        local upgradeLevel = 0
        if self.GetUpgradeLevel then
            upgradeLevel = self:GetUpgradeLevel()
        end
        
        local amount = GetRecycleAmount(self:GetTechId(), upgradeLevel) or 0
        -- returns a scalar from 0-1 depending on health the structure has (at the present moment)
        local scalar = self:GetRecycleScalar() * kRecyclePaybackScalar
        
        -- We round it up to the nearest value thus not having weird
        -- fracts of costs being returned which is not suppose to be
        -- the case.
        local finalRecycleAmount = math.round(amount * scalar)
        
        self:GetTeam():AddTeamResources(finalRecycleAmount)
        
        self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, finalRecycleAmount, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
        
        Server.SendNetworkMessage( "Recycle", BuildRecycleMessage(amount - finalRecycleAmount, self:GetTechId(), finalRecycleAmount), true )
        
        local team = self:GetTeam()
        local deathMessageTable = team:GetDeathMessage(team:GetCommander(), kDeathMessageIcon.Recycled, self)
        team:ForEachPlayer(function(player) if player:GetClient() then Server.SendNetworkMessage(player:GetClient(), "DeathMessage", deathMessageTable, true) end end)
        
        self.digested = true
        self.timeRecycled = Shared.GetTime()

        self:OnRecycled()
        
    end

end

function DigestMixin:GetIsRecycled()
    return self.digested
end

function DigestMixin:GetRecycleScalar()
    return self:GetHealth() / self:GetMaxHealth()
end

function DigestMixin:GetIsRecycling()
    return self.researchingId == kTechId.Digest
end

function DigestMixin:OnResearch(researchId)

    if researchId == kTechId.Digest then        
        self:TriggerEffects("recycle_start")        
        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end


function DigestMixin:OnResearchCancel(researchId)

    if researchId == kTechId.Digest then
        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end


function DigestMixin:OnUpdateRender() --key to electrifymixin ?

    PROFILE("DigestMixin:OnUpdateRender")

    if self.digested ~= self.clientRecycled then
    
        self.clientRecycled = self.digested
        self:SetOpacity(1, "recycleAmount")
        
        if self.digested then
            self.clientTimeRecycleStarted = Shared.GetTime()
        else
            self.clientTimeRecycleStarted = nil
        end
    
    end
    
    if self.clientTimeRecycleStarted then
    
        local recycleAmount = 1 - Clamp((Shared.GetTime() - self.clientTimeRecycleStarted) / kRecycleEffectDuration, 0, 1)
        self:SetOpacity(recycleAmount, "recycleAmount")
    
    end

end

function DigestMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("DigestMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("recycling", self:GetDigestActive())
    
end

local function SharedUpdate(self, deltaTime)

    if Server then
    
        if self.timeRecycled then
        
            if self.timeRecycled + kRecycleEffectDuration + 1 < Shared.GetTime() then
                DestroyEntity(self)
            end
        
        elseif self.researchingId == kTechId.Digest then
            self:UpdateResearch(deltaTime)
        end
        

    end
    
end

function DigestMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function DigestMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end