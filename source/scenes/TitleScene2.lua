TitleScene2 = {}

class("TitleScene2").extends(NobleScene)
local title2 = TitleScene2

function title2:init()
    title2.super.init(self)

    -- Delay flags
    self.menuHighlightDelayStarted = false
    self.showMenuHighlight = false
    self.menuHighlightDelayTimer = nil

    -- Don't create sprites here - do it in enter() to avoid stutter
    self.backgroundMenuSprite = nil
    self.trophyButton = nil

    self.menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, self.color2, 4, 6, 0, FONT_PIXO)
    self:setupMenu(self.menu)
    local crankTick = 0

    self.inputHandler = {
        leftButtonDown = function()
            if not self.showMenuHighlight then return end
            Sound.playSound("dpad", 0.8)
            self.menu:selectPrevious()
        end,
        rightButtonDown = function()
            if not self.showMenuHighlight then return end
            Sound.playSound("dpad", 0.8)
            self.menu:selectNext()
        end,
        cranked = function(change, acceleratedChange)
            if not self.showMenuHighlight then return end
            crankTick = crankTick + change
            if (crankTick > 30) then
                crankTick = 0
                Sound.playSound("dpad", 0.8)
                self.menu:selectNext()
            elseif (crankTick < -30) then
                crankTick = 0
                Sound.playSound("dpad", 0.8)
                self.menu:selectPrevious()
            end
        end,
        AButtonDown = function()
            if not self.showMenuHighlight then return end
            Sound.playSound("abutton")
            self.menu:click()
        end,
        BButtonDown = function()
            if not self.showMenuHighlight then return end
            Sound.playSound("sfxon")
            Noble.GameData.set("LastScore", 0)
            Noble.GameData.set("Score", 0)
            Noble.GameData.set("HighScoreRank", 0)
            Noble.transition(InitialsPostScene)
        end,
        --[[ DELETE or Comment out
        upButtonDown = function()
            if not self.showMenuHighlight then return end
            Sound.playSound("bbutton")
            self:resetHighScoresToDefault()
            print("Highscores reset to default")
        end]]
    }
end

function title2:enter()
    title2.super.enter(self)

        -- Music check (lightweight operation)
    if not Sound.isMusicPlaying("chesty1") then 
        Sound.stopMusic()
        Sound.playMusic("chesty1")
    end
    
    -- Flag to track if we need deferred setup
    self.needsDeferredSetup = false
    
    -- Immediately activate menu (lightweight)
    self.menu:select(1, true)
    self.menu:activate()
    
    self.menuHighlightDelayStarted = false
    if self.menuHighlightDelayTimer then
        self.menuHighlightDelayTimer:remove()
        self.menuHighlightDelayTimer = nil
    end
    
    -- Defer heavy sprite operations to next frame
    self.needsDeferredSetup = true
    
end

function title2:start()
    title2.super.start(self)
end

function title2:update()
    title2.super.update(self)

    if self.needsDeferredSetup then
        self:performDeferredSetup()
        self.needsDeferredSetup = false
    end

    -- Draw highlight overlay (uses same animation/imagetable, no state change)
    if self.showMenuHighlight and self.backgroundMenuSprite and self.backgroundMenuSprite.animation then
        self:drawHighlightOverlay()
    end
end

function title2:performDeferredSetup()
    if not self.backgroundMenuSprite then
        self.backgroundMenuSprite = NobleSprite("assets/images/sprites/ui/mainmenu/intro-menu-table-400-240", true)
        self.backgroundMenuSprite:setSize(400, 240)
        self.backgroundMenuSprite:setCenter(0, 0)
        self.backgroundMenuSprite:setZIndex(-10)

        if self.backgroundMenuSprite.animation then
            -- Main loop
            self.backgroundMenuSprite.animation:addState("menu_idle", 41, 44, nil, true, nil, 2.5)
            self.backgroundMenuSprite.animation:setState("menu_idle")
            -- Highlight frames (single-frame states)
            self.backgroundMenuSprite.animation:addState("highlight_drop", 45, 45, nil, false)
            self.backgroundMenuSprite.animation:addState("highlight_tutorial", 46, 46, nil, false)
            self.backgroundMenuSprite.animation:addState("highlight_options", 47, 47, nil, false)
        end
    end

    if not self.trophyButton then
        self.trophyButton = NobleSprite("assets/images/sprites/ui/trophy-lb-button", false)
        self.trophyButton:setZIndex(10)
    end

    self.backgroundMenuSprite:add(0, 0)
    self.trophyButton:add(360, 35)

    self.showMenuHighlight = true

end



function title2:drawHighlightOverlay()
    local anim = self.backgroundMenuSprite.animation
    local state = self.menu.currentItemName == "Tutorial"
        and "highlight_tutorial"
        or (self.menu.currentItemName == "Options" and "highlight_options" or "highlight_drop")

    -- menu_idle keeps running; we just draw one frame from the highlight state on top
    anim:drawFrame(1, state, 0, 0, anim.direction)
end


function title2:exit()
    title2.super.exit(self)
    
    -- Remove sprites from scene but DON'T destroy them
    if self.backgroundMenuSprite then
        self.backgroundMenuSprite:remove()
        self.backgroundMenuSprite = nil
    end

    if self.trophyButton then
        self.trophyButton:remove()
        self.trophyButton = nil
    end


    collectgarbage("collect")
end

function title2:setupMenu(__menu)
    __menu:addItem("Drop", function() Noble.transition(GameScene) end)
    __menu:addItem("Tutorial", function() Noble.transition(TutorialScene) end)
    __menu:addItem("Options", function() Noble.transition(SettingsScene) end)
    self.menu:select(1)
end

function title2:resetHighScoresToDefault()
    local defaultScores = {666, 420, 369, 139, 46}
    local defaultInitials = {"DVL", "BOB", "NIC", "VFC", "SXE"}
    for i = 1, 5 do
        Noble.Settings.set("Highscore" .. i, defaultScores[i])
        Noble.Settings.set("Initials" .. i, defaultInitials[i])
    end
end