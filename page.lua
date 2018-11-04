page = class:new()

function page:init(x, y, t)
	self.letter = t

	if self.letter then
		self.width = 3
		self.height = 2
	else
		self.width = 1+1/3
		self.height = 1+2/3
	end
	self.x = x+.5-self.width/2
	self.y = y+.5-self.height/2
	self.static = true
	self.active = true

	self.timer = 0

	self.mask = {true, true, false, true, true, true, true, true, true, true, true, true, true}
end

function page:update(dt)
	self.timer = math.fmod(self.timer+dt*4, math.pi*2)

	return self.kill
end

function page:draw()
	if self.letter then
		love.graphics.draw(letterimg, math.floor((self.x+self.width/2-xscroll)*tilewidth*scale), math.floor(((self.y+self.height/2-yscroll)*tilewidth+math.sin(self.timer)*2)*scale), 0, scale, scale, 16.5, 13.5)
	else
		love.graphics.draw(pageimg, math.floor((self.x+self.width/2-xscroll)*tilewidth*scale), math.floor(((self.y+self.height/2-yscroll)*tilewidth+math.sin(self.timer)*2)*scale), 0, scale, scale, 9, 9.5)
	end
end