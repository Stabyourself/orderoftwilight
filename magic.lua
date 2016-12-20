magic = class:new()

function magic:init(x, y)
	self.x = x
	self.y = y
	self.timer = 0
end

function magic:update()