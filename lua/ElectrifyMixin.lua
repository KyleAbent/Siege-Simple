ElectrifyMixin = CreateMixin( ElectrifyMixin )
ElectrifyMixin.type = "Electrifyable"

PrecacheAsset("cinematics/vfx_materials/pulse_gre_elec.material")

local kElectrifyMaterial = PrecacheAsset("cinematics/vfx_materials/pulse_gre_elec.material")

ElectrifyMixin.networkVars =
{
    commElectrified = "boolean"
}

function ElectrifyMixin:__initmixin()
      if Server then
        self.commElectrified = false   
      end 
end

local function ClearCommElectrify(self, destroySound)

    self.commElectrified = false  
    
    if Client then
        self:_RemoveEffect()
    end
    
   -- if Server and self.shieldLoopSound and destroySound then
    --    DestroyEntity(self.shieldLoopSound)
    --end
    
  --  self.shieldLoopSound = nil
    
end

function ElectrifyMixin:OnDestroy()

    if self:GetIsElectrified() then
        ClearCommElectrify(self, false)
    end
    
end


function ElectrifyMixin:ElectrifyStructure()
        self.commElectrified = true
end

function ElectrifyMixin:GetIsElectrified()
  local boolean = self:GetIsPowered() and self.commElectrified
    --Print("GetIsElectrified is %s",boolean )
    return boolean
end


local function UpdateElectrifiedEffects(self)

    assert(Client)
    
    if self:GetIsElectrified() and self:GetIsAlive() then
        self:_CreateEffect()
    else
        self:_RemoveEffect() 
    end
    
end

local function SharedUpdate(self)
    if Server then
    
        if not self:GetIsElectrified() then
            return
        end
        
    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateElectrifiedEffects(self)
    end
    
end


function ElectrifyMixin:OnProcessMove(input)   
    SharedUpdate(self)
end
function ElectrifyMixin:OnUpdate(deltaTime)
     if Server then
     
     
      if not self.LastDamage or Shared.GetTime() > self.LastDamage + 4 and self:GetIsElectrified() then  
                      for _, entity in ipairs(GetEntitiesForTeamWithinRange("Player", 2, self:GetOrigin(), 3)) do
                           if entity:GetIsAlive() and not entity:isa("Commander") then 
                             local damage = math.random(5, 15)
                             entity:TakeDamage(damage, nil, nil, nil, nil, damage /2, damage, kDamageType.Normal)
                           end
                      end        
                self.LastDamage = Shared.GetTime()
         end
    
   end

end
--Great for some reason the onupdate deleted where it had the damage rules
if Client then

    local function AddEffect(entity, material)
    
        
            local model = entity._renderModel
            if model ~= nil then
                    model:AddMaterial(material)
            end
        
    
    end
    
    local function RemoveEffect(entity, material)
    
                local model = entity._renderModel
                if model ~= nil then
                        model:RemoveMaterial(material)
                end                    
        
    end

    function ElectrifyMixin:_CreateEffect()
   
        if not self.electrifyMaterial then
        
            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kElectrifyMaterial)
            self.electrifyMaterial = material
            AddEffect(self, material)
            
        end    
        
    end

    function ElectrifyMixin:_RemoveEffect()

        if self.nanoShieldMaterial then
            RemoveEffect(self, self.nanoShieldMaterial)
            Client.DestroyRenderMaterial(self.electrifyMaterial)
            Client.DestroyRenderMaterial(self.nanoShieldViewMaterial)
            self.electrifyMaterial = nil
        end            

    end
    
end