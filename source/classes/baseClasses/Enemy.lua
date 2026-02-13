Enemy = {}
class("Enemy").extends(GameObject)

function Enemy:init(imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset)
    Enemy.super.init(self, imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset, 18)
end
