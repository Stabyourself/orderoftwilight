shockwave = class:new()

function shockwave:init(x, y, dir)
	self.width = 1
	self.height = 1
	self.speedx = 0
	self.speedy = 0
	self.dir = dir
	self.active = true
	self.static = false
	self.gravity = 0
	self.rotation = 0
	self.category = 7

	self.mask = {true, true, true, true, false, false, true}

	if self.dir == "left" then
		self.height = 2
		self.speedx = -shockwavespeed
	elseif self.dir == "right" then
		self.height = 2
		self.speedx = shockwavespeed
	elseif self.dir == "up" then
		self.width = 2
		self.speedy = -shockwavespeed
		self.rotation = math.pi/2
	elseif self.dir == "down" then
		self.width = 2
		self.speedy = shockwavespeed
		self.rotation = math.pi/2
	end

	self.x = x-self.width/2
	self.y = y-self.height/2

	self.timer = 0

	self.hittable = {}
end

function shockwave:update(dt)
	self.timer = self.timer + dt
	return self.timer >= shockwavetime
end

function shockwave:draw()
	local xscale = scale
	if self.dir == "left" or self.dir == "up" then
		xscale = -xscale
	end
	love.graphics.setColor(1, 1, 1, 1-self.timer/shockwavetime)
	love.graphics.draw(shockwaveimg, math.floor(((self.x-xscroll+self.width/2)*tilewidth)*scale), math.floor(((self.y-yscroll+self.height/2)*tilewidth)*scale), self.rotation, xscale, scale, 4, 6)
	love.graphics.setColor(1, 1, 1)
end

function shockwave:globalcollide(a, b, c, d, dir)
	if not tablecontains(self.hittable, b) and b.hurt then
		b:hurt(5)
		table.insert(self.hittable, b)
		damageinworld(b.x+b.width/2, b.y, 5)
	end
end

function shockwave:leftcollide(a, b)
	self:globalcollide(a, b, c, d, "left")
	return false
end

function shockwave:rightcollide(a, b)
	self:globalcollide(a, b, c, d, "right")
	return false
end

function shockwave:ceilcollide(a, b)
	self:globalcollide(a, b, c, d, "ceil")
	return false
end

function shockwave:floorcollide(a, b)
	self:globalcollide(a, b, c, d, "floor")
	return false
end