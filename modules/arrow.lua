local  arrow = {}

local ennemies = require "modules.ennemies"

local sfx = {
    stone = "event:/SFX/Arrow/Stone",
    wood = "event:/SFX/Arrow/Wood",
    guard = "event:/SFX/Arrow/Guard",
    priest = "event:/SFX/Arrow/Priest",
    bat = "event:/SFX/Arrow/Bat"
}
local monoChannel = love.thread.getChannel("monoSfx")
local arrowSize = 64

local colMask = {layer.WALLS, layer.OBSTACLES, layer.EXTRA_COLLIDE}

local list = {}
local objectList = {}



function arrow.update_objects(list)

    objectList = list

end


function arrow.new(vecPos, angle, vecDir)

    local newArrow = {}
    newArrow.sType = sType.ARROW
    newArrow.pos = vecPos
    newArrow.origin = vecPos
    newArrow.timer = 45
    newArrow.angle = angle
    newArrow.dir = vecDir
    newArrow.collide = false
    newArrow.soundDraw = false
    newArrow.soundCol = false
    newArrow.radius = 200
    newArrow.hasPlayedSound = false
    newArrow.speed = love.math.random(1000, 1200)
    table.insert(list, newArrow)

end


local function check_sound_col(arrow)

  local ennemy
  local eList = ennemies.on_screen()
  if #eList > 0 then
    for i=1, #eList do
      ennemy = eList[i]
       if distance(arrow.pos, ennemy.pos) < arrow.radius then
        ennemies.hear_sound(arrow.pos, arrow.origin, ennemy)
      end
    end
  end

end


local function check_collisions(arrow)

    local dist = math.floor(distance(arrow.pos, PLAYER_POS))
    local ennemy
    local eList = ennemies.on_screen()
    if #eList > 0 then
        for i=1, #eList do
            ennemy = eList[i]
            if ennemy.state ~= eState.KO then
                if ennemy.sType ~= sType.BAT and
                        check_colPoint_to_colBox(arrow.pos.x + arrowSize/2, arrow.pos.y +                       arrowSize/2, ennemy.pos.x, ennemy.pos.y, QUADSIZE/2, QUADSIZE/2) then
                    if ennemy.sType == sType.GUARD then
                        monoChannel:push({obj = sType.ARROW, event = sfx.guard, param = dist})
                    else
                        monoChannel:push({obj = sType.ARROW, event = sfx.priest, param=dist})
                    end
                    ennemies.get_stunned(arrow.pos, arrow.origin, ennemy)
                    arrow.soundDraw = true
                    return true
                elseif ennemy.sType == sType.BAT and
                        check_colPoint_to_colBox(arrow.pos.x + arrowSize/2, arrow.pos.y +                        arrowSize/2, ennemy.pos.x + 15, ennemy.pos.y + 15,
                        QUADSIZE/4, QUADSIZE/4 + 15) then
                    monoChannel:push({obj = sType.ARROW, event = sfx.bat, param = dist})
                    ennemies.get_stunned(arrow.pos, arrow.origin, ennemy)
                    arrow.soundDraw = true
                return true
                end
            end
        end
    end
    local currentTileX, currentTileY
    for m = 1, #colMask do
        currentTile = world_to_tile(arrow.pos)
        if check_tile_collision(colMask[m],currentTile) then
            if m == layer.WALLS then
                monoChannel:push({obj = sType.ARROW, event = sfx.stone, param = dist})
            else
                monoChannel:push({obj = sType.ARROW, event = sfx.wood, param = dist})
            end
        arrow.soundDraw = true
        return true
        end
    end

    if #objectList == 0 then
        return false
    end

    for i=1, #objectList do
        local obj = objectList[i]
        if check_colPoint_to_colBox(arrow.pos.x, arrow.pos.y, obj.colBox[1], obj.colBox[2],                obj.colBox[3], obj.colBox[4]) then
            if obj.sType == sType.DOOR then
                if not obj.isOpen then
                    monoChannel:push({obj = sType.ARROW, event = sfx.stone, param = dist})
                    return true
                end
            elseif obj.sType == sType.HIDING_PLACE then
                monoChannel:push({obj = sType.ARROW, event = sfx.wood, param = dist})
            return true
            end
        end
    end
    
    return false

end


function arrow.load()

    list = {}

end


function arrow.update(dt)

    if #list < 1 then
        return
    end
    local arrow
    for i=#list, 1, -1 do
        arrow = list[i]
        arrow.timer = arrow.timer - 60 * dt
        if arrow.timer <= 0 then
            table.remove(list, i)
        else
            local currentPos = arrow.pos
            if not arrow.collide then
                arrow.pos = arrow.pos + arrow.dir * arrow.speed * dt
                arrow.collide = check_collisions(arrow)
                if arrow.collide then
                    check_sound_col(arrow)
                end
                arrow.speed = arrow.speed - 60 * dt
                if not is_on_screen(arrow.pos) then
                    table.remove(list, i)
                end
            else
                arrow.pos = currentPos
            end
        end
    end

end


function arrow.get_list()

    return list

end


function arrow.check_list()

    return #list

end


return arrow
