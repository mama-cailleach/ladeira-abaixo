-- InitialsPostScene.lua
-- Unified scene for initials entry, transition, and leaderboard/post-game

InitialsPostScene = {}
class("InitialsPostScene").extends(NobleScene)
local scene = InitialsPostScene

function scene:init()
    scene.super.init(self)
    
    -- Set up font
    Graphics.setFont(FONT_PIXO_SMOL)

    -- Get score and rank from transition data
    self.lastScore = Noble.GameData.get("LastScore") or 0
    local rankValue = Noble.GameData.get("HighScoreRank") or 0
    self.rank = (rankValue > 0) and rankValue or nil  -- Convert 0 back to nil
    
    -- Load background sprite sheet (5 frames)
    local imagePath = "assets/images/sprites/ui/initials-leaderboard/initials-table-400-240"
    -- Create NobleSprite with path string and true for spritesheet
    self.backgroundSprite = NobleSprite(imagePath, true)
    
    if self.backgroundSprite.animation then
        -- Frame 1: Static initials screen
        self.backgroundSprite.animation:addState("initials", 1, 1, nil, false)
        -- Frames 2-4: Transition animation
        self.backgroundSprite.animation:addState("transition", 2, 4, "leaderboard", false, nil, 2.5)
        -- Frame 5: Static leaderboard screen
        self.backgroundSprite.animation:addState("leaderboard", 5, 5, nil, false)

        -- Determine initial state based on rank
        if self.rank then
            -- Has a high score - start at initials entry
            Sound.playMusic("chesty3")
            self.backgroundSprite.animation:setState("initials")
            self.shouldShowInitials = true
        else
            -- No high score - skip to leaderboard
            Sound.playMusic("chesty2")
            self.backgroundSprite.animation:setState("leaderboard")
            self.shouldShowInitials = false
        end
    end
    
    self.backgroundSprite:setZIndex(1)
    self.backgroundSprite:moveTo(200, 120)
    
    -- Load selection circle image
    self.selectionImage = Graphics.image.new("assets/images/sprites/ui/initials-leaderboard/selection-circle")
    self.selectionCircle = NobleSprite.new(self.selectionImage)
    self.selectionCircle:setZIndex(10)
    
    -- Letter grid definition (A-Z, 0-9)
    self.letters = {
        {"A","B","C","D","E","F","G","H","I"},
        {"J","K","L","M","N","O","P","Q","R"},
        {"S","T","U","V","W","X","Y","Z"},
        {"1","2","3","4","5","6","7","8","9","0"}
    }
    
    -- Letter positions based on background image layout
    -- Vertical columns with 20px spacing going DOWN
    self.letterPositions = {
        -- Column 1: A-I (x=200, y from 200 down to 40)
        {
            {x=200, y=207}, {x=200, y=185}, {x=200, y=160}, {x=200, y=140}, {x=200, y=120},
            {x=200, y=100}, {x=200, y=75}, {x=200, y=53}, {x=200, y=30}
        },
        -- Column 2: J-R (x=240, y from 200 down to 40)
        {
            {x=235, y=207}, {x=235, y=185}, {x=235, y=165}, {x=235, y=140}, {x=235, y=118},
            {x=235, y=97}, {x=235, y=75}, {x=235, y=53}, {x=235, y=30}
        },
        -- Column 3: S-Z (x=260, y from 200 down to 60)
        {
            {x=268, y=195}, {x=268, y=174}, {x=268, y=150}, {x=268, y=130}, {x=268, y=108},
            {x=268, y=85}, {x=268, y=60}, {x=268, y=40}
        },
        -- Column 4: 1-0 (x=280, y from 200 down to 40)
        {
            {x=300, y=205}, {x=300, y=185}, {x=300, y=165}, {x=300, y=145}, {x=300, y=125},
            {x=300, y=106}, {x=300, y=87}, {x=300, y=68}, {x=300, y=49}, {x=300, y=30}
        }
    }
    
    
    -- Selection state
    self.selectedRow = 1
    self.selectedCol = 1
    self.selectedLetter = 1  -- Which initial slot (1-3) we're filling
    
    -- Initials entered so far
    self.initials = {"", "", ""}
    
    -- Sprite for entered initials
    self.initialsSprites = nil

    -- Navigation lock flag
    self.navigationLocked = false
    
    -- Game state
    self:loadHighScores()
    
    -- Input handler
    self.inputHandler = self:createInputHandler()
end

function scene:createInputHandler()
    return {
        downButtonDown = function()
            if self.shouldShowInitials and self.backgroundSprite.animation.currentName == "initials" and not self.navigationLocked then
                Sound.playSound("dpad", 0.6)
                if self.selectedCol > 1 then
                    self.selectedCol -= 1
                else
                    self.selectedCol = #self.letters[self.selectedRow]
                end
                self:updateSelectorPosition()
            end
        end,
        
        upButtonDown = function()
            if self.shouldShowInitials and self.backgroundSprite.animation.currentName == "initials" and not self.navigationLocked then
                Sound.playSound("dpad", 0.6)
                if self.selectedCol < #self.letters[self.selectedRow] then
                    self.selectedCol += 1
                else
                    self.selectedCol = 1
                end
                self:updateSelectorPosition()
            end
        end,
        
        leftButtonDown = function()
            if self.shouldShowInitials and self.backgroundSprite.animation.currentName == "initials" and not self.navigationLocked then
                Sound.playSound("dpad", 0.6)
                if self.selectedRow > 1 then
                    self.selectedRow -= 1
                    if self.selectedCol > #self.letters[self.selectedRow] then
                        self.selectedCol = #self.letters[self.selectedRow]
                    end
                else
                    self.selectedRow = #self.letters
                    if self.selectedCol > #self.letters[self.selectedRow] then
                        self.selectedCol = #self.letters[self.selectedRow]
                    end
                end
                self:updateSelectorPosition()
            end
        end,
        
        rightButtonDown = function()
            if self.shouldShowInitials and self.backgroundSprite.animation.currentName == "initials" and not self.navigationLocked then
                Sound.playSound("dpad", 0.6)
                if self.selectedRow < #self.letters then
                    self.selectedRow += 1
                    if self.selectedCol > #self.letters[self.selectedRow] then
                        self.selectedCol = #self.letters[self.selectedRow]
                    end
                else
                    self.selectedRow = 1
                    if self.selectedCol > #self.letters[self.selectedRow] then
                        self.selectedCol = #self.letters[self.selectedRow]
                    end
                end
                self:updateSelectorPosition()
            end
        end,
        
        AButtonDown = function()
            if self.backgroundSprite.animation.currentName == "initials" and self.shouldShowInitials then
                if self.navigationLocked then
                    Sound.playSound("abutton", 0.8)
                    -- At OK button - transition to leaderboard
                    self.backgroundSprite.animation:setState("transition")
                    self:saveInitials()
                else
                    Sound.playSound("click", 0.6)
                    -- Select the current letter
                    local letter = self.letters[self.selectedRow][self.selectedCol]
                    self.initials[self.selectedLetter] = letter
                    
                    if self.selectedLetter < 3 then
                        self.selectedLetter += 1
                    end
                    
                    self:updateSelectorPosition()
                    self:refreshInitialsSprite() -- Refresh when initials change
                end
            elseif self.backgroundSprite.animation.currentName == "leaderboard" then
                Sound.playSound("abutton")
                Noble.transition(GameScene)
            end
        end,
        
        BButtonDown = function()
            if self.backgroundSprite.animation.currentName == "initials" and self.shouldShowInitials then
                Sound.playSound("tchin", 0.6)
                -- Find the last filled slot (work backwards from slot 3)
                local lastFilledSlot = 0
                for i = 3, 1, -1 do
                    if self.initials[i] ~= "" then
                        lastFilledSlot = i
                        break
                    end
                end
                if lastFilledSlot > 0 then
                    self.initials[lastFilledSlot] = ""
                    self.selectedLetter = lastFilledSlot  -- Move pointer to the now-empty slot
                    
                    self:updateSelectorPosition()
                    self:refreshInitialsSprite()
                end
            elseif self.backgroundSprite.animation.currentName == "leaderboard" then
                Sound.playSound("sfxon")
                Noble.transition(TitleScene)
            end
        end
    }
end

function scene:updateSelectorPosition()
    -- Check if we have 3 letters - if so, move to OK button
    if self.initials[1] ~= "" and self.initials[2] ~= "" and self.initials[3] ~= "" then
        self.selectionCircle:moveTo(350, 135) -- OK button position
        self.navigationLocked = true
    else
        self.navigationLocked = false -- reset flag
        -- Move selector circle to the selected letter position
        local pos = self.letterPositions[self.selectedRow][self.selectedCol]
        if pos then
            self.selectionCircle:moveTo(pos.x, pos.y)
        end
    end
end

function scene:refreshInitialsSprite()
    -- Create a single image with the initials text
    local initialsStr = table.concat(self.initials)
    local textWidth, textHeight = Graphics.getTextSize(initialsStr)
    local padding = 8
    
    self.initialsImage = Graphics.image.new(textWidth + padding * 2, textHeight + padding * 2)

    Graphics.pushContext(self.initialsImage)
        Graphics.clear(Graphics.kColorClear)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
        Graphics.drawText(initialsStr, padding, padding)
        --Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
    Graphics.popContext()
    
    -- Remove old sprite if exists
    if self.initialsSprite then
        self.initialsSprite:remove()
    end
    
    -- Create sprite and position it
    -- Adjust position to match your background image
    self.initialsSprite = Graphics.sprite.new(self.initialsImage)
    self.initialsSprite:setRotation(270) -- Rotate like in old InitialsScene
    self.initialsSprite:moveTo(120, 120) -- Adjust this position!
    self.initialsSprite:setZIndex(40)
    self.initialsSprite:add()
    
end

-- Load high scores from settings (like PostScene)
function scene:loadHighScores()
    self.highscores = {}
    for i = 1, 5 do
        self.highscores[i] = {
            score = Noble.Settings.get("Highscore" .. i) or 0,
            initials = Noble.Settings.get("Initials" .. i) or "---"
        }
    end
end

-- Save initials and update high scores (simplified like PostScene)
function scene:saveInitials()
    local initialsStr = table.concat(self.initials)
    
    -- Add new score to list
    table.insert(self.highscores, {
        score = self.lastScore,
        initials = initialsStr
    })
    
    -- Sort by score (descending)
    table.sort(self.highscores, function(a, b) return a.score > b.score end)
    
    -- Save top 5 to settings
    for i = 1, 5 do
        Noble.Settings.set("Highscore" .. i, self.highscores[i].score)
        Noble.Settings.set("Initials" .. i, self.highscores[i].initials)
    end
    
end

function scene:drawLeaderboard()
    -- Build scoreboard text from loaded high scores
    local scoreboardText = ""
    
    for i = 1, 5 do
        if self.highscores[i] then
            local text = string.format("%d. %s  %d", i, self.highscores[i].initials, self.highscores[i].score)
            scoreboardText = scoreboardText .. text .. "\n"
        end
    end
    
    -- Calculate image size
    local textWidth, textHeight = Graphics.getTextSize(scoreboardText)
    local padding = 8
    
    -- Create image
    self.endImage = Graphics.image.new(textWidth + padding * 2, textHeight + padding * 2)
    Graphics.pushContext(self.endImage)
        Graphics.clear(Graphics.kColorClear)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
        Graphics.drawText(scoreboardText, padding, padding)
    Graphics.popContext()

end

function scene:drawLastScore()
    local textWidth, textHeight = Graphics.getTextSize(tostring(self.lastScore))
    local padding = 8
    
    self.lastScoreImage = Graphics.image.new(textWidth + padding * 2, textHeight + padding * 2)
    
    Graphics.pushContext(self.lastScoreImage)
        Graphics.clear(Graphics.kColorClear)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
        Graphics.drawText(tostring(self.lastScore), padding, padding)
    Graphics.popContext()
    

end

function scene:enter()
    scene.super.enter(self)

    -- Only set up initials UI if needed
    if self.shouldShowInitials then
        self:updateSelectorPosition()
        self:refreshInitialsSprite()
    end

    -- create Last Score always
    self:drawLastScore()
    
end

function scene:start()
    scene.super.start(self)
end

function scene:update()
    scene.super.update(self)
    
    -- Manual drawing pattern (project standard)
    
    -- Draw background sprite
    if self.backgroundSprite and self.backgroundSprite.animation then
        self.backgroundSprite.animation:draw(0, 0)
    end
    
    -- Draw selection circle (only in initials state)
    if self.shouldShowInitials and self.backgroundSprite.animation.currentName == "initials" then
        self.initialsImage:drawRotated(135, 122, 270) -- Rotated on update
        if self.selectionCircle and self.selectionImage then
            -- Draw static image at sprite position
            self.selectionImage:draw(self.selectionCircle.x - self.selectionImage.width / 2, 
                                     self.selectionCircle.y - self.selectionImage.height / 2)
        end
    end
    
    
    -- Draw leaderboard (only in leaderboard state)
    if self.backgroundSprite.animation.currentName == "leaderboard" then
        self:drawLeaderboard()
        if self.endImage then
            self.endImage:drawRotated(312, 120, 270)
        end
        if self.lastScoreImage then
            self.lastScoreImage:drawRotated(212, 120, 270)
        end
    end
end

function scene:exit()
    scene.super.exit(self)
    if self.initialsSprite then
        self.initialsSprite:remove()
        self.initialsSprite = nil
    end
end

function scene:finish()
    scene.super.finish(self)
    Sound.stopMusic()
    if self.initialsSprite then
        self.initialsSprite:remove()
        self.initialsSprite = nil
    end
end

return InitialsPostScene
