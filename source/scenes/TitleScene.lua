TitleScene = {}

class("TitleScene").extends(NobleScene)
local title = TitleScene

function title:init()
    title.super.init(self)
    --self.background = Graphics.image.new("assets/images/background1")
    self.black = Graphics.kColorBlack
	self.white = Graphics.kColorWhite

    -- Delay flags
    self.menuHighlightDelayStarted = false
    self.showMenuHighlight = false
    self.menuHighlightDelayTimer = nil

    -- INTRO ANIMATION SPRITE
    self.backgroundMenuSprite = NobleSprite("assets/images/sprites/ui/mainmenu/intro-menu-table-400-240", true)    

    if self.backgroundMenuSprite.animation then
        -- Intro sequence 1-40
        self.backgroundMenuSprite.animation:addState("intro", 1, 6, "intro_title", false, function () -- not in use for now but saving here in case
        end, 2.5) -- intro speed. less = faster
        self.backgroundMenuSprite.animation:addState("intro_title", 7, 7, "intro_end", false, function () -- frame 7 direto e segura
        end, 30) -- duration of frame
        self.backgroundMenuSprite.animation:addState("intro_end", 8, 40, "menu_idle", false, function ()
        end, 2.5) -- intro speed. less = faster
        -- menu loop 41-44
        self.backgroundMenuSprite.animation:addState("menu_idle", 41, 44, nil, true, nil, 2.5)

        -- Menu highlight states (individual frames 45-47)
        self.backgroundMenuSprite.animation:addState("highlight_drop", 45, 45, nil, false)
        self.backgroundMenuSprite.animation:addState("highlight_tutorial", 46, 46, nil, false)
        self.backgroundMenuSprite.animation:addState("highlight_options", 47, 47, nil, false)

        -- set intro as starting state
        self.backgroundMenuSprite.animation:setState("intro_title")
    end

    -- Set sprite bounds manually for imagetable animations (400x240 fullscreen)
    self.backgroundMenuSprite:setSize(400, 240)
    self.backgroundMenuSprite:setCenter(0, 0)  -- Top-left anchor
    self.backgroundMenuSprite:setZIndex(-10)

    -- MENU HIGHLIGHT SPRITE (separate sprite for overlays)
    self.menuHighlightSprite = NobleSprite("assets/images/sprites/ui/mainmenu/intro-menu-table-400-240", true)
    
    if self.menuHighlightSprite.animation then
        -- Menu highlight states (individual frames 45-47)
        self.menuHighlightSprite.animation:addState("highlight_drop", 45, 45, nil, false)
        self.menuHighlightSprite.animation:addState("highlight_tutorial", 46, 46, nil, false)
        self.menuHighlightSprite.animation:addState("highlight_options", 47, 47, nil, false)
        
        -- Start with drop highlight
        self.menuHighlightSprite.animation:setState("highlight_drop")
    end
    
    self.menuHighlightSprite:setSize(400, 240)
    self.menuHighlightSprite:setCenter(0, 0)
    self.menuHighlightSprite:setZIndex(15)  -- Above background, below trophy button

    self.trophyButton = NobleSprite("assets/images/sprites/ui/trophy-lb-button", false)
    self.trophyButton:setZIndex(10)
    


    self.menu = nil
    self.menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, self.color2, 4,6,0, FONT_PIXO)
    
    self:setupMenu(self.menu)
    self.menuSprite = nil

    local crankTick = 0

self.inputHandler = {
        leftButtonDown = function()
            if not self.showMenuHighlight then
                return
            end
            Sound.playSound("dpad", 0.8)
            self.menu:selectPrevious()
		end,
		rightButtonDown = function()
            if not self.showMenuHighlight then
                return
            end
            Sound.playSound("dpad", 0.8)
            self.menu:selectNext()
		end,
		cranked = function(change, acceleratedChange)
            if not self.showMenuHighlight then
                return
            end
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
            if not self.showMenuHighlight then
                return
            end
            Sound.playSound("abutton")
            self.menu:click()
		end,
        BButtonDown = function()
            if not self.showMenuHighlight then
                return
            end
            Sound.playSound("sfxon")
			Noble.GameData.set("LastScore", 0)
            Noble.GameData.set("Score", 0)
            Noble.GameData.set("HighScoreRank", 0)
            Noble.transition(InitialsPostScene)
		end,
        --[[ debug clear highscores DELETE or comment out
        upButtonDown = function()
            if not self.showMenuHighlight then
                return
            end
            Sound.playSound("bbutton")
			self:resetHighScoresToDefault()
            print("Highscores reset to default")
		end]]
	}
    
    
end

function title:enter()
    title.super.enter(self)

    if not Sound.isMusicPlaying("chesty1") then 
        Sound.stopMusic()
        Sound.playMusic("chesty1")
    end
    
    -- Add background sprite to scene using Noble's automatic drawing
    self.backgroundMenuSprite:add(0, 0)
    
    self.menu:select(1, true)
	self.menu:activate()
    -- make sure to delete the menu sprite
    if self.menuSprite then
        self.menuSprite:remove()
        self.menuSprite = nil
    end

    self.menuHighlightDelayStarted = false
    self.showMenuHighlight = false
    if self.menuHighlightDelayTimer then
        self.menuHighlightDelayTimer:remove()
        self.menuHighlightDelayTimer = nil
    end


end

function title:start()
	title.super.start(self)
    -- Trophy button will be added by timer in update()
end

function title:update()
    title.super.update(self)
    
    -- Detect first frame of menu_idle and start timer only once
    if self.backgroundMenuSprite.animation.currentName == "menu_idle" and not self.menuHighlightDelayStarted then
        self.menuHighlightDelayStarted = true
        self.menuHighlightDelayTimer = playdate.timer.new(400, function()
            self.showMenuHighlight = true
            self.trophyButton:add(360, 35)
            self.menuHighlightSprite:add(0, 0)  -- Add highlight sprite on top
        end)
    end

    -- Update highlight animation state based on selection
    if self.showMenuHighlight then
        self:updateMenuHighlight()
    end
    
end

function title:exit()
	title.super.exit(self)

    -- Clean up background sprite
    if self.backgroundMenuSprite then
        self.backgroundMenuSprite:remove()
    end

    if self.menuSprite then
        self.menuSprite:remove()
        self.menuSprite = nil
    end

    if self.menuHighlightDelayTimer then
        self.menuHighlightDelayTimer:remove()
        self.menuHighlightDelayTimer = nil
    end

    if self.trophyButton then
        self.trophyButton:remove()
        self.trophyButton = nil
    end
    
    if self.menuHighlightSprite then
        self.menuHighlightSprite:remove()
        self.menuHighlightSprite = nil
    end
    

end

function title:setupMenu(__menu)
__menu:addItem("Drop", function() Noble.transition(GameScene) end)
__menu:addItem("Tutorial", function() Noble.transition(TutorialScene) end)
__menu:addItem("Options", function() Noble.transition(SettingsScene) end)

    -- Set default selection - "DROP" sticker will show immediately
    self.menu:select(1) -- Select first item by default

end

function title:updateMenuHighlight()
    local selectedItem = self.menu.currentItemName
    local highlightState = nil
    
    -- Map menu selections to animation states
    if selectedItem == "Drop" then
        highlightState = "highlight_drop"
    elseif selectedItem == "Tutorial" then
        highlightState = "highlight_tutorial"
    elseif selectedItem == "Options" then
        highlightState = "highlight_options"
    end
    
    -- Switch the HIGHLIGHT SPRITE to the appropriate state (background keeps animating)
    if highlightState and self.menuHighlightSprite then
        self.menuHighlightSprite.animation:setState(highlightState)
    end
end


--reset highscores for debug / take this off. make more sense to only delete if delete pd data (like arcade machine)
function title:resetHighScoresToDefault()
    local defaultScores = {666, 420, 369, 139, 46}
    local defaultInitials = {"DVL", "BOB", "NIC", "VFC", "SXE"}
    for i = 1, 5 do
        Noble.Settings.set("Highscore" .. i, defaultScores[i])
        Noble.Settings.set("Initials" .. i, defaultInitials[i])
    end
end