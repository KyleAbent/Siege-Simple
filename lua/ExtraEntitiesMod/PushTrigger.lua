--thanks eem
class 'PushTrigger' (Trigger)

PushTrigger.kMapName = "push_trigger"

local networkVars =
{
}

function PushTrigger:Reset()

end    

local function PushEntity(self, entity)
    for i = 1, 8 do
 --Print("PushEntity 1")
   end
    if entity:isa("Player") and not entity:isa("Commander") then
    
        for i = 1, 8 do
 --Print("PushEntity 2")
   end
        local force = self.pushForce
        if self.pushDirection then      
                for i = 1, 8 do
 --Print("PushEntity 3")
   end
            // get him in the air a bit
            if entity.GetIsOnGround and entity:GetIsOnGround() then
                local extents = GetExtents(entity:GetTechId())            
                if GetHasRoomForCapsule(extents, entity:GetOrigin() + Vector(0, extents.y + 0.2, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, entity)) then                
                    entity:SetOrigin(entity:GetOrigin() + Vector(0,0.2,0)) 
                end
                
                entity.timeOfLastJump = Shared.GetTime()
                entity.onGroundNeedsUpdate = true
                entity.jumping = true  
               
            end 
            
            entity.pushTime = Shared.GetTime()
            
            velocity = self.pushDirection * force 
            entity:SetVelocity(velocity)

        end 
    end
    
end

local function PushAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        PushEntity(self, entity)
    end
    
end

function PushTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
        for i = 1, 8 do
 --Print("PushEntity 4")
   end
end

function PushTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then 
        self.pushDirection = self:AnglesToVector()
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
            for i = 1, 8 do
 --Print("PushEntity 5")
   end
end

--if Server then


function PushTrigger:OnTriggerEntered(enterEnt, triggerEnt)

         PushEntity(self, enterEnt)
            for i = 1, 8 do
 --Print("PushEntity 6")
   end
end


//Addtimedcallback had not worked, so lets search it this way
function PushTrigger:OnUpdate(deltaTime)

        PushAllInTrigger(self)
            for i = 1, 8 do
 --Print("PushEntity 7")
   end
end


function PushTrigger:AnglesToVector()
    // y -1.57 in game is up in the air
    local angles =  self:GetAngles()
    local origin = self:GetOrigin()
    local directionVector = Vector(0,0,0)
    if angles then
        // get the direction Vector the pushTrigger should push you                
        
        // pitch to vector
        directionVector.z = math.cos(angles.pitch)
        directionVector.y = -math.sin(angles.pitch)
        
        // yaw to vector
        if angles.yaw ~= 0 then
            directionVector.x = directionVector.z * math.sin(angles.yaw)                   
            directionVector.z = directionVector.z * math.cos(angles.yaw)                                
        end  
    end
    return directionVector
end


Shared.LinkClassToMap("PushTrigger", PushTrigger.kMapName, networkVars)