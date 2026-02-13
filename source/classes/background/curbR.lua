CurbR = {}
class("CurbR").extends(GameObject)

function CurbR:init()
    -- Use GameObject constructor with no collision
    CurbR.super.init(self, "assets/images/sprites/curbR-100w", 8, 7, 400, 19, nil, nil, 5) -- Low Z-index for background

    self:setCenter(0, 0.5)
    
    self.imageWidth = self:getImage():getSize()
    self.duplicateSprite = nil
end

function CurbR:createDuplicate()
    -- Create a duplicate sprite for seamless scrolling
    self.duplicateSprite = CurbR()
    self.duplicateSprite.isDuplicate = true  -- SET THIS BEFORE CALLING ADD!
    self.duplicateSprite:setCenter(0, 0.5)

    -- Position with consistent 2-pixel overlap
    local duplicateX = math.floor(self.x + self.imageWidth - 2)
    self.duplicateSprite:add(duplicateX, self.y)
end

function CurbR:add(x, y)
    CurbR.super.add(self, x, y)
    if not self.isDuplicate then
        self:createDuplicate()
    end
end


function CurbR:update()
    if self.isDuplicate then return end -- Only the main sprite handles logic
    if not self.active then return end -- Don't move until active
    
    CurbR.super.update(self) -- Standard GameObject movement
    
    -- Move duplicate with consistent overlap maintenance
    if self.duplicateSprite then
        self.duplicateSprite:moveBy(-self.moveSpeed, 0)
        self.duplicateSprite:moveTo(math.floor(self.duplicateSprite.x), self.duplicateSprite.y)
    end

    self:moveTo(math.floor(self.x), self.y)
   
    -- Reset logic 
    local resetTrigger = -self.imageWidth
    
    if self.x <= resetTrigger then
        -- Position reset sprite to maintain 2-pixel overlap with visible sprite
        local newX = self.duplicateSprite.x + self.imageWidth - 2
        self:moveTo(newX, self.y)
    end
    
    if self.duplicateSprite and self.duplicateSprite.x <= resetTrigger then
        -- Position reset sprite to maintain 2-pixel overlap with visible sprite
        local newX = self.x + self.imageWidth - 2
        self.duplicateSprite:moveTo(newX, self.y)
    end
end

