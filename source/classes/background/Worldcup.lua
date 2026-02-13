Worldcup = {}
class("Worldcup").extends(Dressings)

function Worldcup:init()
    Worldcup.super.init(self, "assets/images/sprites/worldcup")

    self:setZIndex(7)

end
