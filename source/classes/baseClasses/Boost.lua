Boost = {}
class("Boost").extends(GameObject)

function Boost:init(imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset)
    Boost.super.init(self, imagePath, group, collideGroups, collideRectW, collideRectH, x_offset, y_offset, 10)
end
