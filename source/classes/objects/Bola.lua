Bola = {}
class("Bola").extends(Obstacle)

function Bola:init()
    Bola.super.init(self, "assets/images/sprites/bola", 3, 1, 22, 23, 0, 0)
    self:setZIndex(10)
    
    -- Ball physics properties
    self.vx = 0
    self.vy = 0
    self.rotation = 0
    self.rotationSpeed = 0
    self.bounceStrength = 3 -- How strong bounces are
    
    -- Collision setup for ball-to-ball and ball-to-object interactions
    self:setGroups(7) -- Ball group
    self:setCollidesWithGroups({2, 4, 6, 7, 8}) -- Collide with enemies, bueiro, pastel, and other balls, curb (8)
    self.collisionResponse = NobleSprite.kCollisionTypeOverlap
end

function Bola:update()
    Bola.super.update(self)
    
    -- Handle collisions with bouncing physics
    local actualX, actualY, collisions, length = self:moveWithCollisions(self.x + self.vx, self.y + self.vy)
    
    if length > 0 then
        -- Handle bounces off other objects
        for _, collision in pairs(collisions) do
            local other = collision.other
            
            if other:isa(Bola) then
                -- Ball-to-ball collision: exchange momentum
                self:handleBallCollision(other)
            elseif other.vx and other.vy then
                -- Object has physics: apply bounce force to it
                self:bounceOffObject(other)
            else
                -- Static object: just bounce off
                self:bounceOffStatic(collision)
            end
        end
    else
        -- No collision, move normally
        self:moveTo(actualX, actualY)
    end

    -- Ensure downhill movement (positive X) after collisions
    if self.vx < 0 then
        self.vx = -self.vx
    end
    
    -- Apply rotation and friction (existing code)
    if self.vx ~= 0 or self.vy ~= 0 then
        local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        self.rotationSpeed = speed * 5
        self.rotation = self.rotation + self.rotationSpeed
        self:setRotation(self.rotation)
        
        -- Apply friction
        self.vx *= 0.98  -- Slightly less friction for more bouncing
        self.vy *= 0.98
        
        if math.abs(self.vx) < 0.1 then self.vx = 0 end
        if math.abs(self.vy) < 0.1 then self.vy = 0 end
    else
        self.rotationSpeed = 0
    end
end

-- Handle collision between two balls
function Bola:handleBallCollision(otherBall)
    -- Calculate collision vector
    local dx = otherBall.x - self.x
    local dy = otherBall.y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance == 0 then return end -- Avoid division by zero
    
    -- Normalize collision vector
    local nx = dx / distance
    local ny = dy / distance
    
    -- Exchange velocities (simplified elastic collision)
    local tempVx = self.vx
    local tempVy = self.vy
    
    self.vx = otherBall.vx * 0.8 -- Dampen the exchange
    self.vy = otherBall.vy * 0.8
    otherBall.vx = tempVx * 0.8
    otherBall.vy = tempVy * 0.8
    
    -- Separate the balls to prevent overlapping
    local separationForce = 2
    self.vx -= nx * separationForce
    self.vy -= ny * separationForce
    otherBall.vx += nx * separationForce
    otherBall.vy += ny * separationForce
end

-- Bounce off object that can move (like other enemies)
function Bola:bounceOffObject(object)
    -- Calculate bounce direction
    local dx = object.x - self.x
    local dy = object.y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance == 0 then return end
    
    local nx = dx / distance
    local ny = dy / distance
    
    -- Apply force to the object if it has physics
    if object.vx and object.vy then
        object.vx += nx * self.bounceStrength
        object.vy += ny * self.bounceStrength
    end
    
    -- Bounce self away
    self.vx -= nx * self.bounceStrength
    self.vy -= ny * self.bounceStrength
end

-- Bounce off static objects
function Bola:bounceOffStatic(collision)
    local normal = collision.normal
    if not normal then return end
    
    -- Reflect velocity based on collision normal
    local dotProduct = self.vx * normal.x + self.vy * normal.y
    self.vx -= 2 * dotProduct * normal.x * 0.7 -- Dampen bounce
    self.vy -= 2 * dotProduct * normal.y * 0.7
end