local vec2_meta = {
    __add = function (a, b)
        return Vector2(a.x + b.x, a.y + b.y)
    end,
    __sub = function (a, b)
        return Vector2(a.x - b.x, a.y - b.y)
    end,
    __mul = function (a, b)
        return Vector2(a.x * b, a.y * b)
    end,
    __div = function (a, b)
        return Vector2(a.x / b, a.y / b)
    end,
    __eq = function (a, b)
        return a.x == b.x and a.y == b.y
    end
}


function Vector2(x, y)

    local vec = {x = x or 0, y = y or 0}
    setmetatable(vec, vec2_meta)
    return vec

end


local camera = Vector2()


function normalize(vec)

    local l=(vec.x*vec.x+vec.y*vec.y)^.5
    if l==0 then
        return Vector2(0,0)
    else
        return Vector2(vec.x/l,vec.y/l)
    end

end


function easeInSin(t, b, c, d)

    return -c * math.cos(t/d * (math.pi/2)) + c + b

end


function easeOutSin(t, b, c, d)

    return c * math.sin(t/d * (math.pi/2)) + b

end


function easeInExpo(t, b, c, d)

	return c * math.pow( 2, 10 * (t/d - 1) ) + b

end


function easeOutExpo(t, b, c, d)

	return c * ( -math.pow( 2, -10 * t/d ) + 1 ) + b
  
end


function distance(vec1, vec2)

    return ((vec2.x-vec1.x)^2+(vec2.y-vec1.y)^2)^0.5

end


function round(n, deci)
    
    deci = 10^(deci or 0)
    return math.floor(n*deci+.5)/deci
    
end


function al_kachi(a,b,c)
    
    return math.deg(math.acos(((a^2+b^2-c^2)/(2*a*b))))
    
end


function triangle_collision(triangle, pos)
    
    local collide = false
    local dist_1 = distance(pos, triangle[1])
    local dist_2 = distance(pos, triangle[2])
    local dist_3 = distance(triangle[1], triangle[2]) 
    local a = al_kachi(dist_1, dist_2, dist_3)
    dist_1 = distance(pos, triangle[2])
    dist_2 = distance(pos, triangle[3])
    dist_3 = distance(triangle[2], triangle[3])
    local b = al_kachi(dist_1, dist_2, dist_3)
    dist_1 = distance(pos, triangle[1])
    dist_2 = distance(pos, triangle[3])
    dist_3 = distance(triangle[1], triangle[3])
    local c = al_kachi(dist_1, dist_2, dist_3)
    
    if a + b + c > 359 then
        collide = true
    end
    
    return collide
    
end


function world_to_tile(vec)

	return Vector2(math.ceil(vec.x / MINE.tilewidth), math.ceil(vec.y / MINE.tilewidth))

end


function tile_to_world(vec)

	return Vector2(math.floor(vec.x * MINE.tilewidth - MINE.tilewidth/2),
                   math.floor(vec.y * MINE.tilewidth - MINE.tilewidth/2))

end


function world_to_screen(vec)

    return Vector2(vec.x % SCREEN.WIDTH, vec.y % SCREEN.HEIGHT)

end


function get_closest_pos(pos, gPos)

    local tile = world_to_tile(pos)
    local tileIndex = MINE.layers[layer.GROUND].data[(tile.y-1)*MINE.width + tile.x]
    if tileIndex ~= 0 or tileIndex == nil then
        return tile
    end
    
    local closestPos

	--get adjacent tiles
	local closestTiles = {
            tile + Vector2(0, -1),
            tile + Vector2(0, 1),
            tile + Vector2(1, 0),
            tile + Vector2(-1, 0),
            tile + Vector2(1, 1),
            tile + Vector2(1, -1),
            tile + Vector2(-1, 1),
            tile + Vector2(-1, -1),
            tile + Vector2(-2, 0),
            tile + Vector2(-2, 1),
            tile + Vector2(-2, -1),
            tile +	Vector2(2, 0),
            tile + Vector2(2, 1),
            tile + Vector2(2, -1),
            tile + Vector2(0, -2),
            tile + Vector2(1, -2),
            tile + Vector2(-1, -2),
            tile + Vector2(0, 2),
            tile + Vector2(1, 2),
            tile + Vector2(-1, 2),
            tile + Vector2(-2, 2),
            tile + Vector2(-2, -2),
            tile + Vector2(2, 2),
            tile + Vector2(2, -2),
            tile + Vector2(3, 0),
            tile + Vector2(-3, 0),
            tile + Vector2(0, 3),
            tile + Vector2(0, -3),
            tile + Vector2(3, 3),
            tile + Vector2(3, -3),
            tile + Vector2(-3, 3),
            tile + Vector2(-3, -3)
    }

	--check if tiles are walkable

	for i = #closestTiles, 1, -1 do
        tileIndex = MINE.layers[layer.GROUND].data[((closestTiles[i].y)-1) *
                    MINE.width + closestTiles[i].x]
        if tileIndex == 0 or tileIndex == nil then
            table.remove(closestTiles, i)
        end
	end

    local tempDist = 1000
    for i = 1, #closestTiles do
        local iDist = distance(gPos, closestTiles[i])
        if iDist < tempDist then
            tempDist = iDist
            closestPos = closestTiles[i]
        end
    end
    
    if #closestTiles >= 1 then
        return closestPos
    else
        print("no closest pos")
    end

end


function check_tile_collision(layer, vec)

    local id = MINE.layers[layer].data[(vec.y-1) * MINE.width + vec.x]
    if id ~= 0 and id ~= nil then
        return true
    end
    return false

end


function check_colBox(x1,y1,w1,h1, x2,y2,w2,h2)

    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1

end


function check_colPoint_to_colBox(x1, y1, x2, y2, w2, h2)

    if x1 > x2 and x1 < x2 + w2 and y1 > y2 and y1 < y2 + h2 then
        return true
    end
    return false

end


function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end


function checkIntersect(l1p1, l1p2, l2p1, l2p2)

	local function checkDir(pt1, pt2, pt3)
        return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y)))
    end
    
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and
            (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))

end


function set_cameraPos(vec)

    camera = vec

end


function is_on_screen(vec)

    if vec.x > camera.x and vec.x < camera.x + SCREEN.WIDTH and
            vec.y > camera.y and vec.y < camera.y + SCREEN.HEIGHT then
        return true
    end
    return false

end


function get_direction(vec, lastDir)

	if math.abs(vec.y) > math.abs(vec.x) and vec.y >=0 then
		return dir.DOWN
	end
	if math.abs(vec.y) > math.abs(vec.x) and vec.y <=0 then
		return dir.UP
	end
	if math.abs(vec.x) > math.abs(vec.y) and vec.x<=0 then
		return dir.LEFT
	end
	if math.abs(vec.x) > math.abs(vec.y) and vec.x>=0 then
		return dir.RIGHT
	end
  return lastDir

end


function get_next_dir(d)

    if d == dir.DOWN then
        return dir.LEFT
    elseif d == dir.UP then
        return dir.RIGHT
    elseif d == dir.LEFT then
        return dir.UP
    elseif d == dir.RIGHT then
        return dir.DOWN
    end

end