import "utilities/GameConstants"
import "systems/SpeedManager"

MovementManager = {}

-- Initialize MovementManager
function MovementManager.init(gameScene)
    MovementManager.gameScene = gameScene
end

-- Update player position based on angle and constant forward speed
function MovementManager.updatePlayerPosition(playerRect, playerAngle)
    -- Get constant forward speed from SpeedManager (no turn penalty)
    local forwardSpeed = SpeedManager.getPlayerSpeed()
    
    -- Apply lateral movement based on turning angle
    local lateralMovement = playerAngle * GameConstants.MOVEMENT.LATERAL_MOVEMENT_FACTOR
    
    -- Apply slight downward drift (skateboard rolling down)
    local newY = playerRect.y + lateralMovement + (forwardSpeed * GameConstants.MOVEMENT.DOWNWARD_DRIFT_FACTOR)
    
    -- Clamp to vertical bounds
    newY = math.max(GameConstants.MOVEMENT.PLAYER_Y_MIN, math.min(newY, GameConstants.MOVEMENT.PLAYER_Y_MAX))
    
    playerRect:moveTo(playerRect.x, newY)
end

-- Handle player input and angle updates
function MovementManager.handlePlayerInput(playerRect, currentAngle, controlLocked)
    if controlLocked then return currentAngle end
    
    -- Detect crank movement for animation
    local crankChange = playdate.getCrankChange()
    local newAngle = currentAngle
    
    if math.abs(crankChange) > 0.5 then  -- Threshold to avoid noise
        if crankChange > 0 then
            -- Clockwise movement - animate toward negative angle (inverted)
            newAngle = math.max(currentAngle - math.abs(crankChange), -GameConstants.MOVEMENT.PLAYER_ANGLE_LIMIT)
        else
            -- Counterclockwise movement - animate toward positive angle (inverted)
            newAngle = math.min(currentAngle - crankChange, GameConstants.MOVEMENT.PLAYER_ANGLE_LIMIT)
        end
    end
    
    -- Set player rotation (for animation)
    playerRect:setAngle(newAngle)
    
    return newAngle
end

-- Update all object speeds to match current SpeedManager speed
function MovementManager.updateAllObjectSpeeds()
    local gameScene = MovementManager.gameScene
    if not gameScene then return end
    
    local objectSpeed = SpeedManager.getObjectSpeed()
    
    -- Apply to all moving objects
    for _, obj in ipairs(gameScene.objects) do
        if obj.baseSpeed then  -- Only objects with baseSpeed are moving
            obj.moveSpeed = objectSpeed
            
            -- Also update duplicate sprites (for curbs)
            if obj.duplicateSprite and obj.duplicateSprite.baseSpeed then
                obj.duplicateSprite.moveSpeed = objectSpeed
            end
        end
    end
end

-- Apply current speed to newly spawned object
function MovementManager.applySpeedToObject(obj)
    if not obj.baseSpeed then return end
    obj.moveSpeed = SpeedManager.getObjectSpeed()
end

-- Stop all object movement (for freeze frame)
function MovementManager.stopAllMovement()
    local gameScene = MovementManager.gameScene
    if not gameScene then return end
    
    -- Stop ALL objects including curbs
    for _, obj in ipairs(gameScene.objects) do
        obj.moveSpeed = 0
        if obj.duplicateSprite then
            obj.duplicateSprite.moveSpeed = 0
        end
    end
end

return MovementManager
