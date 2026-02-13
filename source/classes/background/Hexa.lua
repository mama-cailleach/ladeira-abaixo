Hexa = {}
class("Hexa").extends(Dressings)

function Hexa:init()
    Hexa.super.init(self, "assets/images/sprites/rumo-ao-hexa")

    self:setZIndex(7)

end
