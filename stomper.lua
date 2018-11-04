stomper = class:new()

function stomper:init(x, y)
	self.x = x
	self.y = y
	self.height = 4
	self.width = 2
	self.timer = 0
	self.category = 6

	self.active = true
	self.static = true
	self.mask = {true, false, false, true}
end

function stomper:update(dt)
	self.timer = math.fmod(self.timer + dt*stomperspeed, stompertime)
	if self.timer < 1 then
		self.height = self.timer/1*(4-1/3)+1/4
		if not timefrozen and not objects.player[1].dead and #checkrect(self.x, self.y, self.width, self.height, {"player"}) > 0 then
			objects.player[1].y = self.y+self.height+0.01
			if #checkrect(objects.player[1].x, objects.player[1].y, objects.player[1].width, objects.player[1].height, "all", true) > 0 then
				objects.player[1]:die()
			end
		end
	else
		self.height = math.max(1/3, (1-(self.timer-1)/1)*(4-1/3)+1/4)
	end

	return self.kill
end

function stomper:draw()
	love.graphics.setScissor(math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), 2*tilewidth*scale, self.height*tilewidth*scale)
	love.graphics.draw(stomperimg, math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll+self.height-4)*tilewidth)*scale), 0, scale, scale)
	love.graphics.setScissor()
end