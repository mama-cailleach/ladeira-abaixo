Pipoqueiro = {}
class("Pipoqueiro").extends(Enemy)

function Pipoqueiro:init()
    Pipoqueiro.super.init(self, "assets/images/sprites/pipoqueiro", 2, 1, 115, 40, 0, 0)
end
