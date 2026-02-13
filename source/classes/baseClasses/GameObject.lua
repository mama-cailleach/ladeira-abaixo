import "utilities/GameConstants"

GameObject = {}
class("GameObject").extends(NobleSprite)

function GameObject:init(imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset, zIndex)
    GameObject.super.init(self)
    
    -- Image setup
    local img = Graphics.image.new(imagePath)
    assert(img, "Image failed to load: " .. imagePath)
    self:setImage(img)
    

     if collideRectW and collideRectH then
        local offsetX = x_offset or 0
        local offsetY = y_offset or 0
        self:setCollideRect(offsetX, offsetY, collideRectW, collideRectH)
        self.collisionResponse = NobleSprite.kCollisionTypeOverlap
     end
    
    if group then
        self:setGroups(group)
    end
    
    if collideGroups then
        self:setCollidesWithGroups(collideGroups)
    end
    
    -- Speed setup - UNIFIED HERE
    self.baseSpeed = GameConstants.MOVEMENT.NORMAL_SPEED
    self.moveSpeed = self.baseSpeed
    
    -- Z-index setup
    self:setZIndex(zIndex)

    

end

function GameObject:setMirrored(mirrored)
    if mirrored then
        self:setImageFlip(Graphics.kImageFlippedY)
    else
        self:setImageFlip(Graphics.kImageUnflipped)
    end
end

function GameObject:add(x, y)
    playdate.graphics.sprite.add(self)  -- Add to sprite system manually
    self:moveTo(x, y)
    self.realX = x  -- Initialize position tracking
end

function GameObject:update()
    GameObject.super.update(self)
    -- Floor the movement delta
    -- Simple movement with moveBy - let NobleSprite handle positioning

    local deltaX = -math.floor(self.moveSpeed)
    self:moveBy(deltaX, 0)
    
    -- ✅ Floor position to prevent floating-point accumulation (like curbs do)
    self:moveTo(math.floor(self.x), self.y) 

    
end