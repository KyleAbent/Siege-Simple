//derp

local kDualWelderModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
local kDualWelderAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")


if Server then 
    function ExoWeaponHolder:SetWelderWeapons()
    
        
        if self.leftWeaponId ~= Entity.invalidId then
            DestroyEntity(Shared.GetEntity(self.leftWeaponId))
        end
        local leftWeapon = CreateEntity(ExoWelder.kMapName, Vector(), self:GetTeamNumber())
        leftWeapon:SetParent(self:GetParent())
        leftWeapon:SetExoWeaponSlot(ExoWeaponHolder.kSlotNames.Left)
        self.leftWeaponId = leftWeapon:GetId()
        
        if self.rightWeaponId ~= Entity.invalidId then
            DestroyEntity(Shared.GetEntity(self.rightWeaponId))
        end
        local rightWeapon = CreateEntity(ExoWelder.kMapName, Vector(), self:GetTeamNumber())
        rightWeapon:SetParent(self:GetParent())
        rightWeapon:SetExoWeaponSlot(ExoWeaponHolder.kSlotNames.Right)
        self.rightWeaponId = rightWeapon:GetId()
        
        self.weaponSetupName = Railgun.kMapName .. "+" .. Railgun.kMapName
        
        if self:GetIsActive() then
            local player = self:GetParent()
            player:SetViewModel(self:GetViewModelName(), self)
        end
        
    end
 end