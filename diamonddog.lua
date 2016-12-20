diamonddog = class:new()

function diamonddog:init(x, y)
	self.width = 1.5
	self.height = 2.5
	self.x = x-self.width
	self.y = y-self.height
	self.active = true
	self.static = false
	
	self.speedy = 0
	self.speedx = -diamonddogspeed
	self.dir = "left"
	
	self.frame = 1
	self.frametimer = 0
	self.category = 5
	
	self.mask = {true, false, false, false, true}
	
	self.hp = 10
end

function diamonddog:update(dt)
	self.frametimer = self.frametimer + dt
	while self.frametimer > diamonddogdelay do
		self.frametimer = self.frametimer - diamonddogdelay
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
	end
	
	return self.kill
end

function diamonddog:draw()
	if not self.kill then
		local xscale = scale
		if self.dir == "right" then
			xscale = -xscale
		end
		love.graphics.draw(_G["diamonddog" .. self.frame .. "img"], math.floor(((self.x-xscroll)*tilewidth+4.5)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), 0, xscale, scale, 4.5)
	end
end

function diamonddog:globalcollide(a, b, c, d, dir)
	if a == "shockwave" then
		return true
	end
end

function diamonddog:leftcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d) then
		return false
	end
	
	if not timefrozen then
		self.speedx = diamonddogspeed
		self.dir = "right"
		return false
	end
end

function diamonddog:rightcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d) then
		return false
	end
	
	if not timefrozen then
		self.speedx = -diamonddogspeed
		self.dir = "left"
		return false
	end
end

function diamonddog:ceilcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d) then
		return false
	end
end

function diamonddog:floorcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d) then
		return false
	end
end

function diamonddog:hurt(damage)
	self.hp = self.hp - damage
	if self.hp <= 0 then
		self.kill = true
		playsound(deadsound)
	else
		playsound(hurtsound)
	end
end