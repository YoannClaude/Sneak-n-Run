local player = {}

local ennemies = require "modules.ennemies"
local arrow = require "modules.arrow"
local spell = require "modules.spell"
local position = require "modules.position"
local objects = require "modules.objects"

local speed = {SNEAK = 70, WALK = 150, RUN = 320}
local arrowDir
local state = pState.STATIC
local currentState = state
local currentAnim = action.IDLE
local colBox = {}
local visionBox = {}
local colMask = {layer.WALLS, layer.OBSTACLES, layer.HOLES, layer.EXTRA_COLLIDE}
local pace = 0
local radius = {SNEAK = 0, WALK = 100, RUN = 150, WALK_LOUD = 150, RUN_LOUD = 200}
local isDead = false
local colBoxWidth = Vector2(40, 0)
local colBoxHeight = Vector2(0, 40)
local visionBoxWidth = colBoxWidth
local visionBoxHeight = Vector2(0, 30)
local eList = {}
local spList = {}
local objectList = {}
local isNoisy = false
local hasPlayedSound = false
local pointList = {}
local sfx = {
    shoot = "event:/SFX/Player/Shoot"
}
local stereoChannel = love.thread.getChannel("stereoSfx")
local playerChannel = love.thread.getChannel("player")
local loPassChannel = love.thread.getChannel("loPass")


local function update_colBox()

    colBox[1] = player.pos - colBoxWidth/2
    colBox[2] = colBox[1] + colBoxWidth
    colBox[3] = colBox[2] + colBoxHeight
    colBox[4] = colBox[3] - colBoxWidth

    visionBox[1] = player.pos - visionBoxWidth/2 - visionBoxHeight
    visionBox[2] = visionBox[1] + visionBoxWidth
    visionBox[3] = visionBox[2] + visionBoxHeight * 2 + Vector2(0, 10)
    visionBox[4] = visionBox[3] - visionBoxWidth

end

    
local function check_vCollisions()
  --collisions with ennemies vision cones
    for i=1, #eList do
        local e = eList[i]
        local triangles = ennemies.get_vision_triangles(e)
        for t = 1, #triangles do
            for vB = 1, #visionBox do
                if triangle_collision(triangles[t], visionBox[vB]) then
                    ennemies.see_player(e, player.pos)
                    return
                end
            end
        end
    end

end


local function check_sCollision()
  --collisions when making sound
    for i=1, #eList do
    local ennemy = eList[i]
        if distance(player.pos, ennemy.pos) < player.sound then
            ennemies.hear_sound(player.pos, player.pos, ennemy)
        end
    end

end


local function check_eCollision()
  --collisions with ennemies
    local collide = false
    for i=1, #eList do
        local ennemy = eList[i]
        if check_colBox(colBox[1].x, colBox[1].y, colBoxWidth.x, colBoxHeight.y,               ennemy.colBox.x, ennemy.colBox.y, ennemy.colBoxSize, ennemy.colBoxSize) then
            if ennemy.sType == sType.GUARD then
                local gDir = player.pos - ennemy.pos
                ennemy.facing = get_direction(gDir)
                ennemy.target = Vector2()
                ennemy.state = eState.SLAY
                state = pState.CAUGHT
                collide = true
            elseif ennemy.sType == sType.BAT and ennemy.state ~= eState.KO and
                    ennemy.state ~= eState.HIT then
                state = pState.STATIC
                collide =  true
            end
        end
    end
    
    return collide

end


local function check_spellCol()

    for i = 1, #spList do
        local spell = spList[i]
        if check_colBox(colBox[1].x, colBox[1].y, colBoxWidth.x, colBoxHeight.y,                spell.colBox.x, spell.colBox.y, spell.colBoxSize, spell.colBoxSize) then
            spell.collide = true
            if state ~= pState.CAUGHT and state ~= pState.DEAD then
                state = pState.HIT
            end
        end
    end

end


local function check_tCollision()
  --collisions with tiles
    for m=1,#colMask do
        for i=1, #colBox do
            local currentTile = world_to_tile(colBox[i])
            if check_tile_collision(colMask[m],currentTile) then
                return true
            end
        end
    end

  --collisions with objects
    if #objectList == 0 then
        return false
    end

    for i=1, #objectList do
        local obj = objectList[i]
        if check_colBox(colBox[1].x, colBox[1].y, colBoxWidth.x, colBoxHeight.y,
                obj.colBox[1], obj.colBox[2], obj.colBox[3], obj.colBox[4]) then
            if obj.sType == sType.DOOR then
                if not obj.isOpen then
                    return true
                end
            elseif obj.sType == sType.TRAP then
                if obj.isOpen then
                    return true
                end
            else
                return true
            end
        end
    end

    return false

end


local function check_sound_area()
    
    local collide = false
    for i=1, #colBox do
        local currentTile = world_to_tile(colBox[i])
        if check_tile_collision(layer.SOUND_AREA, currentTile) then
            collide = true
            break
        end
    end
    
    return collide
    
  end



local function set_movement(dt)

    if #spList > 0 then
        check_spellCol()
    end

    if state == pState.HIT or state == pState.DEAD then
        return
    end

    if state == pState.SHOOTING then
        player.facing = arrowDir
        return
    end

    local vel = Vector2()
    local previousPos = player.pos

    if GAMEPAD ~= nil then
        local xvalueL = GAMEPAD:getGamepadAxis("leftx")
        local yvalueL = GAMEPAD:getGamepadAxis("lefty")
        local xvalueR = GAMEPAD:getGamepadAxis("rightx")
        local yvalueR = GAMEPAD:getGamepadAxis("righty")
        local lvalue = GAMEPAD:getGamepadAxis("triggerleft")
        local rvalue = GAMEPAD:getGamepadAxis("triggerright")
        if xvalueL > 0.25 or xvalueL < -0.25 then
            vel = vel + Vector2(xvalueL, 0)
            player.facing = get_direction(Vector2(xvalueL, yvalueL, dir.DOWN))
        end
        if yvalueL > 0.25 or yvalueL < -0.25 then
            vel = vel + Vector2(0, yvalueL)
            player.facing = get_direction(Vector2(xvalueL, yvalueL, dir.DOWN))
        end
        if GAMEPAD:isGamepadDown('dpleft') then
            vel = vel + Vector2(-1, 0)
            player.facing = dir.LEFT
        end
        if GAMEPAD:isGamepadDown('dpright') then
            vel = vel + Vector2(1, 0)
            player.facing = dir.RIGHT
        end
        if GAMEPAD:isGamepadDown('dpup') then
            vel = vel + Vector2(0, -1)
            player.facing = dir.UP
        end
        if GAMEPAD:isGamepadDown('dpdown') then
            vel = vel + Vector2(0, 1)
            player.facing = dir.DOWN
        end
        if rvalue > 0.5 then
            state = pState.RUNNING
            if isNoisy then
                player.sound = radius.RUN_LOUD
            else
                player.sound = radius.RUN
            end
        elseif lvalue > 0.5 then
            state = pState.SNEAKING
            player.sound = radius.SNEAK
        else
            state = pState.WALKING
            if isNoisy then
                player.sound = radius.WALK_LOUD
            else
                player.sound = radius.WALK
            end
        end
        if  xvalueR > 0.25 or
                xvalueR < -0.25 or
                yvalueR > 0.25 or
                yvalueR < -0.25 then
            player.isAiming = true
            player.joyAngle = math.atan2(yvalueR, xvalueR)
        else
            player.isAiming = false
            player.joyAngle = 0
        end
    else
        if love.keyboard.isDown('q') or love.keyboard.isDown('a') then
            vel = vel + Vector2(-1, 0)
            player.facing = dir.LEFT
        end
        if love.keyboard.isDown('d') then
            vel = vel + Vector2(1, 0)
            player.facing = dir.RIGHT
        end
        if love.keyboard.isDown('z') or love.keyboard.isDown('w') then
            vel = vel + Vector2(0, -1)
            player.facing = dir.UP
        end
        if love.keyboard.isDown('s') then
            vel = vel + Vector2(0, 1)
            player.facing = dir.DOWN
        end
        if love.keyboard.isDown("space") then
            state = pState.RUNNING
            if isNoisy then
                player.sound = radius.RUN_LOUD
            else
                player.sound = radius.RUN
            end
        elseif love.keyboard.isDown("lshift") then
            state = pState.SNEAKING
            player.sound = radius.SNEAK
        else
            state = pState.WALKING
            if isNoisy then
                player.sound = radius.WALK_LOUD
            else
                player.sound = radius.WALK
            end
        end
    end

    if vel == Vector2() then
        state = pState.STATIC
        player.sound = 0
        pace = 0
    else
        pace = pace + 500 * dt
        if state == pState.SNEAKING then
            if pace > speed.SNEAK then
                pace = speed.SNEAK
            end
        elseif state == pState.WALKING then
            if pace > speed.WALK then
                pace = speed.WALK
            end
        elseif state == pState.RUNNING then
            if pace > speed.RUN then
                pace = speed.RUN
            end
        end
        vel = normalize(vel)
        player.pos = player.pos + vel * pace * dt
    end

    if #eList > 0 and player.sound ~= radius.SNEAK then
        check_sCollision()
    end

    update_colBox()

    local collide = check_tCollision()
    if collide and state ~= pState.DEAD then
        player.pos = previousPos
        state = pState.STATIC
    end

    if #eList > 0 then
        collide = check_eCollision()
        if collide and state ~= pState.DEAD then
            player.pos = previousPos
            state = pState.STATIC
        end
    end
    
end


local function set_anim()

    if currentState == state then
        return
    end

    currentState = state


    if state == pState.STATIC then
        player.anim = action.IDLE
        return
    elseif state == pState.WALKING then
        player.anim = action.MOVE
        return
    elseif state == pState.SNEAKING then
        player.anim = action.MOVE
        return
    elseif state == pState.RUNNING then
        player.anim = action.MOVE
        return
    elseif state == pState.HIT then
        player.anim = action.STUNNED
        return
    elseif state == pState.SHOOTING then
        player.anim = action.ATTACK
        return
    elseif state == pState.CAUGHT then
        player.anim = action.IDLE
        return
    elseif state == pState.DEAD then
        player.anim = action.STUNNED
        return
    end

end


local function set_frames(dt)
  --set frames

    if currentAnim ~= player.anim then
        currentAnim = player.anim
        player.frame = 1
    end

    if state == pState.STATIC then
        player.frame = player.frame + 3 * dt
    elseif state == pState.WALKING then
        player.frame = player.frame + 6 * dt
    elseif state == pState.RUNNING then
        player.frame = player.frame + 9 * dt
    elseif state == pState.SNEAKING then
        player.frame = player.frame + 4 * dt
    elseif state == pState.SHOOTING then
        player.frame = player.frame + 8 * dt
    elseif state == pState.HIT then
        player.frame = player.frame + 9 * dt
    elseif state == pState.CAUGHT then
        player.frame = player.frame + 5 * dt
    elseif state == pState.DEAD then
        player.frame = player.frame + 9 * dt
    end

    if player.frame >= 5 then
        player.frame = 1
        if state == pState.SHOOTING then
            player.anim = action.IDLE
            state = pState.STATIC
        elseif state == pState.HIT then
            state = pState.STATIC
            player.anim = action.IDLE
        elseif state == pState.DEAD then
            player.frame = 4
        isDead = true
        end
    end

    if player.frame >= 3 and player.frame <= 4 and player.anim == action.MOVE then
        if not hasPlayedSound then
            playerChannel:push({action = state, loud = isNoisy})
            hasPlayedSound = true
        end
    else 
        hasPlayedSound = false
    end

end



function player.shoot(x, y)

    if state == pState.SHOOTING then
        return
    end

    stereoChannel:push(sfx.shoot)
    local dir = Vector2()

    if GAMEPAD ~= nil then
        if player.isAiming then
            dir.x = x
            dir.y = y
            state = pState.SHOOTING
            arrowDir = get_direction(dir)
            local angle = math.atan2(dir.y, dir.x)
            dir = normalize(dir)
            arrow.new(player.pos, angle, dir)
        end
    else
        dir.x = x - (player.pos.x % SCREEN.WIDTH)
        dir.y = y - (player.pos.y % SCREEN.HEIGHT)
        state = pState.SHOOTING
        arrowDir = get_direction(dir)
        local angle = math.atan2(dir.y, dir.x)
        dir = normalize(dir)
        arrow.new(player.pos, angle, dir)
    end

    pace = 0

end


function player.on_hit()

    state = pState.HIT

end


function player.action()

    if #objectList == 0 then
        return
    end

    for i=1, #objectList do
        local obj = objectList[i]
        if obj.sType == sType.SWITCH then
            if distance(player.pos, obj.pos) < 75 then
                objects.toggle_switch(obj)
            end
        elseif obj.sType == sType.HIDING_PLACE then
            if distance(player.pos, obj.pos) < 75 then
                if player.isVisible then
                    player.isVisible = false
                    obj.isOpen = false
                    ennemies.lost_player()
                    loPassChannel:push({value = true})
                else
                    player.isVisible = true
                    obj.isOpen = true
                    loPassChannel:push({value = false})
                end
            end
        end
    end

end


function player.game_over()

    state = pState.DEAD

end


function player.get_visionBox()

    return visionBox

end


function player.update_objects(list)

    objectList = list

end


function player.check_death()

    return isDead

end


function player.load(level, checkpoint, restart)

    pointList = position.get_player_list()
    arrow.load()
  
    if restart then checkpoint = 0 end
  
    if level == levels.TUTORIAL then
        player.pos = pointList.tutorial
    elseif level == levels.MINE then
        if checkpoint == 1 then
            player.pos = pointList.checkpoint[1]
        elseif checkpoint == 2 then
            player.pos = pointList.checkpoint[2]
        elseif checkpoint == 3 then
            player.pos = pointList.checkpoint[3]
        else
            player.pos = pointList.game
        end
    end

    isDead = false
    player.sType = sType.PLAYER
    player.frame = 1
    player.isVisible = true
    state = pState.STATIC
    player.anim = action.IDLE
    player.facing = dir.DOWN
    player.sound = radius.WALK
    player.isAiming = false

    --set collision boxes
    for i=1, 4 do
        colBox[i] = Vector2(0, 0)
    end
    for i=1, 4 do
        visionBox[i] = {}
        for i2=1, 2 do
            visionBox[i][i2] = {}
        end
    end
    update_colBox()
  
    PLAYER_POS = player.pos
  
end


function player.update(dt)

    if not player.isVisible then
        return
    end

    eList = ennemies.on_screen()
    spList = spell.get_list()

    if #eList > 0 then
        check_vCollisions()
    end
    
    isNoisy = check_sound_area()

    set_movement(dt)
    set_anim()
    set_frames(dt)

    PLAYER_POS = player.pos
  
    arrow.update(dt)


end



return player
