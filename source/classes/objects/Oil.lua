Oil = {}
class("Oil").extends(Obstacle)


function Oil:init()
    Oil.super.init(self, "assets/images/sprites/oil", 3, 1, 40, 50, 0, 0)
    self:setZIndex(8)
end
