function _init()
	--game states
	TITLE = 0
	PLAYING = 1 
	
	gameState = TITLE
	gameOver = false
	--title screen
	index = 1 --# of letters to show
	title = {} --title letters to draw
	
	--menu theme
	sfx(3)
	
	--puts object to list (with coordinates and a sprite)
	
	--title text
	add(title, {x=15, y=48, spr=33} ) --S
	add(title, {x=30, y=48, spr=35} ) --P
	add(title, {x=45, y=48, spr=37} ) --U
	add(title, {x=60, y=48, spr=39} ) --T
	add(title, {x=75, y=48, spr=41} ) --N
	add(title, {x=90, y=48, spr=43} ) --I
	add(title, {x=105, y=48, spr=45} ) --K
	
	--letter appearance speed
	titleAlarm = MakeAlarm(5, NextLetter)
	resetAlarm = MakeAlarm(-1, _init)
	
	--set up game here (initialize the global data)
	c = 0
	score = 0
	lives = 3
	player = NewObject(63,120,1,0,0)
	
	--create invaders
	invader = {}
	for i = 1,3 do
		local e = NewObject(flr(rnd(128)),-1* flr(rnd(128)),2,.8,270)
		add(invader, e)
	end
	
	--create asteroids
	asteroid = {}
	for i = 1,2 do
		local a = NewObject(flr(rnd(128)),-1* flr(rnd(128)),5,.8,270)
		add(asteroid, a)
	end
	
	--list of shots
	shots = {} 
	
	--list of stars
	stars = {} 
	ystars = {}
	
	--background stars
	--make 100 stars
	for i=0,100 do
		stars[i] = {}
		stars[i].x = flr(rnd(128))
		stars[i].y = flr(rnd(128))
		stars[i].s = 0
	end	
	
	--make 100 y stars
	for i=0,100 do
		ystars[i] = {}
		ystars[i].x = flr(rnd(128))
		ystars[i].y = flr(rnd(128))
		ystars[i].s = 4
	end	
	
	--explosions
	EXPLOSION_SPRITE = 8 --starting sprite number
	EXPLOSION_FRAMES = 5 --how many sprites in animation
	EXPLOSION_TICKS = 5 --how long to display each frame
	
	--list of explosions
	explosions = {}
	
end

function UpdateGame()
	--update the game here 
	UpdateExplosions()
	if gameOver == false then
		resetInvader()
		--player controls
		if btn(LEFT) and player.x > 4 then
			player.x-=1
		elseif btn(RIGHT) and player.x < 125 then
			player.x+=1
		end
		
		if btnp(UP) then
			sfx(0)
			--make a new shot
			local sh = NewObject(player.x - 4, player.y - 10, 3, 0,0)
			add(shots, sh) --puts shot in list
			CleanupShots()
		end
		
		--bullet direction
		for s in all (shots) do
			s.y -= 2
		end
		
		--if asteroid passes player, reset position
		for a in all (asteroid) do
			if a.y > 128  then
				a.x = flr(rnd(128))
				a.y = -8
			end
		end
		
		--invader movement
		for e in all (invader) do
			MoveObject(e)
			--invader collision
			if RectHit(player, e) then
				sfx(2)
				lives -= 1
				e.x = flr(rnd(128))
				e.y = -8
			end
			--bullet collision
			for s in all (shots) do
				if RectHit(s, e) then
					sfx(1)
					CreateExplosion(e.x,e.y)
					--removes invader and shot
					e.x = flr(rnd(128))
					e.y = -8
					del(shots, s)
					--add point
					score += 1
				end
			end
			--bullet to asteroid collision
			for a in all (asteroid) do
				for s in all (shots) do
					if RectHit(s, a) then
						sfx(6)
						CreateExplosion(a.x,a.y)
						del(shots, s)
						a.x = flr(rnd(128))
						a.y = -8
						score += 2
					elseif RectHit(player, a) then
						sfx(2)
						lives -= 1
						a.x = flr(rnd(128))
						a.y = -8
					end	
				end
			end	
		end
		
			--if score is greater then 50, obstacles speed up
			if score >= 50 then
				for e in all (invader) do
					e.speed = 1.2
				end
				for a in all (asteroid) do
					a.speed = 1.2
				end
			end
			
			--Show ship damage for every live lost
			if lives == 3 then
				player.sprite = 1
			elseif lives == 2 then
				player.sprite = 6
			elseif lives == 1 then
				player.sprite = 7
			end
			
	--move stars
		for i=0,100 do
			stars[i].y = stars[i].y + 1.5
			if stars[i].y >= 128 then
				stars[i].x = flr(rnd(128))
				stars[i].y = -8
			end
		end
	
	for i=0,100 do
		ystars[i].y = ystars[i].y + 1.5
		if ystars[i].y >= 128 then
			ystars[i].x = flr(rnd(128))
			ystars[i].y = -8
		end
	end
	
		--gameover when player loses all lives
		if lives == 0 then
			sfx(4)
			newScore = score
			gameOver = true
		end
	end
end

function UpdateTitle()
	UpdateAlarms()
	if btnp(BUTTON1) or btnp(BUTTON2) then
		sfx(5)
		gameState = PLAYING 
	end
end

function _update60()

	if gameState == TITLE then
		UpdateTitle()
	elseif gameState == PLAYING then
		UpdateGame()
	end
	
	--Back to title screen
	if gameOver == true then
		gameState = TITLE
		if btnp(BUTTON1) or btnp(BUTTON2) then
			sfx(5)
			gameState = PLAYING 
			ResetGame()
		end
	end
end

function CleanupShots()
	for s in all (shots) do
		if s.y > 127 then
			del(shots, s)
		end
	end
	
	--prevent bullet overload (so game does not slow down)
	if #shots > 100 then
		for s in all (shots) do
			del(shots, s)
		end
	end
end

function resetInvader()
	--invader respawn
	for e in all (invader) do
		if e.y > 128  then
			e.x = flr(rnd(128))
			e.y = -8
		end
	end
end

function _draw()
	if gameState == TITLE then
		DrawTitle()
	elseif gameState == PLAYING then
		DrawGame()
	end
end


function NextLetter()
	--shows title name one by one
	if index != #title then
		index += 1
		RestartAlarm(titleAlarm, 30)
	end
end

function DrawList()
	--display # of letters
	for i= 1,index do
		--draw 2x2 sprite
		spr(title[i].spr, title[i].x, title[i].y, 2, 2)
	end
end


function DrawTitle()
	cls()
	--draws previous score
	print("final score: " .. score, 0, 1, WHITE)
	--draws title screen
	DrawList(title)
	
	--draw subtitle
	if index == #title then
		print("by ethan nguyen", 35, 86, GREEN)
		print("press 🅾️ or ❎ to start", 20 ,100, GREEN)
	end
end



function DrawGame()
	--draw the game here
	cls(c)
	
	DrawExplosions()
	--draws stars
	for i=0,100 do
		spr(stars[i].s, stars[i].x, stars[i].y)
	end	
	
	--draws y stars
	for i=0,100 do
		spr(ystars[i].s, ystars[i].x, ystars[i].y)
	end	
	
	--draws score
	print("score: " .. score, 0, 1, WHITE)
	
	--draws lives
	print("lives: " .. lives, 85, 1, WHITE)
	
	--draws player
	DrawObject(player)
	
	--draw each shot
	for s in all (shots) do
		spr(3, s.x, s.y)
	end
	
	for e in all (invader) do
		e.Draw(e)
	end
	
	--draw asteroids
	if score >= 15 then
		for a in all (asteroid) do
			MoveObject(a)
			a.visible = true
		end
	elseif score <= 15 then
		for a in all (asteroid) do
			a.visible = false
		end
	end
	
	for a in all (asteroid) do
		a.Draw(a)
	end
	
	--if score is greater then 100, screen goes crazy
	if score >= 100 then
		c = c + 1
		if c == 16 then
			c = 0
		end
	end
	
	for e in all(explosions) do
		spr(e.sprite,e.x, e.y)
	end
end

function ResetGame()
	cls()
	player.x = 63
	player.y = 120
	score = 0
	lives = 3
	for e in all (invader) do
		e.x = flr(rnd(128))
		e.y = -8
	end
	
	for a in all (asteroid) do
		a.x = flr(rnd(128))
		a.y = -8
	end
	
	for s in all (shots) do
		del(shots,s)
	end
	
	gameOver = false
end