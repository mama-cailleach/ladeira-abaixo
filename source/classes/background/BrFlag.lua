BRFlag = {}
class("BRFlag").extends(Dressings)

function BRFlag:init()
    BRFlag.super.init(self, "assets/images/sprites/br")

    self:setZIndex(7)

end
