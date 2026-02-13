-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

function Utilities.getZero()
	return 0
end

function Utilities.crankView()
	if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw(0,-10)
    else return
    end
	
end