--[[
	PHYSICS LIBRARY THING
	WRITTEN BY MAURICE GUÉGAN FOR MARI0
	DON'T STEAL MY SHIT
]]--

function physicsupdate(dt)
	local lobjects = objects

	for j, w in pairs(lobjects) do
		if j ~= "tile" and (not timefrozen or j == "player") then
			for i, v in pairs(w) do
				if v.static == false and v.active then
					--GRAVITY
					v.speedy = v.speedy + (v.gravity or yacceleration)*dt

					if v.speedy > maxyspeed then
						v.speedy = maxyspeed
					end

					--Standard conversion!
					if v.gravitydirection and v.gravitydirection ~= math.pi/2 then
						v.speedx, v.speedy = convertfromstandard(v, v.speedx, v.speedy)
					end

					--COLLISIONS ROFL
					local horcollision = false
					local vercollision = false

					--VS OTHER OBJECTS --but not: portalwall, castlefirefire
					for h, u in pairs(lobjects) do
						local hor, ver = handlegroup(i, h, u, v, j, dt, passed)
						if hor then
							horcollision = true
						end
						if ver then
							vercollision = true
						end
					end

					--VS TILES (Because I only wanna check close ones)
					local xstart = math.floor(v.x+v.speedx*dt-2/16)+1
					local ystart = math.floor(v.y+v.speedy*dt-2/16)+1

					local xfrom = xstart
					local xto = xstart+math.ceil(v.width)
					local dir = 1

					if v.speedx < 0 then
						xfrom, xto = xto, xfrom
						dir = -1
					end

					for x = xfrom, xto, dir do
						for y = ystart, ystart+math.ceil(v.height) do
							--check if invisible block
							if inmap(x, y) then
								local t = lobjects["tile"][x .. "-" .. y]
								if t then
									--    Same object          Active        Not masked
									if (i ~= g or j ~= h) and t.active and v.mask[t.category] ~= true then
										local collision1, collision2 = checkcollision(v, t, "tile", x .. "-" .. y, j, i, dt, passed)
										if collision1 then
											horcollision = true
										elseif collision2 then
											vercollision = true
										end
									end
								end
							end
						end
					end

					--Move the object
					if vercollision == false then
						v.y = v.y + v.speedy*dt
					end

					if horcollision == false then
						v.x = v.x + v.speedx*dt
					end

					if v.gravitydirection and v.gravitydirection ~= math.pi/2 then
						v.speedx, v.speedy = converttostandard(v, v.speedx, v.speedy)
					end

					if v.gravity then
						if math.abs(v.speedy-v.gravity*dt)<0.00001 and v.speedy ~= 0 and v.startfall then
							v:startfall(i)
						end
					else
						if math.abs(v.speedy-yacceleration*dt)<0.00001 and v.speedy ~= 0 and v.startfall then
							v:startfall(i)
						end
					end
				end
			end
		end
	end
end

function handlegroup(i, h, u, v, j, dt, passed)
	local horcollision = false
	local vercollision = false
	for g, t in pairs(u) do
		--    Same object?          Active                 Not masked
		if (i ~= g or j ~= h) and t.active and (v.mask == nil or v.mask[t.category] ~= true) and (t.mask == nil or t.mask[v.category] ~= true) then
			local collision1, collision2 = checkcollision(v, t, h, g, j, i, dt, passed)
			if collision1 then
				horcollision = true
			elseif collision2 then
				vercollision = true
			end
		end
	end

	return horcollision, vercollision
end

function checkcollision(v, t, h, g, j, i, dt, passed) --v: b1table | t: b2table | h: b2type | g: b2id | j: b1type | i: b1id
	local hadhorcollision = false
	local hadvercollision = false

	if math.abs(v.x-t.x) < math.max(v.width, t.width)+1 and math.abs(v.y-t.y) < math.max(v.height, t.height)+1 then
		--check if it's a passive collision (Object is colliding anyway)
		if not passed and aabb(v.x, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --passive collision! (oh noes!)
			if passivecollision(v, t, h, g, j, i, dt) then
				hadvercollision = true
			end

		elseif aabb(v.x + v.speedx*dt, v.y + v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then
			if aabb(v.x + v.speedx*dt, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is horizontal!
				if horcollision(v, t, h, g, j, i, dt) then
					hadhorcollision = true
				end

			elseif aabb(v.x, v.y+v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is vertical!
				if vercollision(v, t, h, g, j, i, dt) then
					hadvercollision = true
				end

			else
				--We're fucked, it's a diagonal collision! run!
				--Okay actually let's take this slow okay. Let's just see if we're moving faster horizontally than vertically, aight?
				local grav = yacceleration
				if self and self.gravity then
					grav = self.gravity
				end
				if math.abs(v.speedy-grav*dt) < math.abs(v.speedx) then
					--vertical collision it is.
					if vercollision(v, t, h, g, j, i, dt) then
						hadvercollision = true
					end
				else
					--okay so we're moving mainly vertically, so let's just pretend it was a horizontal collision? aight cool.
					if horcollision(v, t, h, g, j, i, dt) then
						hadhorcollision = true
					end
				end
			end
		end
	end

	return hadhorcollision, hadvercollision
end

function passivecollision(v, t, h, g, j, i, dt)
	if v.passivecollide then
		v:passivecollide(h, t, i, g)
		if t.passivecollide then
			t:passivecollide(j, v, i, g)
		end
	else
		if v.floorcollide then
			if v:floorcollide(h, t, i, g) ~= false then
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		else
			if v.speedy > 0 then
				v.speedy = 0
			end
			v.y = t.y - v.height
			return true
		end
	end

	return false
end

function horcollision(v, t, h, g, j, i, dt)
	if v.speedx < 0 then
		--move object RIGHT (because it was moving left)

		if collisionexists("right", t) then
			if callcollision("right", t, j, v, g, i) ~= false then
				if t.speedx and t.speedx > 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx > 0 then
				t.speedx = 0
			end
		end
		if collisionexists("left", v) then
			if callcollision("left", v, h, t, i, g) ~= false then
				if v.speedx < 0 then
					v.speedx = 0
				end
				v.x = t.x + t.width
				return true
			end
		else
			if v.speedx < 0 then
				v.speedx = 0
			end
			v.x = t.x + t.width
			return true
		end
	else
		--move object LEFT (because it was moving right)

		if collisionexists("left", t) then
			if callcollision("left", t, j, v, g, i) ~= false then
				if t.speedx and t.speedx < 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx < 0 then
				t.speedx = 0
			end
		end

		if collisionexists("right", v) then
			if callcollision("right", v, h, t, i, g) ~= false then
				if v.speedx > 0 then
					v.speedx = 0
				end
				v.x = t.x - v.width
				return true
			end
		else
			if v.speedx > 0 then
				v.speedx = 0
			end
			v.x = t.x - v.width
			return true
		end
	end

	return false
end

function vercollision(v, t, h, g, j, i, dt)
	if v.speedy < 0 then
		--move object DOWN (because it was moving up)
		if collisionexists("floor", t) then
			if callcollision("floor", t, j, v, g, i) ~= false then
				if t.speedy and t.speedy > 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy > 0 then
				t.speedy = 0
			end
		end

		if collisionexists("ceil", v) then
			if callcollision("ceil", v, h, t, i, g) ~= false then
				if v.speedy < 0 then
					v.speedy = 0
				end
				v.y = t.y  + t.height
				return true
			end
		else
			if v.speedy < 0 then
				v.speedy = 0
			end
			v.y = t.y  + t.height
			return true
		end
	else
		if collisionexists("ceil", t) then
			if callcollision("ceil", t, j, v, g, i) ~= false then
				if t.speedy and t.speedy < 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy < 0 then
				t.speedy = 0
			end
		end
		if collisionexists("floor", v) then
			if callcollision("floor", v, h, t, i, g) ~= false then
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		else
			if v.speedy > 0 then
				v.speedy = 0
			end
			v.y = t.y - v.height
			return true
		end
	end
	return false
end

function collisionscalls(dir, obj, a, b, c, d)
	local r

	if obj.gravitydirection > math.pi/4*1 and obj.gravitydirection <= math.pi/4*3 then
		if dir == "floor" then
			if obj.floorcollide then
				r = obj:floorcollide(a, b, c, d)
			end
		elseif dir == "left" then
			if obj.leftcollide then
				r = obj:leftcollide(a, b, c, d)
			end
		elseif dir == "ceil" then
			if obj.ceilcollide then
				r = obj:ceilcollide(a, b, c, d)
			end
		elseif dir == "right" then
			if obj.rightcollide then
				r = obj:rightcollide(a, b, c, d)
			end
		end
	elseif obj.gravitydirection > math.pi/4*3 and obj.gravitydirection <= math.pi/4*5 then
		if dir == "floor" then
			if obj.rightcollide then
				r = obj:rightcollide(a, b, c, d)
			end
		elseif dir == "left" then
			if obj.floorcollide then
				r = obj:floorcollide(a, b, c, d)
			end
		elseif dir == "ceil" then
			if obj.leftcollide then
				r = obj:leftcollide(a, b, c, d)
			end
		elseif dir == "right" then
			if obj.ceilcollide then
				r = obj:ceilcollide(a, b, c, d)
			end
		end
	elseif obj.gravitydirection > math.pi/4*5 and obj.gravitydirection <= math.pi/4*7 then
		if dir == "floor" then
			if obj.ceilcollide then
				r = obj:ceilcollide(a, b, c, d)
			end
		elseif dir == "left" then
			if obj.rightcollide then
				r = obj:rightcollide(a, b, c, d)
			end
		elseif dir == "ceil" then
			if obj.floorcollide then
				r = obj:floorcollide(a, b, c, d)
			end
		elseif dir == "right" then
			if obj.leftcollide then
				r = obj:leftcollide(a, b, c, d)
			end
		end
	else
		if dir == "floor" then
			if obj.leftcollide then
				r = obj:leftcollide(a, b, c, d)
			end
		elseif dir == "left" then
			if obj.ceilcollide then
				r = obj:ceilcollide(a, b, c, d)
			end
		elseif dir == "ceil" then
			if obj.rightcollide then
				r = obj:rightcollide(a, b, c, d)
			end
		elseif dir == "right" then
			if obj.floorcollide then
				r = obj:floorcollide(a, b, c, d)
			end
		end
	end

	return r
end

function callcollision(dir, obj, a, b, c, d)
	if not obj.gravitydirection then
		if dir == "floor" then
			return obj:floorcollide(a, b, c, d)
		elseif dir == "left" then
			return obj:leftcollide(a, b, c, d)
		elseif dir == "ceil" then
			return obj:ceilcollide(a, b, c, d)
		elseif dir == "right" then
			return obj:rightcollide(a, b, c, d)
		end
	end

	obj.speedx, obj.speedy = converttostandard(obj, obj.speedx, obj.speedy)

	local r

	r = collisionscalls(dir, obj, a, b, c, d)

	obj.speedx, obj.speedy = convertfromstandard(obj, obj.speedx, obj.speedy)

	return r
end

function collisionexists(dir, obj)
	if not obj.gravitydirection or (obj.gravitydirection > math.pi/4*1 and obj.gravitydirection <= math.pi/4*3) then
		if dir == "floor" then
			return obj.floorcollide
		elseif dir == "left" then
			return obj.leftcollide
		elseif dir == "ceil" then
			return obj.ceilcollide
		elseif dir == "right" then
			return obj.rightcollide
		end
	elseif obj.gravitydirection > math.pi/4*3 and obj.gravitydirection <= math.pi/4*5 then
		if dir == "floor" then
			return obj.rightcollide
		elseif dir == "left" then
			return obj.floorcollide
		elseif dir == "ceil" then
			return obj.leftcollide
		elseif dir == "right" then
			return obj.ceilcollide
		end
	elseif obj.gravitydirection > math.pi/4*5 and obj.gravitydirection <= math.pi/4*7 then
		if dir == "floor" then
			return obj.ceilcollide
		elseif dir == "left" then
			return obj.rightcollide
		elseif dir == "ceil" then
			return obj.floorcollide
		elseif dir == "right" then
			return obj.leftcollide
		end
	else
		if dir == "floor" then
			return obj.leftcollide
		elseif dir == "left" then
			return obj.ceilcollide
		elseif dir == "ceil" then
			return obj.rightcollide
		elseif dir == "right" then
			return obj.floorcollide
		end
	end
end

function adjustcollside(side, gravitydirection)
	if side == "left" then
		if gravitydirection > math.pi/4*1 and gravitydirection <= math.pi/4*3 then --down
			return "left"
		elseif gravitydirection > math.pi/4*3 and gravitydirection <= math.pi/4*5 then --left
			return "up"
		elseif gravitydirection > math.pi/4*5 and gravitydirection <= math.pi/4*7 then --up
			return "right"
		else --right
			return "down"
		end
	elseif side == "up" then
		if gravitydirection > math.pi/4*1 and gravitydirection <= math.pi/4*3 then --down
			return "up"
		elseif gravitydirection > math.pi/4*3 and gravitydirection <= math.pi/4*5 then --left
			return "right"
		elseif gravitydirection > math.pi/4*5 and gravitydirection <= math.pi/4*7 then --up
			return "down"
		else --right
			return "left"
		end
	elseif side == "right" then
		if gravitydirection > math.pi/4*1 and gravitydirection <= math.pi/4*3 then --down
			return "right"
		elseif gravitydirection > math.pi/4*3 and gravitydirection <= math.pi/4*5 then --left
			return "down"
		elseif gravitydirection > math.pi/4*5 and gravitydirection <= math.pi/4*7 then --up
			return "left"
		else --right
			return "up"
		end
	elseif side == "down" then
		if gravitydirection > math.pi/4*1 and gravitydirection <= math.pi/4*3 then --down
			return "down"
		elseif gravitydirection > math.pi/4*3 and gravitydirection <= math.pi/4*5 then --left
			return "left"
		elseif gravitydirection > math.pi/4*5 and gravitydirection <= math.pi/4*7 then --up
			return "up"
		else --right
			return "right"
		end
	end
end

function aabb(ax, ay, awidth, aheight, bx, by, bwidth, bheight)
	return ax+awidth > bx and ax < bx+bwidth and ay+aheight > by and ay < by+bheight
end

function checkrect(x, y, width, height, list, statics)
	local out = {}

	local inobj

	if type(list) == "table" and list[1] == "exclude" then
		inobj = list[2]
		list = "all"
	end

	for i, v in pairs(objects) do
		local contains = false

		if list and list ~= "all" then
			for j = 1, #list do
				if list[j] == i then
					contains = true
				end
			end
		end

		if list == "all" or contains then
			for j, w in pairs(v) do
				if statics or w.static ~= true or list ~= "all" then
					local skip = false
					if inobj then
						if w.x == inobj.x and w.y == inobj.y then
							skip = true
						end
						--masktable
						if (inobj.mask ~= nil and inobj.mask[w.category] == true) or (w.mask ~= nil and w.mask[inobj.category] == true) then
							skip = true
						end
					end
					if not skip then
						if w.active then
							if aabb(x, y, width, height, w.x, w.y, w.width, w.height) then
								table.insert(out, i)
								table.insert(out, j)
							end
						end
					end
				end
			end
		end
	end

	return out
end

function converttostandard(obj, speedx, speedy)
	--Convert speedx and speedy to horizontal values
	local speed = math.sqrt(speedx^2+speedy^2)
	local speeddir = math.atan2(speedy, speedx)

	local speedx, speedy = math.cos(speeddir-obj.gravitydirection+math.pi/2)*speed, math.sin(speeddir-obj.gravitydirection+math.pi/2)*speed

	if math.abs(speedy) < 0.00001 then
		speedy = 0
	end
	if math.abs(speedx) < 0.00001 then
		speedx = 0
	end

	return speedx, speedy
end

function convertfromstandard(obj, speedx, speedy)
	--reconvert speedx and speedy to actual directions
	local speed = math.sqrt(speedx^2+speedy^2)
	local speeddir = math.atan2(speedy, speedx)

	local speedx, speedy = math.cos(speeddir+obj.gravitydirection-math.pi/2)*speed, math.sin(speeddir+obj.gravitydirection-math.pi/2)*speed

	if math.abs(speedy) < 0.00001 then
		speedy = 0
	end
	if math.abs(speedx) < 0.00001 then
		speedx = 0
	end

	return speedx, speedy
end

function unrotate(rotation, gravitydirection, dt)
	--rotate back to gravitydirection (portals)
	rotation = math.fmod(rotation, math.pi*2)

	if rotation < -math.pi then
		rotation = rotation + math.pi*2
	elseif rotation > math.pi then
		rotation = rotation - math.pi*2
	end

	if rotation == math.pi and gravitydirection == 0 then
		rotation = rotation + portalrotationalignmentspeed*dt
	elseif rotation <= -math.pi/2 and gravitydirection == math.pi*1.5 then
		rotation = rotation - portalrotationalignmentspeed*dt
	elseif rotation > (gravitydirection-math.pi/2) then
		rotation = rotation - portalrotationalignmentspeed*dt
		if rotation < (gravitydirection-math.pi/2) then
			rotation = (gravitydirection-math.pi/2)
		end
	elseif rotation < (gravitydirection-math.pi/2) then
		rotation = rotation + portalrotationalignmentspeed*dt
		if rotation > (gravitydirection-math.pi/2) then
			rotation = (gravitydirection-math.pi/2)
		end
	end

	return rotation
end