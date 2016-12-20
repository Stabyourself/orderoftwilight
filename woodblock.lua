woodblock = class:new()
	
function woodblock:init(x, y)
	self.x = x
	self.y = y
	self.width = 1
	self.height = 1
	self.static = true
	self.active = true
	
	self.hp = 10
end

function woodblock:update(dt)
	return self.kill
end

function woodblock:draw()
	love.graphics.draw(woodblockimg, math.floor(((self.x-xscroll)*tilewidth)*scale), math.floor(((self.y-yscroll)*tilewidth)*scale), 0, scale, scale)
end

function woodblock:hurt(s)
	self.hp = self.hp - s
	if self.hp <= 0 then
		self.kill = true
	end
	playsound(hurtsound)
end