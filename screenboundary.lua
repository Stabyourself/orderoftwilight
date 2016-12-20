screenboundary = class:new()

function screenboundary:init(x)
	self.x = x
	self.y = -100
	self.height = 200
	self.width = 0
	self.active = true
	self.static = true
end