CAFlag = {}
class("CAFlag").extends(Dressings)

function CAFlag:init()
    CAFlag.super.init(self, "assets/images/sprites/canada")

    self:setZIndex(7)

end
