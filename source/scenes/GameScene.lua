GameScene = {}

class("GameScene").extends(NobleScene)
local game = GameScene

import "utilities/GameConstants"
import "classes/Classes"
import "systems/SpawnManager"
import "systems/EffectManager"
import "systems/MovementManager"
import "systems/SpeedManager"

function game:init()
    game.super.init(self)
    
    -- Initialize systems
    SpawnManager.init(self)
    EffectManager.init(self)
    MovementManager.init(self)
    SpeedManager.init(self)
    
    -- Core game state
    self.objects = {}
    self.playerScore = 0
    self.playerAngle = 0
    self.gameStarted = false

    -- distance accumulator for pixel -> meter conversion
    self.distanceAccumulator = 0 -- pixels accumulated since last meter
    
    -- Countdown setup
    self.countdownActive = false
    self.countdownValue = 3
    self.countdownTimer = 0
    self.countdownStrings = {"*3*", "*2*", "*1*", "*GO!*"}
    
    -- Freeze frame for endgame
    self.freezeFrame = false
    self.freezeTimer = nil

    -- Create death sprite with 2-frame animation
    self.deathSprite = NobleSprite("assets/images/sprites/ded-table-90-59", true)
    
    if self.deathSprite.animation then
        -- Frame 1: flying (will move 100px on x-axis)
        self.deathSprite.animation:addState("flying", 1, 1, nil, false)
        -- Frame 2: falling
        self.deathSprite.animation:addState("falling", 2, 2, nil, false)
        
        -- Start with flying frame
        self.deathSprite.animation:setState("flying")
    end
    
    -- Set sprite bounds for proper rendering (90x59 based on filename)
    self.deathSprite:setSize(90, 59)
    self.deathSprite:setCenter(0.5, 0.5)  -- Center anchor
    self.deathSprite:setZIndex(21)

    --[[ Invincibility debug 
    self.inputHandler = {
        downButtonDown = function()
            -- debug invincibility
            self.playerRect:setCollisionsEnabled(false)
            print("Player invincibility ON")
        end,
        rightButtonDown = function()
            -- debug invincibility off
            self.playerRect:setCollisionsEnabled(true)
            print("Player invincibility OFF")
        end 
        } ]]


end

function game:enter()
    game.super.enter(self)
    
    -- Create player
    self.playerRect = Player(76, 64)
    self.playerRect:add(60, 120)
    
    -- Create curbs
    self.curbL = CurbL()
    self.curbL:add(0, 231)
    self.curbL.type = "curbL"
    self.curbL.baseSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    self.curbL.moveSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    table.insert(self.objects, self.curbL)
    
    self.curbR = CurbR()
    self.curbR:add(0, 10)
    self.curbR.type = "curbR"
    self.curbR.baseSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    self.curbR.moveSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    table.insert(self.objects, self.curbR)

    -- Spawn Partida once at the start
    local partida = Partida()
    partida:add(100, 120) 
    partida.type = "partida"
    table.insert(self.objects, partida)

    self.score_ui = NobleSprite("assets/images/sprites/ui/score-ui", false)
    self.score_ui:setZIndex(26)
    self.score_ui:setVisible(false)  -- Hidden during countdown
    self.score_ui:add(386, 120)
    
    
    -- Reset score
    Noble.GameData.set("Score", 0)
end

function game:start()
    game.super.start(self)
    
    self.countdownActive = true
    self.countdownValue = 0
    self.countdownTimer = 0
    Sound.stopMusic()
end

function game:update()
    game.super.update(self)

    -- Handle freeze frame
    if self.playerRect.freezeFlag then
        self:triggerFreezeFrame()
        self.playerRect.freezeFlag = false
        return
    end
    if self.freezeFrame then
        return
    end

    -- Handle countdown
    if self.countdownActive then
        Utilities.crankView()
        self.countdownTimer += 1
        if self.countdownTimer > GameConstants.GAME.COUNTDOWN_FPS then
            self.countdownTimer = 0
            self.countdownValue += 1
            self:updateCountdownSprite()
            if self.countdownValue < #self.countdownStrings then
                Sound.playSound("beep1", 0.4)
            elseif self.countdownValue == #self.countdownStrings then
                Sound.playSound("beep2", 0.5)
            end
            
            if self.countdownValue > #self.countdownStrings then
                self.countdownActive = false
                self.gameStarted = true
                Sound.playRandomMusic()
                if self.countdownSprite then
                    self.countdownSprite:remove()
                    self.countdownSprite = nil
                end
                
                -- Show score UI now that game has started
                if self.score_ui then
                    self.score_ui:setVisible(true)
                end

                -- Start ambient skate loop (plays independently of music)
                if Sound and Sound.playAmbient then
                    Sound.playAmbient("skate_bg1")
                end

                -- Start game systems
                SpawnManager.startSpawner()
                for _, obj in ipairs(self.objects) do
                    if obj.type == "partida" or obj.type == "curbL" or obj.type == "curbR" then
                        obj.active = true
                    end
                end
            end
        end
        return
    end

    if not self.gameStarted then
        return
    end

    -- Handle effects and update speeds
    EffectManager.handleEffects()
    SpeedManager.setActiveEffects(EffectManager.activeEffects)
    MovementManager.updateAllObjectSpeeds()
    
    -- Handle player input
    self.playerAngle = MovementManager.handlePlayerInput(self.playerRect, self.playerAngle, self.playerRect.controlLocked)
    
    -- Update player position
    MovementManager.updatePlayerPosition(self.playerRect, self.playerAngle)
    
    -- Update spawning
    SpawnManager.updateSpawning()

    -- update music if needed
    if not Sound.isAnyMusicPlaying() and not self.freezeFrame and Noble.Settings.get("musicEnabled") then
        Sound.playNextMusic()
    end
    
    
    -- Update score (meters) based on pixels traveled this frame
    local pixelsThisFrame = SpeedManager.getObjectSpeed() or 0
    self.distanceAccumulator = (self.distanceAccumulator or 0) + pixelsThisFrame
    local pixelsPerMeter = GameConstants.MOVEMENT.PIXELS_PER_METER
    if self.distanceAccumulator >= pixelsPerMeter then
        local meters = math.floor(self.distanceAccumulator / pixelsPerMeter)
        self.playerScore = (self.playerScore or 0) + meters
        self.distanceAccumulator = self.distanceAccumulator - meters * pixelsPerMeter
    end

    self:updateMetersSprite() -- score UI
    -- self:updateSpeedSprite() -- speed debug DELETE


end

function game:updateCountdownSprite()
    if self.countdownSprite then
        self.countdownSprite:remove()
        self.countdownSprite = nil
    end
    local text = self.countdownStrings[self.countdownValue] or ""
    if text and text ~= "" then
        local countdownSpriteText = NobleSprite.spriteWithText(text, 100, 40, playdate.graphics.kColorClear, nil, nil, kTextAlignment.center, FONT_PIXO)
        countdownSpriteText:moveTo(200, 120)
        countdownSpriteText:add()
        countdownSpriteText:setRotation(270)
        self.countdownSprite = countdownSpriteText
    end

end

-- test for meter counter
function game:updateMetersSprite()
    if self.metersSpriteText then
        self.metersSpriteText:remove()
        self.metersSpriteText = nil
    end
    local text = tostring(self.playerScore or 0)
    if text and text ~= "" then
        self.metersSpriteText = NobleSprite.spriteWithText(text, 100, 40, playdate.graphics.kColorClear, nil, nil, kTextAlignment.center, FONT_PIXO_SMOL)
        self.metersSpriteText:moveTo(382, 120)
        self.metersSpriteText:setRotation(270)
        self.metersSpriteText:setImageDrawMode(playdate.graphics.kDrawModeNXOR)
        self.metersSpriteText:setZIndex(27)
        self.metersSpriteText:add()
    end
end

-- debug for player speed on screen
function game:updateSpeedSprite()
    if self.speedSprite then
        self.speedSprite:remove()
        self.speedSprite = nil
    end
    local text = tostring("Vel " .. math.tointeger(SpeedManager.getPlayerSpeed()))
    if text and text ~= "" then
        local metersSpriteText = NobleSprite.spriteWithText(text, 100, 40, playdate.graphics.kColorClear, nil, nil, kTextAlignment.center, FONT_PIXO_SMOL)
        metersSpriteText:moveTo(380, 50)
        metersSpriteText:setRotation(270)
        self.speedSprite = metersSpriteText
        metersSpriteText:add()
    end
end

function game:drawBackground()
    game.super.drawBackground(self)
    
    if self.freezeFrame then
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.setDitherPattern(0.25, Graphics.image.kDitherTypeBayer8x8)
        Graphics.fillRect(0, 0, 400, 240)
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.setDitherPattern(1.0)
    end
end

-- Freeze frame functionality
function game:triggerFreezeFrame()
    if self.freezeFrame then return end
    self.freezeFrame = true

    if Sound and Sound.playSound then
        -- Stop ambient skate loop (it plays until player crashes)
        if Sound and Sound.stopAmbient then
            Sound.stopAmbient()
        end

        -- Play crash sound provided by the player (centralized here)
        if self.playerRect and self.playerRect.crashSoundName and Sound.playSound then
            Sound.playSound(self.playerRect.crashSoundName)
            -- clear it so it doesn't replay
            self.playerRect.crashSoundName = nil
            Sound.stopMusic()
        end

    end

    SpawnManager.stopSpawner()
    MovementManager.stopAllMovement()
    Shaker:screenShake(GameConstants.EFFECTS.SHAKE_TIME, GameConstants.EFFECTS.SHAKE_MAGNITUDE)

    -- Apply dim effect to all spawned objects
    for _, obj in ipairs(self.objects) do
        if obj and obj.setImageDrawMode then
            obj:setImageDrawMode(Graphics.kDrawModeNXOR) -- kDrawModeNXOR | kDrawModeXOR | kDrawModeFillWhite
        end
        -- Also dim the duplicate sprite if it exists (for curbs)
        if obj.duplicateSprite and obj.duplicateSprite.setImageDrawMode then
            obj.duplicateSprite:setImageDrawMode(Graphics.kDrawModeNXOR)
        end
        
    end
    
    --[[ Also dim the curbs
    if self.curbL then self.curbL:setImageDrawMode(Graphics.kDrawModeNXOR) end
    if self.curbR then self.curbR:setImageDrawMode(Graphics.kDrawModeNXOR) end ]]

    -- Death animation: replace player with flying/falling sprite
    local playerX, playerY = self.playerRect:getPosition()
    local finalX = playerX + 200  -- Where both sprites will meet
    
    -- Remove player sprite
    if self.playerRect then
        self.playerRect:remove()
    end
    
    -- Reset death sprite to flying state before showing
    if self.deathSprite and self.deathSprite.animation then
        self.deathSprite.animation:setState("flying")
    end
    
    -- Add death sprite at player's last position
    self.deathSprite:add(playerX, playerY)
    
    -- Create and add Finish sprite (coming from offscreen)
    local finishSprite = Finish()
    finishSprite:add(450, 120)  -- Start offscreen right
    finishSprite.active = true
    table.insert(self.objects, finishSprite)
    
    -- Animate death sprite: move right (+x) to meeting point
    local moveDeathSprite = playdate.timer.new(900, playerX, finalX, playdate.easingFunctions.outQuad)
    moveDeathSprite.updateCallback = function(timer)
        self.deathSprite:moveTo(timer.value, playerY)
    end
    
    -- Animate finish sprite: move left (-x) to meeting point (simultaneous)
    local finishFinalX = finalX + 50
    local moveFinishSprite = playdate.timer.new(900, 450, finishFinalX, playdate.easingFunctions.outQuad)
    moveFinishSprite.updateCallback = function(timer)
        finishSprite:moveTo(timer.value, 120)
        finishSprite.active = false
    end

    -- UI: small nudge matching meters text movement, then stop
    local uiStartX = (self.metersSpriteText and self.metersSpriteText.x)
    local uiTargetX = finishFinalX + 30 -- not in use atm, but if need the socre ui to be under finish line
    local moveUIScore = playdate.timer.new(1400, uiStartX, uiTargetX, playdate.easingFunctions.outQuad)
    moveUIScore.updateCallback = function(timer)
        if self.metersSpriteText then self.metersSpriteText:moveTo(timer.value, self.metersSpriteText.y) end
        if self.score_ui then self.score_ui:moveTo(timer.value, self.score_ui.y) end
    end
    
    -- After moving, swap death sprite to frame 2 (falling)
    playdate.timer.performAfterDelay(300, function()
        if self.deathSprite and self.deathSprite.animation then
            self.deathSprite.animation:setState("falling")
        end
    end)

    self.freezeTimer = playdate.timer.performAfterDelay(GameConstants.GAME.DEATH_FRAME_DURATION, function()
        self:cleanupForTransition()
        local lastScore = self.playerScore
        Noble.GameData.set("LastScore", lastScore)
        local rank = self:getHighScoreRank(lastScore)
        Noble.GameData.set("HighScoreRank", rank or 0)  -- Use 0 for "no rank"

        Noble.transition(InitialsPostScene, nil, Noble.Transition.CrossDissolve)

    end)
end

function game:cleanupForTransition()
        -- CANCEL ALL ACTIVE EFFECT TIMERS to prevent callbacks after cleanup
    for effectName, effect in pairs(EffectManager.activeEffects) do
        if effect and effect.timer then
            effect.timer:remove()
        end
    end
    EffectManager.activeEffects = {} -- Clear effects table
    
    -- Remove freeze timer if exists
    if self.freezeTimer then
        self.freezeTimer:remove()
        self.freezeTimer = nil
    end
    
    -- Remove death sprite if exists
    if self.deathSprite then
        self.deathSprite:remove()
        self.deathSprite = nil
    end

    -- Remove score UI if exists
    if self.score_ui then
        self.score_ui:remove()
        self.score_ui = nil
    end

    -- Remove all game objects INCLUDING curbs
    for i = #self.objects, 1, -1 do
        local obj = self.objects[i]
        if obj and obj.remove then
            obj:remove()
            -- Also remove duplicate sprites
            if obj.duplicateSprite and obj.duplicateSprite.remove then
                obj.duplicateSprite:remove()
            end
        end
        table.remove(self.objects, i)
    end
    
    -- Remove player
    if self.playerRect and self.playerRect.remove then
        self.playerRect:remove()
    end
    
    -- Remove countdown sprite if it exists
    if self.countdownSprite and self.countdownSprite.remove then
        self.countdownSprite:remove()
        self.countdownSprite = nil
    end

    --remove debugs sprites if exists
    if self.metersSpriteText then
        self.metersSpriteText:remove()
        self.metersSpriteText = nil
    end

    if self.speedSprite then
        self.speedSprite:remove()
        self.speedSprite = nil
    end
    
    -- Stop spawner through system
    SpawnManager.stopSpawner()
    
    -- Clear objects table
    self.objects = {}
end

function game:getHighScoreRank(score)
    for i = 1, 5 do
        local s = Noble.Settings.get("Highscore" .. i) or 0
        if score > s then
            return i
        end
    end
    return nil
end

function game:exit()
    game.super.exit(self)
    SpawnManager.stopSpawner()
    Noble.GameData.set("LastScore", self.playerScore)
end

function game:finish()
    game.super.finish(self)
    
    -- Cleanup
    self.freezeFrame = false
    if self.freezeTimer then
        self.freezeTimer:remove()
        self.freezeTimer = nil
    end
    
    -- Clear references
    self.objects = {}
    self.playerRect = nil
    self.curbL = nil
    self.curbR = nil

end


-- New Spawning stuff to make it work on player.lua
-- Is this in use? maybe not, but leaving it here for now just in case
function game:stopSpawning()
    SpawnManager.stopSpawner()
end
