CreditsScene = {}

class("CreditsScene").extends(NobleScene)

function CreditsScene:init()
    CreditsScene.super.init(self)

    Graphics.setBackgroundColor(Graphics.kColorWhite)

    -- Scrolling state
    self.scrollOffset = 0
    self.maxScroll = 1354  -- 1754 (sprite width) - 240 (screen width)
    self.scrollSpeed = 210   -- Pixels to scroll per input

    local crankTick = 0

    self.inputHandler = {
        AButtonDown = function()
            Sound.playSound("abutton")
            Noble.transition(TitleScene2)
        end,
        BButtonDown = function()
            Sound.playSound("bbutton")
            Noble.transition(SettingsScene)
        end,
        rightButtonDown = function()
            Sound.playSound("dpad")
            self.scrollOffset = math.min(self.scrollOffset + self.scrollSpeed, self.maxScroll)
        end,
        leftButtonDown = function()
            Sound.playSound("dpad")
            self.scrollOffset = math.max(self.scrollOffset - self.scrollSpeed, 0)
        end,
        cranked = function(change, acceleratedChange)
            crankTick = crankTick + change
            if math.abs(crankTick) > 10 then
                self.scrollOffset = math.max(0, math.min(self.scrollOffset + (crankTick / 2), self.maxScroll))
                crankTick = 0
            end
        end
    }
end

function CreditsScene:enter()
    CreditsScene.super.enter(self)

    -- Reset scroll position
    self.scrollOffset = 0

    if not self.creditsImage then
        self.creditsImage = Graphics.image.new("assets/images/sprites/ui/credits")
    end
end

function CreditsScene:exit()
    CreditsScene.super.exit(self)

    self.creditsImage = nil
end

function CreditsScene:update()
    CreditsScene.super.update(self)

    -- Draw the credits image with current scroll offset
    if self.creditsImage then
        -- No rotation - sprite is already in correct orientation
        -- 1754x240 sprite: 1754 wide, 240 tall (matches screen height in portrait)
        -- X=-scrollOffset: starts at 0 (showing left), negative values move image left to scroll right
        -- Y=0 aligns top edge with screen
        self.creditsImage:draw(-self.scrollOffset, 0)
    end
end
