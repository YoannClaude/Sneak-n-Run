local bat = {}


local position = require "modules.position"

local currentLevel
local tutoWakeUp = false
local sfx = "event:/SFX/Ennemies/Bat/Wings"
local audioChannel = love.thread.getChannel("monoSfx")


local function check_holes(pBat)

    local currentTile = world_to_tile(pBat.pos)
    if check_tile_collision(layer.HOLES, currentTile) then
        pBat.state = eState.FALLING
    end

end


local function fall_in_whole(pBat, dt)

    pBat.sx = pBat.sx - 0.4 * dt
    pBat.sy = pBat.sy - 0.4 * dt

    if pBat.sx < 0 then
        pBat.isDead = true
        return
    end

end


local function update_colBox(pBat)

    pBat.colBox = pBat.pos - pBat.colBoxWidth/2
  
end


local function chase_player(pBat, dt)

    local previousPos = pBat.pos
    local dir = PLAYER_POS - pBat.pos
    pBat.facing = get_direction(dir, pBat.facing)
    pBat.target = normalize(dir)

    pBat.pace = pBat.pace + 500 * dt
    if pBat.pace > 200 then
        pBat.pace = 200
    end

    if distance(PLAYER_POS, pBat.pos) > 32 then
        pBat.pos = pBat.pos + pBat.target * pBat.pace * dt
        update_colBox(pBat)
    end
  
  end
  
  
local function check_state(pBat, dt)
  
    if pBat.state == eState.HIT then
        return
    elseif pBat.state == eState.KO then
        return
    elseif pBat.state == eState.STATIC then
        pBat.facing = pBat.dir
        return
    elseif pBat.state == eState.CHASE then
        chase_player(pBat, dt)
    elseif pBat.state == eState.FALLING then
        fall_in_whole(pBat, dt)
    end
  
end
  
  
local function set_anim(pBat)
  
    if pBat.currentState == pBat.state then
        return
    end
  
    pBat.currentState = pBat.state
  
    if pBat.state == eState.STATIC then
        pBat.anim = action.ATTACK
        return
    elseif pBat.state == eState.HIT then
        pBat.anim = action.STUNNED
        return
    elseif pBat.state == eState.KO then
        pBat.anim = action.STUNNED
        return
    elseif pBat.state == eState.CHASE then
        pBat.anim = action.MOVE
        return
    elseif pBat.state == eState.FALLING then
        pBat.anim = action.STUNNED
        return
    end
  
end
  
  
local function set_frames(pBat, dt)
  
    if pBat.state == eState.KO or pBat.state == eState.FALLING then
        return
    elseif pBat.state == eState.STATIC then
        pBat.frame = 4
        pBat.dir = dir.DOWN
        return
    end
  
    if pBat.currentAnim ~= pBat.anim then
        pBat.currentAnim = pBat.anim
        pBat.frame = 1
    end
  
    if pBat.state == eState.HIT then
        pBat.frame = pBat.frame + 7 * dt
        pBat.pace = 0
    elseif pBat.state == eState.CHASE then
        pBat.frame = pBat.frame + 9 * dt
    end
    if pBat.frame >= 5 then
        if pBat.state == eState.HIT then 
            pBat.frame = 4
            pBat.state = eState.KO
        else
        pBat.frame = 1
        end
    end
    
    if pBat.frame >= 3 and pBat.frame <= 4 and pBat.anim == action.MOVE then
        if not pBat.hasPlayedSound then
            local dist = math.floor(distance(pBat.pos, PLAYER_POS))
            audioChannel:push({obj = sType.BAT, event = sfx, param = dist})
            pBat.hasPlayedSound = true
        end
    else
        pBat.hasPlayedSound = false
    end
end
  

function bat.load(list, level)

    currentLevel = level
    bat.list = {}

    if level == levels.TUTORIAL then
        local newBat = list[#list]
        newBat.pos = newBat.initPos
        newBat.sx = 0.8
        newBat.sy = 0.8
        newBat.isDead = false
        newBat.sType = sType.BAT
        newBat.frame = 4
        newBat.dir = dir.DOWN
        newBat.facing = dir.DOWN
        newBat.anim = action.ATTACK
        newBat.currentAnim = newBat.anim
        newBat.state = eState.STATIC
        newBat.currentState = newBat.state
        newBat.lastDir = dir.DOWN
        newBat.pace = 0
        newBat.colBox = Vector2(0, 0)
        newBat.colBoxWidth = Vector2(50, 0)
        newBat.colBoxSize = 50
        newBat.lookDir = 0
        newBat.remove = false
        newBat.hasPlayedSound = false
  
        update_colBox(newBat)
        table.insert(bat.list, newBat)
        return bat.list

    else
        for i=1, #list do
            local newBat = list[i]
            newBat.pos = newBat.initPos
            newBat.sx = 0.8
            newBat.sy = 0.8
            newBat.isDead = false
            newBat.sType = sType.BAT
            newBat.frame = 4
            newBat.dir = dir.DOWN
            newBat.facing = dir.DOWN
            newBat.anim = action.ATTACK
            newBat.currentAnim = newBat.anim
            newBat.state = eState.STATIC
            newBat.currentState = newBat.state
            newBat.lastDir = dir.DOWN
            newBat.pace = 200
            newBat.colBox = Vector2(0, 0)
            newBat.colBoxWidth = Vector2(50, 0)
            newBat.colBoxSize = 50
            newBat.lookDir = 0
            newBat.remove = false
    
            update_colBox(newBat)
            table.insert(bat.list, newBat)
        end
        return bat.list
    end
end


function bat.update(dt)
  
    if currentLevel == levels.TUTORIAL then
        local b = bat.list[1]
        if is_on_screen(b.pos) and not tutoWakeUp then
            b.state = eState.CHASE
            tutoWakeUp = true
        end
    end
  
    for i=#bat.list, 1, -1 do
        local b = bat.list[i]
        if b.state == eState.KO and is_on_screen(b.pos)then
            check_holes(b)
        end
        check_state(b, dt)
        set_anim(b)
        set_frames(b, dt)
        if b.isDead then
            table.remove(bat.list, i)
            return
        end
    end
  
end



return bat
