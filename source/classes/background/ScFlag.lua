SCFlag = {}
class("SCFlag").extends(Dressings)

function SCFlag:init()
    SCFlag.super.init(self, "assets/images/sprites/scotland")

    self:setZIndex(7)

end
