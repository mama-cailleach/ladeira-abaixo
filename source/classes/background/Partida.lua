Partida = {}
class("Partida").extends(Dressings)

function Partida:init()
    Partida.super.init(self, "assets/images/sprites/partida")

    self.active = false 
    self:setZIndex(7)

end



function Partida:update()
    
    if not self.active then return end

    Partida.super.update(self)

    

end
