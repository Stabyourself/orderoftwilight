laser = class:new()

function laser:init(x, y, dir)
	self.x = x-1/8
	self.y = y-1/8
	self.dir = dir
	self.active = true
	self.static = false
	self.gravity = 0

	self.speedy = 0
	self.speedx = 0
	self.width = 1/4
	self.height = 1/4

	if self.dir == "right" then
		self.speedx = laserspeed
		self.width = 1
		self.x = self.x - 3/8
	elseif self.dir == "left" then
		self.speedx = -laserspeed
		self.width = 1
		self.x = self.x - 3/8
	elseif self.dir == "down" then
		self.speedy = laserspeed
		self.height = 1
		self.y = self.y - 3/8
	elseif self.dir == "up" then
		self.speedy = -laserspeed
		self.height = 1
		self.y = self.y - 3/8
	end


	self.mask = {true, false, true, true}
	self.colortimer = 0
	self.colortable = {{1, 0, 0}, {1, 1, 1}, {1, 1, 0}}
	self.lasercolor = 1
	playsound(lasersound)
end

function laser:update(dt)
	if self.x > xscroll+width*2 or self.x < xscroll-width then
		self.kill = true
	end
	if self.y > yscroll+height*2 or self.y < yscroll-height then
		self.kill = true
	end

	self.colortimer = self.colortimer + dt
	while self.colortimer > lasercolordelay do
		self.colortimer = self.colortimer - lasercolordelay
		self.lasercolor = self.lasercolor + 1
		if self.lasercolor > #self.colortable then
			self.lasercolor = 1
		end
	end

	return self.kill
end

function laser:draw()
	love.graphics.setColor(self.colortable[self.lasercolor])
	love.graphics.rectangle("fill", math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), self.width*tilewidth*scale, self.height*tilewidth*scale)
	love.graphics.setColor(1, 1, 1)
end

function laser:globalcollide(a, b, c, d, dir)
	if b.hurt then
		b:hurt(10)
		damageinworld(b.x+b.width/2, b.y, 10)
	end
	self.kill = true
end

function laser:leftcollide(a, b)
	self:globalcollide(a, b, c, d, "left")
	return false
end

function laser:rightcollide(a, b)
	self:globalcollide(a, b, c, d, "right")
	return false
end

function laser:ceilcollide(a, b)
	self:globalcollide(a, b, c, d, "ceil")
	return false
end

function laser:floorcollide(a, b)
	self:globalcollide(a, b, c, d, "floor")
	return false
end