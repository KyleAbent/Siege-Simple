local rifleReloadTime = Shared.GetAnimationLength("models/marine/male/male.model", "rifle_reload")
local hmgReloadTime = Shared.GetAnimationLength("models/marine/lmg/lmg_view.model", "reload")

kRifleToHMGReloadSpeed = (rifleReloadTime / hmgReloadTime) * 0.7

function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("reload_speed", kRifleToHMGReloadSpeed)

end