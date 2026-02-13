Uninho = {}
class("Uninho").extends(Enemy)

function Uninho:init()
    Uninho.super.init(self, "assets/images/sprites/uninho", 2, 1, 95, 65)
end
