damagenumber = class:new()

function damagenumber:init(x, y, i)
	self.i = tostring(i)
	self.x = x
	self.y = y
	self.timer = 0
end

function damagenumber:update(dt)
	self.y = self.y - dt*damagenumberspeed
	self.timer = self.timer + dt/damagenumberduration

	return self.timer >= 1
end

function damagenumber:draw()
	love.graphics.setColor(1, 0, 0, 1-self.timer)
	numberprint(self.i, self.x-(#self.i*2.5), self.y)
	love.graphics.setColor(1, 1, 1)
end