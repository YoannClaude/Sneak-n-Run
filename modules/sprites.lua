local sprites = {}


local position = require "modules.position"
local ennemies = require "modules.ennemies"
local player = require "modules.player"
local arrows = require "modules.arrow"
local spells = require "modules.spell"
local objects = require "modules.objects"

local playerImg = love.graphics.newImage("assets/player/player.png")
local guardImg = love.graphics.newImage("assets/ennemies/guard.png")
local priestImg = love.graphics.newImage("assets/ennemies/priest.png")
local batImg = love.graphics.newImage("assets/ennemies/bat.png")
local arrowImg = love.graphics.newImage("assets/player/arrow.png")
local spellImg = love.graphics.newImage("assets/ennemies/spell.png")
local lightImg = love.graphics.newImage("assets/objects/light.png")
local doorImg = love.graphics.newImage("assets/objects/door.png")
local switchImg = love.graphics.newImage("assets/objects/switch.png")
local trapImg = love.graphics.newImage("assets/objects/trap.png")
local hidingPlaceClosedImg = love.graphics.newImage("assets/objects/hiding_place_closed.png")
local hidingPlaceOpenImg = love.graphics.newImage("assets/objects/hiding_place_open.png")

local arrowWidth, arrowHeight = arrowImg:getDimensions()
local spellWidth, spellHeight = spellImg:getDimensions()
local lightWidth, lightHeight = lightImg:getDimensions()
local imgWidth, imgHeight = playerImg:getDimensions()
local doorWidth, doorHeight = doorImg:getDimensions()
local trapWidth, trapHeight = trapImg:getDimensions()
local hidingPlaceOpenWidth, hidingPlaceOpenHeight = hidingPlaceOpenImg:getDimensions()
local hidingPlaceClosedWidth, hidingPlaceClosedHeight = hidingPlaceClosedImg:getDimensions()
local switchWidth, switchHeight = switchImg:getDimensions()

local fogCanvas = love.graphics.newCanvas()

local arrowQuad
local anim = {}
local fList = {}
local lList = {}
local oList = {}
local isCheckingSound = false
local alphaLight = 0.3
local vel = 0.3
local switchQuadWidth, switchQuadHeight = switchWidth, switchHeight/3
local switchFrames = {}
switchFrames[1] = love.graphics.newQuad(0, 0, switchQuadWidth, switchQuadHeight, switchWidth, switchHeight)
switchFrames[2] = love.graphics.newQuad(0, switchHeight/3, switchQuadWidth, switchQuadHeight, switchWidth, switchHeight)
switchFrames[3] = love.graphics.newQuad(0, switchHeight/3*2, switchQuadWidth, switchQuadHeight, switchWidth, switchHeight)

local images = {}
images[sType.PLAYER] = playerImg
images[sType.GUARD] = guardImg
images[sType.PRIEST] = priestImg
images[sType.SPELL] = spellImg
images[sType.BAT] = batImg
images[sType.SWITCH] = switchImg


local function y_sort(pList)

    local yList = pList
    local buffer
    local n = 1
    for z=1, #yList - 1 do
        for i=1, #yList - n do
            if yList[i].pos.y > yList[i+1].pos.y then
                buffer = yList[i+1]
                yList[i+1] = yList[i]
                yList[i] = buffer
            end
        end
        n = n + 1
    end
    return yList

end


function sprites.set_soundCheck(bool)

    isCheckingSound = bool

end


function sprites.update_objects()

    lList = objects.get_light_on_screen()
    oList = objects.get_objects_on_screen()
    player.update_objects(oList)
    arrows.update_objects(oList)

end


local function fireball(vec)

    local fb = {}
    fb.pos = Vector2(vec.x, vec.y)
    fb.vel = Vector2(love.math.random(-20, 20), love.math.random(-20, 0))
    fb.alpha = love.math.random()
    fb.r = love.math.random(2, 10)
    fb.red = love.math.random(0.5, 1)
    table.insert(fList, fb)

end


function sprites.load(level)

    sList = {}
    fList = {}
    objects.load()
    sprites.update_objects()

    for block=1, 4 do
        anim[block]={}
        for row=1, 4 do
            anim[block][row]={}
            for column=1, 4 do
                anim[block][row][column] = love.graphics.newQuad((column-1)*QUADSIZE,
                (row-1)*QUADSIZE + (block-1)*4*QUADSIZE, QUADSIZE, QUADSIZE, imgWidth, imgHeight)
            end
        end
    end
    arrowQuad = love.graphics.newQuad(0, 0, arrowWidth/2 + 10, arrowHeight, arrowWidth, arrowHeight)

end


function sprites.update(state, dt)

    sList = spells.get_list()

    if #sList > 0 then
        for i = 1, #sList do
            for l = 1, 10 do
                fireball(sList[i].pos)
            end
        end
    end
    local p
    for i = #fList, 1, -1 do
        p = fList[i]
        p.pos = p.pos + p.vel * dt
        p.alpha = p.alpha - 2 * dt
        if fList[i].alpha <= 0 then
            table.remove(fList, i)
        end
    end

    if state == gState.ACTIVE then
        if alphaLight >=  0.6 or alphaLight <= 0.2 then
            vel = -vel
        end
        alphaLight = alphaLight + vel * dt
    end

end


function sprites.draw()
  
    local list = ennemies.on_screen()
    table.insert(list, player)
    for i = 1, #oList do
        local sprite = oList[i]
        if oList[i].sType == sType.TRAP then
            if not sprite.isOpen then
                love.graphics.draw(trapImg, sprite.pos.x, sprite.pos.y, 0, 1, 1, trapWidth/2, trapWidth/2)
            end
        elseif sprite.sType == sType.DOOR then
            if not sprite.isOpen then
                if sprite.facing == "up" then
                    love.graphics.draw(doorImg, sprite.pos.x, sprite.pos.y - 5, math.rad(180), 2, 1, doorWidth/2, doorHeight/2)
                elseif sprite.facing == "right" then
                    love.graphics.draw(doorImg, sprite.pos.x + 5, sprite.pos.y, math.rad(-90), 2, 1, doorWidth/2, doorHeight/2)
                elseif sprite.facing == "down" then
                    love.graphics.draw(doorImg, sprite.pos.x, sprite.pos.y + 5, 0, 2, 1, doorWidth/2, doorHeight/2)
                end
            end
        elseif sprite.sType == sType.SWITCH then
            table.insert(list, sprite)
        end
    end
    local aList = arrows.get_list()
    for i = 1, #aList do
        table.insert(list, aList[i])
    end
    list = y_sort(list)
    for i=1, #list do
        local sprite = list[i]
        if sprite.sType == sType.ARROW then
            if sprite.collide then
                love.graphics.draw(arrowImg, arrowQuad, sprite.pos.x, sprite.pos.y, sprite.angle, 1, 1, arrowWidth/2, arrowHeight/2)
            else
                love.graphics.draw(arrowImg, sprite.pos.x, sprite.pos.y, sprite.angle, 1, 1, arrowWidth/2, arrowHeight/2)
            end
        elseif sprite.sType == sType.SPELL then
            love.graphics.draw(spellImg, sprite.pos.x, sprite.pos.y, 0, 0.7, 0.7, spellWidth/2, spellHeight/2)
        elseif sprite.sType == sType.SWITCH then
            if sprite.currentFrame == 1 then
                love.graphics.draw(switchImg, switchFrames[1], sprite.pos.x, sprite.pos.y, 0, 1, 1, switchQuadWidth/2, switchQuadHeight-10)
            elseif sprite.currentFrame == 2 then
                love.graphics.draw(switchImg, switchFrames[2], sprite.pos.x, sprite.pos.y, 0, 1, 1, switchQuadWidth/2, switchQuadHeight-10)
            elseif sprite.currentFrame == 3 then
                love.graphics.draw(switchImg, switchFrames[3], sprite.pos.x, sprite.pos.y, 0, 1, 1, switchQuadWidth/2, switchQuadHeight-10)
            end
        else
            local frame = math.floor(sprite.frame)
            if sprite.sType == sType.PRIEST then
                love.graphics.draw(images[sprite.sType], anim[sprite.facing][sprite.anim][frame], sprite.pos.x, sprite.pos.y, 0, 1, 1, QUADSIZE/2 * 1.2, QUADSIZE/2 * 1.2)
            elseif sprite.sType == sType.PLAYER and sprite.isVisible then
                love.graphics.draw(images[sprite.sType], anim[sprite.facing][sprite.anim][frame], sprite.pos.x, sprite.pos.y, 0, 0.8, 0.8, QUADSIZE/2, QUADSIZE/2)
            elseif sprite.sType == sType.GUARD then
                love.graphics.draw(images[sprite.sType], anim[sprite.facing][sprite.anim][frame], sprite.pos.x, sprite.pos.y, 0, sprite.sx, sprite.sy, QUADSIZE/2, QUADSIZE/2)
            elseif sprite.sType == sType.BAT then
                love.graphics.draw(images[sprite.sType], anim[sprite.facing][sprite.anim][frame], sprite.pos.x, sprite.pos.y, 0, sprite.sx, sprite.sy, QUADSIZE/2, QUADSIZE/2)
            end
        end
        if sprite.isAiming then
            love.graphics.setColor(0, 0, 0, 0.25)
            love.graphics.draw(arrowImg, sprite.pos.x, sprite.pos.y, sprite.joyAngle, 2.5, 2.5, arrowWidth/2, arrowHeight/2)
            love.graphics.setColor(1, 1, 1, 1)
        end
        for i = 1, #fList do
            love.graphics.setColor(fList[i].red, 0.2, 0.2, fList[i].alpha)
            love.graphics.circle("fill", fList[i].pos.x, fList[i].pos.y, fList[i].r)
            if isCheckingSound then
                love.graphics.setColor(1, 1, 1, 0.5)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end
    for i = 1, #oList do
        local sprite = oList[i]
        if sprite.sType == sType.HIDING_PLACE then
            if sprite.isOpen then
                love.graphics.draw(hidingPlaceOpenImg, sprite.pos.x, sprite.pos.y, 0, 1, 1, hidingPlaceOpenWidth/2, hidingPlaceOpenHeight/2 + hidingPlaceClosedHeight/2)
            else
                love.graphics.draw(hidingPlaceClosedImg, sprite.pos.x, sprite.pos.y, 0, 1, 1, hidingPlaceClosedWidth/2, hidingPlaceClosedHeight/2)
            end
        end
    end
end


function sprites.draw_lights(state)

    for i = 1, #lList do
        if state == gState.SUSPICIOUS then
            love.graphics.setColor(0.7, 0.5, 0, 0.4)
            love.graphics.draw(lightImg, lList[i].pos.x, lList[i].pos.y, 0, 0.5, 0.5, lightWidth/2, lightHeight/2)
        elseif state == gState.ACTIVE then
            love.graphics.setColor(0.7, 0, 0, alphaLight)
            love.graphics.draw(lightImg, lList[i].pos.x, lList[i].pos.y, 0, 0.5, 0.5, lightWidth/2, lightHeight/2)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

end


function sprites.draw_shapes()
  
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)

    love.graphics.circle("line", player.pos.x, player.pos.y, player.sound)

    local sprite
    local list = arrows.get_list()
    for i=1, #list do
        sprite = list[i]
        if sprite.soundDraw then
            love.graphics.circle("line", sprite.pos.x, sprite.pos.y, sprite.radius)
        end
    end


    for i=1, #oList do
        sprite = oList[i]
        if sprite.sType == sType.SWITCH and sprite.soundDraw then
            love.graphics.circle("line", sprite.pos.x, sprite.pos.y, sprite.radius)
        end
    end


    list = ennemies.on_screen()
    for i=1, #list do
        sprite = list[i]
        if sprite.sType ~= sType.BAT and
            sprite.state ~= eState.HIT and
            sprite.state ~= eState.KO then
            local vertices = ennemies.get_vision_points(sprite)
            love.graphics.polygon('fill', vertices[1].x, vertices[1].y,
            vertices[2].x, vertices[2].y, vertices[3].x, vertices[3].y, vertices[4].x, vertices[4].y, vertices[5].x, vertices[5].y)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

end


function sprites.draw_fog()

    love.graphics.setCanvas(fogCanvas)
    love.graphics.clear()
    local playerPos = world_to_screen(PLAYER_POS)
    local alpha
    for l=0, SCREEN.HEIGHT/4 -1 do
        for c=0, SCREEN.WIDTH/4 -1 do
            alpha = distance(Vector2(c * 4, l * 4), playerPos)
            alpha = alpha/500
            love.graphics.setColor(0, 0, 0, alpha)
            love.graphics.rectangle("fill", c * 4, l * 4, 4, 4)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    love.graphics.setCanvas()
    love.graphics.draw(fogCanvas)
end


return sprites
