quad = class:new()

--COLLIDE?

function quad:init(img, imgdata, x, y, width, height)
	--get if empty?

	self.img = img
	self.quad = love.graphics.newQuad((x-1)*(tilewidth+1), (y-1)*(tilewidth+1), tilewidth, tilewidth, width, height)
	self.spikes = {}

	--get collision
	self.collision = false
	local r, g, b, a = imgdata:getPixel(x*(tilewidth+1)-1, (y-1)*(tilewidth+1))
	if a > 0.5 then
		self.collision = true
	end

	--downspike
	self.floorspike = false
	local r, g, b, a = imgdata:getPixel(x*(tilewidth+1)-1, (y-1)*(tilewidth+1)+1)
	if a > 0.5 then
		self.floorspike = true
	end

	--rightspike
	self.leftspike = false
	local r, g, b, a = imgdata:getPixel(x*(tilewidth+1)-1, (y-1)*(tilewidth+1)+2)
	if a > 0.5 then
		self.leftspike = true
	end

	--upspike
	self.ceilspike = false
	local r, g, b, a = imgdata:getPixel(x*(tilewidth+1)-1, (y-1)*(tilewidth+1)+3)
	if a > 0.5 then
		self.ceilspike = true
	end

	--leftspike
	self.rightspike = false
	local r, g, b, a = imgdata:getPixel(x*(tilewidth+1)-1, (y-1)*(tilewidth+1)+4)
	if a > 0.5 then
		self.rightspike = true
	end

end