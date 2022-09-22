--explosions.lua
--Creates a explosion at x0,y0
--Use this when you need a new explosion
function CreateExplosion(x0,y0)
	add( explosions, { x=x0,y=y0,sprite=EXPLOSION_SPRITE,ticks=0} )
end

--Call from _update()
function UpdateExplosions()
	for e in all (explosions) do
		--add one to tick counter
		e.ticks = e.ticks + 1
		--if ticks hits EXPLOSION_FRAMES
		--go to the next sprite
		--and set ticks back to 0
		if (e.ticks ==  EXPLOSION_TICKS) then
			e.sprite = e.sprite+1
			e.ticks = 0
		end
		
		if (e.sprite > EXPLOSION_SPRITE+EXPLOSION_FRAMES) then
			del(explosions, e)
		end
	end
		
end

function DrawExplosions()
	--Add this code to your _draw function
	for e in all(explosions) do
		spr(e.sprite,e.x, e.y)
	end
end
