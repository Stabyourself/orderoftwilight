tile = class:new()

function tile:init(x, y)
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedx = 0
	self.speedy = 0
	self.width = 1
	self.height = 1
	self.active = true
	self.static = true
	self.category = 2
	self.mask = {true}
end