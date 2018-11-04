player = class:new()

function player:init(x, y)
	self.x = x
	self.y = y-6/4
	self.width = 6/4
	self.height = 6/4
	self.speedx = 0
	self.speedy = 0
	self.static = false
	self.active = true
	self.gravity = yacceleration
	self.inair = true

	self.category = 3

	self.offsets = {4.5, 4.5}
	self.centers = {12.5, 14.5}
	self.dir = "right"

	self.animstate = "idle"
	self.walkframe = 1
	self.walkframetimer = 0

	self.hornglowtimer = 0

	self.rotation = 0
	self.gravitydirection = math.pi*.5
	self.magicframe = 0
	self.ascendtimer = 0

	self.controlsenabled = true

	self.mask = {}
end

function player:update(dt)
	self:movement(dt)

	self.hornglowtimer = math.fmod(self.hornglowtimer+dt*5, 1)

	self.walkframetimer = self.walkframetimer + dt*10
	while self.walkframetimer > playerwalkdelay do
		self.walkframetimer = self.walkframetimer - playerwalkdelay
		self.walkframe = self.walkframe + 1
		if self.walkframe > 4 then
			self.walkframe = 1
		end
	end

	if not self.dead and self.x >= mapwidth then
		self.dead = true
		self.gravitydirection = math.pi*.5
		levelwin()
	elseif not self.dead then
		if self.y > mapheight and self.gravitydirection ~= math.pi*1.5 then
			leveldie()
			self.dead = true
		elseif self.x+self.width < 0 and self.gravitydirection ~= 0 then
			leveldie()
			self.dead = true
		elseif self.y+self.height < 0 and self.gravitydirection ~= math.pi*.5 then
			leveldie()
			self.dead = true
		end
	end

	if self.ascendtimer > 0 then
		self.ascendtimer = self.ascendtimer - dt
		if self.ascendtimer <= 0 then
			killeverything()
			self.ascendtimer = 0
		end
	end

	if self.ascendtimer > 0.1 then
		self.speedy = - ascendspeed
	end
end

function player:movement(dt)
	local accel = playeraccel
	if self.inair then
		accel = playerairaccel
	end

	local friction = friction
	if self.inair then
		friction = airfriction
	end

	if not self.dead and (rightkey() or self.x > mapwidth-2) then
		if self.x > mapwidth-2 then
			if self.gravitydirection == math.pi*1.5 then
				self.gravitydirection = math.pi*0.5
				self.speedx = -self.speedx
				self.rotation = 0
			end
		end
		if self.speedx == 0 then
			self.walkframe = 2
			self.walkframetimer = 0
		end
		if self.speedx < 0 then
			self.speedx = self.speedx + friction*dt
		end
		self.speedx = self.speedx + accel*dt
		self.dir = "right"
		self.animstate = "walk"
	elseif not self.dead and leftkey() then
		if self.speedx == 0 then
			self.walkframe = 2
			self.walkframetimer = 0
		end
		if self.speedx > 0 then
			self.speedx = self.speedx - friction*dt
		end
		self.speedx = self.speedx - accel*dt
		self.dir = "left"
		self.animstate = "walk"
	elseif not self.dead or not self.inair then
		if self.speedx < 0 then
			self.speedx = self.speedx + friction*dt
			if self.speedx >= 0 then
				self.speedx = 0
				self.animstate = "idle"
			end
		else
			self.speedx = self.speedx - friction*dt
			if self.speedx <= 0 then
				self.speedx = 0
				self.animstate = "idle"
			end
		end
	end

	if self.speedx > maxplayerspeed then
		self.speedx = maxplayerspeed
	elseif self.speedx < -maxplayerspeed then
		self.speedx = -maxplayerspeed
	end

	if self.jumping then
		if self.speedy >= 0 then
			self:stopjump()
		end
	end

	if self.magicframe > 0 then
		self.magictimer = self.magictimer + dt
		while self.magictimer > magicframedelay do
			self.magictimer = self.magictimer - magicframedelay
			self.magicframe = self.magicframe + 1
			if self.magicframe > 5 then
				self.magicframe = 0
			end
		end
	end

	if self.invisible then
		self.invisibletimer = self.invisibletimer - dt
		if self.invisibletimer <= 0 then
			self.invisible = false
			self.invisibletimer = 0
			self.mask[5] = false
		end
	end
end

function player:draw()
	local xscale = scale
	if self.dir == "left" then
		xscale = -xscale
	end

	hornoffset = {x=0, y=0}

	local graphic = playeranimation.idle

	if self.dead then
		graphic = playeranimation.dead
		invisgraphic = playeranimation.dead
	elseif self.ascendtimer > 0 then
		graphic = playeranimation.ascend
		invisgraphic = playeranimation.ascend
	elseif self.inair then
		graphic = playeranimation.jump
		invisgraphic = playeranimationinvis.jump
	elseif self.animstate == "idle" then
		graphic = playeranimation.idle
		invisgraphic = playeranimationinvis.idle
	elseif self.animstate == "walk" then
		graphic = playeranimation.walk[self.walkframe]
		invisgraphic = playeranimationinvis.walk[self.walkframe]
		hornoffset.y = hornoffsets.walk[self.walkframe][2]
	end

	if self.invisible then
		love.graphics.draw(invisgraphic, math.floor(((self.x-xscroll)*tilewidth+self.offsets[1])*scale), math.floor(((self.y-yscroll)*tilewidth+self.offsets[2])*scale), self.rotation, xscale, scale, self.centers[1], self.centers[2])
	end

	if not self.dead then
		local hornglow
		if self.hornglowtimer <= 0.5 then
			hornglow = 0.5+self.hornglowtimer
		else
			hornglow = 1-(self.hornglowtimer-.5)
		end

		if spelltimeouttimer > spelltimeout - .5 then
			local a = (spelltimeout - spelltimeouttimer)/.5
			love.graphics.setColor(1, 1, 1, a)
			hornglow = hornglow * a
		end

		love.graphics.setColor(0.71, 0.28, 0.84, math.min(1, 0.5*(#currentspell/maxrunecount*2))*hornglow)
		love.graphics.draw(hornglowimg, math.floor(((self.x-xscroll)*tilewidth+self.offsets[1]+hornoffset.x)*scale), math.floor(((self.y-yscroll)*tilewidth+self.offsets[2]+hornoffset.y)*scale), self.rotation, xscale, scale, self.centers[1], self.centers[2])

		if #currentspell > 4 then
			love.graphics.setColor(0.71, 0.28, 0.84, math.min(1, 0.5*((#currentspell-4)/maxrunecount*2))*hornglow)
			love.graphics.draw(hornglowbigimg, math.floor(((self.x-xscroll)*tilewidth+self.offsets[1]+hornoffset.x)*scale), math.floor(((self.y-yscroll)*tilewidth+self.offsets[2]+hornoffset.y)*scale), self.rotation, xscale, scale, self.centers[1], self.centers[2])
		end
	end

	local a = 1
	if self.invisible then
		a = (1-self.invisibletimer/invisibletime)
	end

	if not gamewon then
		love.graphics.setColor(1, 1, 1, a)
		love.graphics.draw(graphic, math.floor(((self.x-xscroll)*tilewidth+self.offsets[1])*scale), math.floor(((self.y-yscroll)*tilewidth+self.offsets[2])*scale), self.rotation, xscale, scale, self.centers[1], self.centers[2])
	end

	love.graphics.setColor(1, 1, 1)

	if not self.dead and self.magicframe > 0 then
		local x, y = self:getpos(1, -1.333)
		love.graphics.draw(magicimg, magicquad[self.magicframe], math.floor((x-xscroll)*tilewidth*scale), math.floor((y-yscroll)*tilewidth*scale), 0, scale, scale, 5, 5)
	end
end

function player:jump()
	if not self.dead and self.inair == false then
		playsound(jumpsound)
		self.inair = true
		self.jumping = true
		self.gravity = jumpgravity
		self.speedy = -jumpforce
	end
end

function player:stopjump()
	self.gravity = yacceleration
	self.jumping = false
end

function player:startfall()
	self.inair = true
end

function player:ceilcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end

	if self.dead then
		return false
	end
end

function player:floorcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end

	self.inair = false
	self.jumping = false
end

function player:rightcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end
	self.animstate = "idle"
end

function player:leftcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end
	self.animstate = "idle"
end

function player:globalcollide(a, b, c, d, dir)
	if a == "page" then
		runecount = runecount + 1
		if b.letter then
			runecount = runecount + 1
		end
		playsound(runegetsound)
		b.kill = true
		newrunetimer = newrunetime
		return true
	end

	if not self.dead and a == "tile" then
		local dir = dir
		if dir == "ceil" then
			dir = "up"
		elseif dir == "floor" then
			dir = "down"
		end

		local dir = adjustcollside(dir, self.gravitydirection)

		if dir == "up" then
			dir = "ceil"
		elseif dir == "down" then
			dir = "floor"
		end

		if tilequads[map[b.cox][b.coy][1]][dir .. "spike"] then
			self:die()
		end
	end
	if a == "diamonddog" and not timefrozen then
		self:die()
	end
end

function player:die()
	playsound(playerdeadsound)
	if self.ascendtimer > 0 then
		return
	end
	self.mask = {false, false, true, true, true, true, true, true, true, true}
	self.dead = true
	if self.dir == "right" then
		self.speedx = -10
	else
		self.speedx = 10
	end
	self.speedy = -10
	self.inair = true
	self.controlsenabled = false
	leveldie()
end

function player:getpos(xoffset, yoffset)
	local xoffset, yoffset = (xoffset or 0), (yoffset or 0)
	local x, y, dir
	if self.gravitydirection == math.pi*.5 then
		if self.dir == "right" then
			dir = "right"
			x = self.x+self.width/2+xoffset
			y = self.y+self.height/2+yoffset
		else
			dir = "left"
			x = self.x+self.width/2-xoffset
			y = self.y+self.height/2+yoffset
		end
	elseif self.gravitydirection == math.pi*1.5 then
		if self.dir == "left" then
			dir = "right"
			x = self.x+self.width/2+xoffset
			y = self.y+self.height/2-yoffset
		else
			dir = "left"
			x = self.x+self.width/2-xoffset
			y = self.y+self.height/2-yoffset
		end

	elseif self.gravitydirection == math.pi then
		if self.dir == "left" then
			dir = "up"
			x = self.x+self.width/2-yoffset
			y = self.y+self.height/2-xoffset
		else
			dir = "down"
			x = self.x+self.width/2-yoffset
			y = self.y+self.height/2+xoffset
		end

	elseif self.gravitydirection == 0 then
		if self.dir == "right" then
			dir = "up"
			x = self.x+self.width/2+yoffset
			y = self.y+self.height/2-xoffset
		else
			dir = "down"
			x = self.x+self.width/2+yoffset
			y = self.y+self.height/2+xoffset
		end
	end

	return x, y, dir
end

------------
-- SPELLS --
------------

function player:superjump()
	if self.inair == false then
		playsound(superjumpsound)
		self.inair = true
		self.jumping = true
		self.gravity = jumpgravity
		self.speedy = -superjumpforce
	end
end

function player:laser()
	local x, y, dir = self:getpos(1, -1.333)
	table.insert(objects.laser, laser:new(x, y, dir))
end

function player:laser2()
	self:laser()
end

function player:ceilingwalk()
	self.gravitydirection = math.pi*1.5
	self.rotation = math.pi
end

function player:floorwalk()
	self.gravitydirection = math.pi*.5
	self.rotation = 0
end

function player:leftwalk()
	self.gravitydirection = math.pi
	self.rotation = math.pi*.5
end

function player:rightwalk()
	self.gravitydirection = 0
	self.rotation = math.pi*1.5
end

function player:cubespawn()
	local x, y = self:getpos(2, -2.333)
	table.insert(objects.cube, cube:new(x, y))

	if #objects.cube > 3 and objects.cube[4].active then
		table.remove(objects.cube, 1)
	end
end

function player:teleport()
	local targetx, targety

	local failx, faily, failwidth, failheight

	for i = 1, 3 do
		targetx, targety = self:getpos(teleportdistance, -i+1/4)

		local col = checkrect(targetx-self.width/2, targety, self.width, self.height, "all", true)
		if #col == 0 and targetx-self.width/2+self.width > 0 and targety < mapheight and targety+self.height > 0 then
			self.x, self.y = targetx-self.width/2, targety
			playsound(teleportsound)
			break
		else
			if i == 1 then
				failx, faily, failwidth, failheight = targetx, targety, self.width, self.height
			elseif i == 3 then
				table.insert(objects.failbox, failbox:new(failx, faily, failwidth, failheight, true, self.rotation, self.dir))
			end
		end
	end
end

function player:teleport2()
	self:teleport()
end

function player:timefreeze()
	timefrozen = true
	timefreezetimer = timefreezetime
end

function player:invisibility()
	self.invisible = true
	self.invisibletimer = invisibletime
	self.mask[5] = true
end

function player:shockwave()
	playsound(shockwavesound)
	local x, y, dir = self:getpos(0, -1/3)

	table.insert(objects.shockwave, shockwave:new(x, y, dir))
	if dir == "right" then
		table.insert(objects.shockwave, shockwave:new(x, y, "left"))
	elseif dir == "left" then
		table.insert(objects.shockwave, shockwave:new(x, y, "right"))
	elseif dir == "up" then
		table.insert(objects.shockwave, shockwave:new(x, y, "down"))
	elseif dir == "down" then
		table.insert(objects.shockwave, shockwave:new(x, y, "up"))
	end
end

function player:gamewin()
	playsound(gamewinsound)
	gamewintimer = gamewintime
	gamewon = true
end

function player:ascend()
	playsound(ascendsound)
	self.ascendtimer = ascendtime
end