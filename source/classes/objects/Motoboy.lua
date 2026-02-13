Motoboy = {}
class("Motoboy").extends(Enemy)

function Motoboy:init()
    Motoboy.super.init(self, "assets/images/sprites/motoboy", 2, 1, 30, 90, 40, 0)
end



function Motoboy:update()
    Motoboy.super.update(self)
end
    