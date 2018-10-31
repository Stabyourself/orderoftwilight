function story_load()
	drawmenu = true

	dialog = {
				{t=2, text="twilight?"},
				{t=4, text=" do not be afraid"},
				{t=7, text="  you are dreaming"},
				{t=9, text=false},
				{t=10, text="your mind is in chaos"},
				{t=11, text=""},
				{t=13, text="find what is truly important"},
				{t=13, text="and wake to a beautiful day"},
				{t=17, text=false},
				{t=19, text="    good luck"},
				{t=19.5, text=false},
				{t=20, text=true},

				{t=100000, text="just a lazy programmer who doesn't want to code a simple check"},
			}


	currentdialog = 0
	dialogtable = {}
	dialogtimer = 0
	typedletters = 0
	lettertimer = 0
	letterdelay = 0.05
	storynoise = 0

	cleartimer = 0
	cleartime = 0.5
	playsound(noiserepeatsound)
end

function story_update(dt)
	dialogtimer = dialogtimer + dt

	if dialogtimer > dialog[currentdialog+1].t then
		currentdialog = currentdialog + 1
		if dialog[currentdialog].text == false then
			cleartimer = cleartime
		elseif dialog[currentdialog].text == true then
			changegamestate("game")
			storynoise = 0
		else
			table.insert(dialogtable, dialog[currentdialog].text)
		end
	end

	local totalletters = 0
	for i = 1, #dialogtable do
		totalletters = totalletters + #dialogtable[i]
	end

	if totalletters > typedletters then
		lettertimer = lettertimer + dt
		while lettertimer > letterdelay do
			lettertimer = lettertimer - letterdelay
			typedletters = typedletters + 1
			playsound(lettersound)
		end
	end

	storynoise = math.min(100, storynoise+dt*50)
	if storynoise == 100 then
		drawmenu = false
	end

	if drawmenu then
		menu_update(dt)
	end

	if cleartimer > 0 then
		cleartimer = cleartimer - dt
		if cleartimer <= 0 then
			dialogtable = {}
			typedletters = 0
		end
	end
end

function story_draw()
	if drawmenu then
		menu_draw()
	end


	love.graphics.setColor(1, 1, 1, 0.01*storynoise)
	love.graphics.draw(lotsanoiseimg, -math.random()*240, -math.random()*120, 0, scale, scale)
	love.graphics.setColor(1, 1, 1, 1)

	local xadd, yadd = (math.random()*2-1)/4, (math.random()*2-1)/4

	if cleartimer > 0 then
		love.graphics.setColor(1, 1, 1, cleartimer/cleartime)
	end
	local currentletters = 0
	for i = 1, #dialogtable do
		for j = 1, #dialogtable[i] do
			if currentletters == typedletters then
				break
			end
			properprint(string.sub(dialogtable[i], j, j), 10+8*(j-1)+xadd, i*20+yadd)
			currentletters = currentletters + 1
		end
		if currentletters == typedletters then
			break
		end
	end
	love.graphics.setColor(1, 1, 1)
end

function story_keypressed()
	if dialogtimer > 1 then
		changegamestate("game")
		storynoise = 0
	end
end