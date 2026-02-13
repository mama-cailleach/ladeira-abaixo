Finish = {}
class("Finish").extends(Dressings)

function Finish:init()
    Finish.super.init(self, "assets/images/sprites/finish")

    self.active = false 
    self:setZIndex(20)

end



function Finish:update()
    
    if not self.active then return end

    Finish.super.update(self)

    

end
