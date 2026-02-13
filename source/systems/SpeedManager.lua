-- SpeedManager.lua
-- Centralized speed state and access for all systems
-- Single source of truth for world speed - no turn penalties, only power-up effects

import "utilities/GameConstants"

SpeedManager = {}

-- Internal state
local currentPlayerSpeed = GameConstants.MOVEMENT.PLAYER_BASE_SPEED
local currentObjectSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
local activeEffects = {}

-- reference to scene (set in init)
SpeedManager.gameScene = nil

-- Initialize SpeedManager
function SpeedManager.init(gameScene)
    currentPlayerSpeed = GameConstants.MOVEMENT.PLAYER_BASE_SPEED
    currentObjectSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    activeEffects = {}
    SpeedManager.gameScene = gameScene or nil
end

-- compute integer delta based on player score and GameConstants.SPEED
local function computeSpeedDelta()
    if not GameConstants.SPEED then return 0 end
    local step = GameConstants.SPEED.UNLOCK_STEP
    local inc = GameConstants.SPEED.INCREMENT
    local maxInc = GameConstants.SPEED.MAX_INCREMENT

    local score = 0
    if SpeedManager.gameScene and SpeedManager.gameScene.playerScore then
        score = SpeedManager.gameScene.playerScore
    end

    local tiers = math.floor(score / math.max(1, step)) * inc
    if tiers > maxInc then tiers = maxInc end
    if tiers < 0 then tiers = 0 end
    return tiers
end

-- Set active effects and recalculate speeds
function SpeedManager.setActiveEffects(effects)
    activeEffects = effects or {}
    SpeedManager.updateSpeeds()
end

-- Update speeds based on active power-up effects only (no turn penalties)
function SpeedManager.updateSpeeds()
    local delta = computeSpeedDelta()
    -- compute adjusted bases (integer additive)
    local basePlayer = (GameConstants.MOVEMENT.PLAYER_BASE_SPEED) + delta
    local baseNormal = (GameConstants.MOVEMENT.NORMAL_SPEED) + delta
    local baseSlow = math.max(1, math.floor(baseNormal * GameConstants.MOVEMENT.SLOW_SPEED_RATIO))
    local baseFast = math.max(baseNormal, math.floor(baseNormal * GameConstants.MOVEMENT.FAST_SPEED_RATIO))



    -- Determine base speed from active effects
    -- Priority: bola (slowest) -> normal -> oil/pastel/bueiro (fastest)
    if activeEffects.bola then
        currentObjectSpeed = baseSlow
        currentPlayerSpeed = baseSlow
    elseif activeEffects.oil or activeEffects.pastel or activeEffects.bueiro then
        currentObjectSpeed = baseFast
        currentPlayerSpeed = baseFast
    else
        currentObjectSpeed = baseNormal
        currentPlayerSpeed = basePlayer
    end
end

-- Get current player forward speed
function SpeedManager.getPlayerSpeed()
    return currentPlayerSpeed
end

-- Get current object speed (for all moving objects including curbs)
function SpeedManager.getObjectSpeed()
    return currentObjectSpeed
end

-- Get active effects table
function SpeedManager.getActiveEffects()
    return activeEffects
end

return SpeedManager
