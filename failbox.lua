failbox = class:new()

function failbox:init(x, y, width, height, pony, rotation, dir)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.pony = pony
	self.rotation = rotation
	self.dir = dir

	self.active = false
	self.static = true

	self.destroytimer = 1
end

function failbox:update(dt)
	if self.destroytimer then
		self.destroytimer = self.destroytimer - dt*2
		if self.destroytimer <= 0 then
			return true
		end
	end
end

function failbox:draw()
	love.graphics.setColor(1, 0, 0, self.destroytimer)
	if self.pony then
		local xscale = scale
		if self.dir == "left" then
			xscale = -xscale
		end

		love.graphics.draw(playeranimationinvis.idle, math.floor(((self.x-xscroll)*tilewidth+4.5)*scale), math.floor(((self.y-yscroll)*tilewidth+4.5)*scale), self.rotation, xscale, scale, 12.5, 14.5)
	else
		love.graphics.rectangle("line", math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), self.width*tilewidth*scale, self.height*tilewidth*scale)
	end
	love.graphics.setColor(1, 1, 1)
end