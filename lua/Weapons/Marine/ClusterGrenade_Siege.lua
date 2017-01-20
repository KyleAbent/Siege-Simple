if Server then

local orig = ClusterGrenade.Detonate

function ClusterGrenade:Detonate(targetHit)

   if not GetGameStarted() or self:GetOwner():GetDarwinMode() then
   local conc = CreateEntity(ConcGrenade.kMapName, self:GetOrigin(), 1)
   DestroyEntity(self)
   else
    return orig(self, targetHit)
   end

end

end