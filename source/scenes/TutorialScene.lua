 TutorialScene = {}

class("TutorialScene").extends(NobleScene)

function TutorialScene:init()
    TutorialScene.super.init(self)

    Graphics.setBackgroundColor(Graphics.kColorWhite)

    -- Scrolling state
    self.scrollOffset = 0
    self.maxScroll = 1354  -- 1754 (sprite width) - 240 (screen width)
    self.scrollSpeed = 210   -- Pixels to scroll per input

    local crankTick = 0

    self.inputHandler = {
        AButtonDown = function()
            Sound.playSound("abutton")
            Noble.transition(GameScene, nil, Noble.Transition.SlideOffLeft)
        end,
        BButtonDown = function()
            Sound.playSound("bbutton")
            Noble.transition(TitleScene2)
        end,
        rightButtonDown = function()
            Sound.playSound("click")
            self.scrollOffset = math.min(self.scrollOffset + self.scrollSpeed, self.maxScroll)
        end,
        leftButtonDown = function()
            Sound.playSound("click")
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

function TutorialScene:enter()
    TutorialScene.super.enter(self)

    -- Reset scroll position
    self.scrollOffset = 0

    if not self.tutorialImage then
        self.tutorialImage = Graphics.image.new("assets/images/sprites/ui/tutorial")
    end
end

function TutorialScene:exit()
    TutorialScene.super.exit(self)

    self.tutorialImage = nil
end


function TutorialScene:update()
    TutorialScene.super.update(self)

    -- Draw the tutorial image with current scroll offset
    if self.tutorialImage then
        -- No rotation - sprite is already in correct orientation
        -- 1754x240 sprite: 1754 wide, 240 tall (matches screen height in portrait)
        -- X=-scrollOffset: starts at 0 (showing left), negative values move image left to scroll right
        -- Y=0 aligns top edge with screen
        self.tutorialImage:draw(-self.scrollOffset, 0)
    end

    Utilities.crankView()
end
