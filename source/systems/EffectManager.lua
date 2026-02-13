import "utilities/GameConstants"
import "systems/SpeedManager"

EffectManager = {}

-- Initialize EffectManager
function EffectManager.init(gameScene)
    EffectManager.gameScene = gameScene
    EffectManager.activeEffects = {}
end

-- Notify SpeedManager when effects change
local function updateSpeedManagerEffects()
    SpeedManager.setActiveEffects(EffectManager.activeEffects)
    
    -- Update all object speeds immediately
    if EffectManager.gameScene and EffectManager.gameScene.updateAllObjectSpeeds then
        EffectManager.gameScene:updateAllObjectSpeeds()
    end
end

-- Handle oil effect (speed boost and control lock)
function EffectManager.handleOilEffect()
    local gameScene = EffectManager.gameScene
    if not gameScene.playerRect.hitOil then return end

    -- PREVENT RE-TRIGGERING: Only trigger if not already active
    if EffectManager.activeEffects.oil then return end

    gameScene.playerRect.controlLocked = true
    
    -- Add oil effect
    -- Play oil sound once when the effect is actually applied
    if Sound and Sound.playSound then
        Sound.playSound("oil", 0.5)
       Sound.temporarilyDuckAmbient(0.8, 600)
    end

    EffectManager.addSpeedEffect("oil", GameConstants.MOVEMENT.FAST_SPEED, GameConstants.EFFECTS.OIL_DURATION, function()
        -- SAFE GUARD: Check if playerRect still exists
        if gameScene.playerRect then
            gameScene.playerRect.controlLocked = false
            gameScene.playerRect.hitOil = false
        end
    end)
end

-- Handle bola effect (slow down)
function EffectManager.handleBolaEffect()
    local gameScene = EffectManager.gameScene
    if not gameScene.playerRect.hitBola then return end

    -- PREVENT RE-TRIGGERING: Only trigger if not already active
    if EffectManager.activeEffects.bola then return end
    
    if Sound and Sound.playSound then
        Sound.playSound("ball_bouncey")
        Sound.temporarilyDuckAmbient(0.7, 1000)
    end
    
    -- Add bola effect
    EffectManager.addSpeedEffect("bola", GameConstants.MOVEMENT.SLOW_SPEED, GameConstants.EFFECTS.BOLA_DURATION, function()
        -- SAFE GUARD: Check if playerRect still exists before accessing
        if gameScene.playerRect then
            gameScene.playerRect.hitBola = false
        end
    end)
end

-- Handle bueiro effect (jump)
function EffectManager.handleBueiroEffect()
    local gameScene = EffectManager.gameScene
    if not gameScene.playerRect.hitBueiro then return end

    -- PREVENT RE-TRIGGERING: Only trigger if not already active
    if EffectManager.activeEffects.bueiro then return end

    if Sound and Sound.playSound then
        Sound.playSound("bueiro")
        Sound.temporarilyDuckAmbient(0.1, (GameConstants.EFFECTS.BUEIRO_DURATION))
    end


    -- Enter jump sheet (switch to larger spritesheet frame) and lock input
    if gameScene.playerRect and gameScene.playerRect.enterJumpSheet then
        gameScene.playerRect:enterJumpSheet()
    else
        -- If no jump sheet available, still lock controls
        if gameScene.playerRect then gameScene.playerRect.controlLocked = true end
    end
    gameScene.playerRect:setGroups(32)
    gameScene.playerRect:setCollisionsEnabled(false)
    gameScene.playerRect:setZIndex(20)
    
    -- Add bueiro effect
    EffectManager.addSpeedEffect("bueiro", GameConstants.MOVEMENT.FAST_SPEED, GameConstants.EFFECTS.BUEIRO_DURATION, function()
        -- SAFE GUARD: Check if playerRect still exists
        if gameScene.playerRect then
            -- Exit jump sheet (restore default spritesheet) and unlock input
            if gameScene.playerRect.exitJumpSheet then
                gameScene.playerRect:exitJumpSheet()
            else
                gameScene.playerRect.controlLocked = false
            end
            gameScene.playerRect:setGroups(gameScene.playerRect.normalGroup)
            gameScene.playerRect:setCollisionsEnabled(true)
            gameScene.playerRect:setZIndex(15)
            gameScene.playerRect.hitBueiro = false
        end
    end)
end

-- Handle pastel effect (boost)
function EffectManager.handlePastelEffect()
    local gameScene = EffectManager.gameScene
    if not gameScene.playerRect.hitPastel then return end

    -- PREVENT RE-TRIGGERING: Only trigger if not already active
    if EffectManager.activeEffects.pastel then return end

    if Sound and Sound.playSound then
        Sound.playSound("pastel")
        --Sound.temporarilyDuckAmbient(0.6, GameConstants.EFFECTS.PASTEL_DURATION)
    end

    gameScene.playerRect:setGroups(32)
    gameScene.playerRect:setCollisionsEnabled(false)
    gameScene.playerRect:setZIndex(20)
    gameScene.playerRect:startBlink(1000, 100)
    
    -- Add pastel effect
    EffectManager.addSpeedEffect("pastel", GameConstants.MOVEMENT.FAST_SPEED, GameConstants.EFFECTS.PASTEL_DURATION, function()
        -- SAFE GUARD: Check if playerRect still exists
        if gameScene.playerRect then
            gameScene.playerRect:setGroups(gameScene.playerRect.normalGroup)
            gameScene.playerRect:setCollisionsEnabled(true)
            gameScene.playerRect:setZIndex(15)
            gameScene.playerRect:stopBlink()
            gameScene.playerRect.hitPastel = false
        end
    end)
end

-- Handle all effects in sequence
function EffectManager.handleEffects()
    EffectManager.handleOilEffect()
    EffectManager.handleBolaEffect()
    EffectManager.handleBueiroEffect()
    EffectManager.handlePastelEffect()
end

-- Speed effect management methods
function EffectManager.addSpeedEffect(name, targetSpeed, duration, onComplete)
    -- Remove existing effect of same type
    EffectManager.removeSpeedEffect(name)
    
    -- Add new effect
    local effect = {
        name = name,
        targetSpeed = targetSpeed,
        timer = playdate.timer.performAfterDelay(duration, function()
            EffectManager.removeSpeedEffect(name)
            if onComplete then onComplete() end
        end)
    }
    
    EffectManager.activeEffects[name] = effect
    
    -- Notify SpeedManager of effect changes
    updateSpeedManagerEffects()
end

function EffectManager.removeSpeedEffect(name)
    local effect = EffectManager.activeEffects[name]
    if effect then
        if effect.timer then
            effect.timer:remove()
        end
        EffectManager.activeEffects[name] = nil
        
        -- Notify SpeedManager of effect changes
        updateSpeedManagerEffects()
    end
end


return EffectManager
