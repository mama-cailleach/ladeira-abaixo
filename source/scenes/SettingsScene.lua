SettingsScene = {}

class("SettingsScene").extends(NobleScene)
local settings = SettingsScene

function settings:init()
    settings.super.init(self)

-- Create background sprite with animation
    self.backgroundSprite = NobleSprite("assets/images/sprites/ui/options-anim-table-400-240", true)
    
    if self.backgroundSprite.animation then
        -- Background animation (frames 1-4)
        self.backgroundSprite.animation:addState("background", 1, 4, nil, true, nil, 2.5)
        
        -- SFX state icons (5-6)
        self.backgroundSprite.animation:addState("sfx_states", 5, 6, nil, false)
        
        -- Music state icons (7-8)
        self.backgroundSprite.animation:addState("music_states", 7, 8, nil, false)

        -- Credits icon (9)
        self.backgroundSprite.animation:addState("credits", 9, 9, nil, false)

        -- Start background animation
        self.backgroundSprite.animation:setState("background")
    end
    
    self.backgroundSprite:setZIndex(-10)
    
    -- Create Noble menu (invisible, just for navigation)
    self.menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4, 6, 0, FONT_PIXO)
    self:setupMenu(self.menu)
    
    -- Input handler
    local crankTick = 0
    self.inputHandler = {
        leftButtonDown = function()
            Sound.playSound("dpad", 0.8)
            self.menu:selectPrevious()
        end,
        rightButtonDown = function()
            Sound.playSound("dpad", 0.8)
            self.menu:selectNext()
        end,
        cranked = function(change, acceleratedChange)
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
            Sound.playSound("abutton")
            self.menu:click()
        end,
        BButtonDown = function()
            Sound.playSound("bbutton")
            Noble.transition(TitleScene2)
        end
    }
end

function settings:enter()
    settings.super.enter(self)
    self.menu:select(1, true)
    self.menu:activate()
end

function settings:update()
    settings.super.update(self)
    
    -- Draw background animation (continuously animating)
    if self.backgroundSprite then
        self.backgroundSprite:draw(0, 0)
    end
    
    -- Draw highlight based on selection
    self:drawMenuHighlight()
end

function settings:exit()
    settings.super.exit(self)
    
    if self.backgroundSprite then
        self.backgroundSprite:remove()
    end
    

end

function settings:setupMenu(__menu)

    local systemMenu = playdate.getSystemMenu()
    
    __menu:addItem("SFX", function()
        Sound.toggleSound()
        Sound.playSound("click")
        local sfxEnabled = Noble.Settings.get("soundEnabled")
        for _, item in ipairs(systemMenu:getMenuItems()) do
            if item:getTitle() == "SFX" then
                item:setValue(sfxEnabled)
            end
        end
    end)

    __menu:addItem("Music", function()        
        Sound.toggleMusic()
        local musicEnabled = Noble.Settings.get("musicEnabled")
        
        for _, item in ipairs(systemMenu:getMenuItems()) do
            if item:getTitle() == "Music" then
                item:setValue(musicEnabled)
            end
        end

        -- If music is now enabled, always start chesty1 fresh
        if musicEnabled then
            Sound.stopMusic()
            Sound.playMusic("chesty1")
        end

    end)
    
    __menu:addItem("Credits", function()
        Noble.transition(CreditsScene)
    end)
    
    -- Set default selection
    self.menu:select(1)
end

function settings:drawMenuHighlight()
    local selectedItem = self.menu.currentItemName
    local musicEnabled, soundEnabled = Sound.getSettings()


    -- Music highlight reflects ON/OFF state
    if selectedItem == "SFX" then
        if soundEnabled then
            self.backgroundSprite.animation:drawFrame(1, "sfx_states", 0, 0) -- Highlighted SFX ON
        else
            self.backgroundSprite.animation:drawFrame(2, "sfx_states", 0, 0) -- Highlighted SFX OFF
        end
    elseif selectedItem == "Music" then
        if musicEnabled then
            self.backgroundSprite.animation:drawFrame(1, "music_states", 0, 0) -- Highlighted Music ON
        else
            self.backgroundSprite.animation:drawFrame(2, "music_states", 0, 0) -- Highlighted Music OFF
        end
    elseif selectedItem == "Credits" then
        self.backgroundSprite.animation:drawFrame(1, "credits", 0, 0) -- Highlighted Credits
    end
end
