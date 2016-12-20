cube = class:new()

function cube:init(x, y)
	self.width = 1.5
	self.height = 1.5
	self.x = x - self.width/2
	self.y = y - self.height/2
	self.active = true
	self.static = false
	self.speedx = 0
	self.speedy = 0
	
	self.gravitydirection = objects.player[1].gravitydirection
	
	self.category = 4
	
	local col = checkrect(self.x, self.y, self.width, self.height, "all", true)
	
	if #col > 0 then
		table.insert(objects.failbox, failbox:new(self.x, self.y, self.width, self.height))
		self.active = false
		self.static = true
		self.kill = true
	end
end

function cube:update(dt)
	return self.kill
end

function cube:draw()
	if self.active then
		love.graphics.draw(cubeimg, math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), 0, scale, scale)
	end
end