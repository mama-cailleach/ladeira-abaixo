Player = {}
class("Player").extends(NobleSprite)

function Player:init(width, height)
    -- Initialize NobleSprite with spritesheet path
    Player.super.init(self, "assets/images/sprites/skate-spritesheet-table-76-64", true) -- true = it's a spritesheet
    
    -- Set up size and collision rect
    self:setSize(width, height)
    self:setCollideRect(20, 20, 40, 30) -- Adjusted for better collision handling

    self.spriteWidth = width
    self.spriteHeight = height
    
    
    -- REQUIRED: Add animation state for Noble.Animation to work properly
    if self.animation then
        -- Add a single state that covers all 30 frames
        self.animation:addState("allFrames", 1, 30, nil, false) -- Don't loop, manual control
        self.animation:setState("allFrames")
    end
    
    -- Collision setup (same as PlayerRectangle)
    self.normalGroup = 1
    self:setGroups(self.normalGroup)
    self.collisionGroups = {1, 2, 3, 4, 6, 7, 8} -- Collides with player (1), enemies (2), oil (3), bueiro (4), pastel (6) bola (7)
    self:setCollidesWithGroups(self.collisionGroups) -- Collides with enemies (2) and oil (3) bueiro (4) pastel (6) bola (7)
    self.collisionResponse = NobleSprite.kCollisionTypeOverlap
    
    -- Player properties (same as PlayerRectangle)
    self.freezeFlag = false
    self.hitOil = false 
    self.hitBueiro = false
    self.hitPastel = false
    self.controlLocked = false
    self.hitBola = false
    self.hitEnemy = false -- guard to ensure crash sound/effect triggers only once per crash
    
    -- ANGLE-TO-FRAME MAPPING PROPERTIES
    self.angle = 0
    self.previousAngle = 0
    self.maxAngle = 60  -- Must match GAME_CONSTANTS.PLAYER_ANGLE_LIMIT
    self.totalFrames = 30  -- Total frames in your spritesheet
    self.centerFrame = 1   -- Frame 1 is center position
    
    self:setZIndex(15)
    self:setCenter(0.5, 0.5)  -- Center the sprite on its position
    self.scale = 1
    self:setRotation(0)  -- Ensure no rotation
    
    -- Set initial frame to center by directly setting currentFrame
    if self.animation then
        self.animation.currentFrame = self.centerFrame
    end

    -- Keep reference to the default animation imagetable
    if self.animation and self.animation.imageTable then
        self.defaultImageTable = self.animation.imageTable
    else
        self.defaultImageTable = nil
    end

    -- Try to load a larger jump imagetable for the bueiro effect; tolerate missing asset
    local ok, jt = pcall(function()
        return Graphics.imagetable.new("assets/images/sprites/skate-jumping-spritesheet-table-88-74")
    end)
    if ok and jt then
        self.jumpImageTable = jt
    else
        self.jumpImageTable = nil
    end
end

-- Swap the player's image table to the jump imagetable (if available)
function Player:enterJumpSheet()
    if not self.jumpImageTable or not self.animation then return end
    self.isJumping = true
    local frame = self.animation.currentFrame or 1
    -- switch imagetable used by animation
    self.animation.imageTable = self.jumpImageTable
    -- set the corresponding frame image
    if self.jumpImageTable[frame] then
        self:setImage(self.jumpImageTable[frame])
    end
    -- Try to adjust sprite size to match jump frame
    if self.jumpImageTable[frame] and self.setSize and self.jumpImageTable[frame].getSize then
        local ok, w, h = pcall(function() return self.jumpImageTable[frame]:getSize() end)
        if ok and w and h then
            self:setSize(w, h)
        end
    end
    -- lock input (MovementManager checks controlLocked)
    self.controlLocked = true
end

-- Restore the player's default image table and re-enable input
function Player:exitJumpSheet()
    if not self.defaultImageTable or not self.animation then return end
    self.isJumping = false
    local frame = self.animation.currentFrame or 1
    self.animation.imageTable = self.defaultImageTable
    if self.defaultImageTable[frame] then
        self:setImage(self.defaultImageTable[frame])
    end
    -- restore original sprite size
    if self.setSize and self.spriteWidth and self.spriteHeight then
        self:setSize(self.spriteWidth, self.spriteHeight)
    end
    self.controlLocked = false
end


function Player:angleToFrameSequential(angle, previousAngle)
    local clampedAngle = math.max(-self.maxAngle, math.min(self.maxAngle, angle))
    local currentFrame = self.animation and self.animation.currentFrame or 1
    local centerCushion = 12
    
    -- Handle transition frames explicitly
    if currentFrame == 14 and math.abs(clampedAngle) <= centerCushion then
        return 15  -- Force transition through frame 15
    elseif currentFrame == 15 and math.abs(clampedAngle) <= centerCushion then
        return 1   -- Now go to center
    elseif currentFrame == 29 and math.abs(clampedAngle) <= centerCushion then
        return 30  -- Force transition through frame 30
    elseif currentFrame == 30 and math.abs(clampedAngle) <= centerCushion then
        return 1   -- Now go to center
    end

    if math.abs(clampedAngle) <= centerCushion then
        return 1
    end

    if clampedAngle > centerCushion then
        -- Left territory
        if self.movingLeft then
            -- Active left turn: 16-23
            local adjustedAngle = clampedAngle - centerCushion
            local maxAngle = self.maxAngle - centerCushion
            local progress = adjustedAngle / maxAngle
            local frame = math.floor(progress * 7) + 16
            return math.min(23, frame)
        else
            -- Returning from left: Only use 24-30 if coming from frame 23
            local currentFrame = self.animation and self.animation.currentFrame or 1
            if currentFrame >= 23 then
                -- Use transition frames 24-30 based on how far we've returned
                local adjustedAngle = clampedAngle - centerCushion
                local maxAngle = self.maxAngle - centerCushion
                local progress = 1 - (adjustedAngle / maxAngle)  -- Inverted for return
                local frame = math.floor(progress * 6) + 24
                return math.min(30, frame)
            else
                -- Use regular left frames if not at max left yet
                local adjustedAngle = clampedAngle - centerCushion
                local maxAngle = self.maxAngle - centerCushion
                local progress = adjustedAngle / maxAngle
                local frame = math.floor(progress * 7) + 16
                return math.min(23, frame)
            end
        end
        
    else -- clampedAngle < -centerCushion
        -- Right territory
        if self.movingRight then
            -- Active right turn: 2-7
            local adjustedAngle = (-clampedAngle) - centerCushion
            local maxAngle = self.maxAngle - centerCushion
            local progress = adjustedAngle / maxAngle
            local frame = math.floor(progress * 5) + 2
            return math.min(7, frame)
        else
            -- Returning from right: Only use 8-15 if coming from frame 7
            local currentFrame = self.animation and self.animation.currentFrame or 1
            if currentFrame >= 7 then
                -- Use transition frames 8-15 based on how far we've returned
                local adjustedAngle = (-clampedAngle) - centerCushion
                local maxAngle = self.maxAngle - centerCushion
                local progress = 1 - (adjustedAngle / maxAngle)  -- Inverted for return
                local frame = math.floor(progress * 7) + 8
                return math.min(15, frame)
            else
                -- Use regular right frames if not at max right yet
                local adjustedAngle = (-clampedAngle) - centerCushion
                local maxAngle = self.maxAngle - centerCushion
                local progress = adjustedAngle / maxAngle
                local frame = math.floor(progress * 5) + 2
                return math.min(7, frame)
            end
        end
    end
end

-- SIMPLIFIED: Single spritesheet approach
function Player:setAngle(angle)
    self.previousAngle = self.angle  -- Store previous angle
    self.angle = angle
    
    if self.animation then
        local frame = self:angleToFrameSequential(angle, self.previousAngle)
        self.animation.currentFrame = frame
        
        -- Force update the displayed image
        if self.animation.imageTable and self.animation.imageTable[frame] then
            self:setImage(self.animation.imageTable[frame])
        end
    end
end



function Player:startBlink(duration, interval)
    if self.blinkTimer then 
        return 
    end -- already blinking
    self.blinkTimer = playdate.timer.keyRepeatTimerWithDelay(0, interval or 100, function()
        self:setVisible(not self:isVisible())
    end)
    playdate.timer.performAfterDelay(duration or 1000, function()
        self:stopBlink()
    end)
end

function Player:stopBlink()
    if self.blinkTimer then
        self.blinkTimer:remove()
        self.blinkTimer = nil
    end
    self:setVisible(true)
end

-- UPDATED: Remove turn animation calls
function Player:update()
    Player.super.update(self)
    
    -- Only handle collisions - frame is controlled by setAngle()
    local actualX, actualY, collisions, length = self:moveWithCollisions(self.x, self.y)
    if length > 0 then
        for _, collision in pairs(collisions) do
            local other = collision['other']
            if other:isa(Enemy) then
                -- Ensure crash handling only triggers once per collision event
                if not self.hitEnemy then
                    -- Record which crash sound should be played by the scene
                    if other:isa(Motoboy) then
                        self.crashSoundName = "crash4"
                    elseif other:isa(Pipoqueiro) then
                        self.crashSoundName = "crash5"
                    elseif other:isa(Uninho) then
                        self.crashSoundName = "crash6"
                    else
                        self.crashSoundName = "crash4"
                    end
                    self.hitEnemy = true
                end

                -- Signal the scene to handle the freeze/crash flow
                self.freezeFlag = true
                if Noble.currentScene() and Noble.currentScene().stopSpawning then
                    Noble.currentScene():stopSpawning()
                end
                return
            elseif other:isa(Oil) then
                self.hitOil = true
                self.controlLocked = true
            elseif other:isa(Bueiro) then
                self.hitBueiro = true
            elseif other:isa(Pastel) then
                self.hitPastel = true

                 -- remove pastel when collide
                if other.remove then other:remove() end

                -- remove from current scene's objects list (safeguard)
                local scene = Noble.currentScene()
                if scene and scene.objects then
                    for i = #scene.objects, 1, -1 do
                        if scene.objects[i] == other then
                            table.remove(scene.objects, i)
                            break
                        end
                    end
                end

            elseif other:isa(Bola) then
                self.hitBola = true
                -- Calculate direction from player to bola
                local dx = other.x - self.x
                local dy = other.y - self.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist == 0 then dist = 1 end -- avoid division by zero
                -- Set bola velocity away from player
                local bounceStrength = 7 -- tweak as needed
                other.vx = (dx / dist) * bounceStrength
                other.vy = (dy / dist) * bounceStrength

            elseif other:isa(CurbL) or other:isa(CurbR) then
                Sound.playSound("curb_skate", 0.8)
            end
        end
    end
end

