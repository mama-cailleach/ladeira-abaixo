Dressings = {}
class("Dressings").extends(GameObject)

function Dressings:init(imagePath)
    Dressings.super.init(self, imagePath, 10, nil, nil, nil, nil, nil, 25)
end
