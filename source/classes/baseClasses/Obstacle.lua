Obstacle = {}
class("Obstacle").extends(GameObject)

function Obstacle:init(imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset)
    Obstacle.super.init(self, imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset, 10)
end

