CurbL = {}
class("CurbL").extends(GameObject)

function CurbL:init()
    CurbL.super.init(self, "assets/images/sprites/curbL-100w", 8, 7, 400, 19, nil, nil, 5)
    
    -- Set left anchor for pixel-perfect tiling
    self:setCenter(0, 0.5)
    
    self.imageWidth = self:getImage():getSize()
    self.duplicateSprite = nil
    

end


function CurbL:createDuplicate()
    self.duplicateSprite = CurbL()
    self.duplicateSprite.isDuplicate = true
    self.duplicateSprite:setCenter(0, 0.5)
    self.duplicateSprite.baseSpeed = self.baseSpeed or 6
    self.duplicateSprite.moveSpeed = self.moveSpeed or 6
    
    -- Position with consistent 2-pixel overlap
    local duplicateX = math.floor(self.x + self.imageWidth - 2)
    self.duplicateSprite:add(duplicateX, self.y)

end

function CurbL:add(x, y)
    CurbL.super.add(self, x, y)
    if not self.isDuplicate then
        self:createDuplicate()
    end
end

function CurbL:update()
    if self.isDuplicate then return end
    if not self.active then return end

    CurbL.super.update(self)

    
    -- OLD Move duplicate with consistent overlap maintenance
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
