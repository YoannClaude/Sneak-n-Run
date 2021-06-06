local guard = {}

                                      -------------------------------

local aStar = require "modules.aStar"

local speed = {WALK_SLOW = 50, WALK_FAST = 90, RUN = 170}
local sfx = {
    footsteps = "event:/SFX/Ennemies/Guard/Footsteps",
    attack = "event:/SFX/Ennemies/Guard/Attack"
    }
local monoChannel = love.thread.getChannel("monoSfx")
local stereoChannel = love.thread.getChannel("stereoSfx")


                                      ---------------------------------


local function update_colBox(pGuard)

    pGuard.colBox = pGuard.pos - pGuard.colBoxWidth/2

end


local function patrol(pGuard)

    pGuard.target = pGuard.patrolPath[pGuard.patrolIndex]
    if distance(pGuard.pos, pGuard.target) < 5 then
        if pGuard.patrolIndex < #pGuard.patrolPath then
            pGuard.patrolIndex = pGuard.patrolIndex + 1
        else
            pGuard.patrolIndex = 1
        end
    end

end


local function investigate(pGuard)
  
    local from, to

    from = world_to_tile(pGuard.pos)
    
    if pGuard.hasCheckedSource then
        to = get_closest_pos(pGuard.soundOrigin, from)
    else
        to = get_closest_pos(pGuard.soundSource, from)
    end

    if not pGuard.hasCalledPath then
        pGuard.path, pGuard.pathLength = aStar.get_path(from, to)
        pGuard.hasCalledPath = true
    end

    if pGuard.pathLength > 0 then
        pGuard.target = Vector2(pGuard.path[pGuard.pathIndex].x, pGuard.path[pGuard.pathIndex].y)
        pGuard.target = tile_to_world(pGuard.target)
    else
        pGuard.hasCheckedSource = true
        pGuard.hasCalledPath = false
        pGuard.target = pGuard.soundOrigin
    end

    if distance(pGuard.pos, pGuard.target) < 5 then
        if pGuard.pathIndex < #pGuard.path then
            pGuard.pathIndex = pGuard.pathIndex + 1
        else
            if not pGuard.hasCheckedSource then
                pGuard.hasCheckedSource = true
                pGuard.hasCalledPath = false
            else
                pGuard.state = eState.LOOK_AROUND
            end
        end
    end

end


local function go_back_home(pGuard)

    local from, to

    from = world_to_tile(pGuard.pos)

    if pGuard.isStatic then
        to = pGuard.staticPos
    else
        to = get_closest_pos(pGuard.patrolPath[pGuard.patrolIndex], from)
    end

    if not pGuard.hasCalledPath then
        pGuard.path, pGuard.pathLength  = aStar.get_path(from, to)
        pGuard.hasCalledPath = true
    end

    if pGuard.pathLength > 0 then
        pGuard.target = Vector2(pGuard.path[pGuard.pathIndex].x,
                                pGuard.path[pGuard.pathIndex].y)
        pGuard.target = tile_to_world(pGuard.target)
    else
        pGuard.target = pGuard.staticPos
    end

    if distance(pGuard.pos, pGuard.target) < 5 then
        if pGuard.pathIndex < #pGuard.path then
            pGuard.pathIndex = pGuard.pathIndex + 1
        else
            if pGuard.isStatic then
                pGuard.state = eState.STATIC
            else
                pGuard.state = eState.PATROL
            end
        end
    end

end


local function is_surprised(pGuard)

    if pGuard.nextState == eState.SUSPICIOUS then
        pGuard.target = pGuard.soundSource
    elseif pGuard.nextState == eState.CHASE then
        pGuard.target = PLAYER_POS
    end
    local dir = pGuard.target - pGuard.pos
    pGuard.facing = get_direction(dir, pGuard.facing)
    pGuard.pathIndex = 2
    pGuard.hasCalledPath = false

end


local function chase_player(pGuard)

    local from, to

    from = world_to_tile(pGuard.pos)
    to = get_closest_pos(PLAYER_POS, from)

    if not pGuard.hasCalledPath then
        pGuard.path, pGuard.pathLength = aStar.get_path(from, to)
        pGuard.hasCalledPath = true
    end

    if pGuard.pathLength > 0 then
        pGuard.previousPath = pGuard.path
        pGuard.pathIndex = 2
        pGuard.target = Vector2(pGuard.path[pGuard.pathIndex].x,
                                pGuard.path[pGuard.pathIndex].y)
        pGuard.target = tile_to_world(pGuard.target)
    else
        pGuard.target = PLAYER_POS
        pGuard.hasCalledPath = false
    end

    if distance(pGuard.pos, pGuard.target) < 5 then
        pGuard.hasCalledPath = false
    end

end


local function fall_in_trap(pGuard, dt)

    pGuard.sx = pGuard.sx - 0.4 * dt
    pGuard.sy = pGuard.sy - 0.4 * dt

    if pGuard.sx < 0 then
        pGuard.isDead = true
        return
    end

    if distance(pGuard.pos, pGuard.target) < 5 then
        pGuard.isFalling = true
    end

end


local function check_state(pGuard, dt)

    if  pGuard.state == eState.LOOK_AROUND or
        pGuard.state == eState.SLAY or
        pGuard.state == eState.HIT then
        return
    elseif pGuard.state == eState.STATIC then
        pGuard.facing = pGuard.dir
        return
    elseif pGuard.state == eState.PATROL then
        patrol(pGuard)
    elseif pGuard.state == eState.SUSPICIOUS then
        investigate(pGuard)
    elseif pGuard.state == eState.GETTING_CALM then
        go_back_home(pGuard)
    elseif pGuard.state == eState.SURPRISE then
        is_surprised(pGuard)
    elseif pGuard.state == eState.CHASE then
        chase_player(pGuard)
    elseif pGuard.state == eState.FALLING then
        fall_in_trap(pGuard, dt)
    end

end


local function set_movement(pGuard, dt)

    if  pGuard.state == eState.STATIC or
        pGuard.state == eState.HIT or
        pGuard.state == eState.LOOK_AROUND or
        pGuard.state == eState.SURPRISE or
        pGuard.state == eState.SLAY or 
        pGuard.isFalling then
        return
    end
    local dir = pGuard.target - pGuard.pos
    pGuard.facing = get_direction(dir, pGuard.facing)
    pGuard.target = normalize(dir)

    pGuard.pace = pGuard.pace + 500 * dt
    if pGuard.state == eState.PATROL or pGuard.state == eState.GETTING_CALM then
        if pGuard.pace > speed.WALK_SLOW * pGuard.speedFactor then
            pGuard.pace = speed.WALK_SLOW * pGuard.speedFactor
        end
    elseif pGuard.state == eState.SUSPICIOUS then
        if pGuard.pace > speed.WALK_FAST * pGuard.speedFactor then
            pGuard.pace = speed.WALK_FAST * pGuard.speedFactor
        end
    elseif pGuard.state == eState.CHASE or pGuard.state == eState.FALLING then
        if pGuard.pace > speed.RUN * pGuard.speedFactor then
            pGuard.pace = speed.RUN * pGuard.speedFactor
        end
    end

    pGuard.pos = pGuard.pos + pGuard.target * pGuard.pace * dt
    update_colBox(pGuard)

end


local function set_anim(pGuard)

    if pGuard.currentState == pGuard.state then
        return
    end

    pGuard.currentState = pGuard.state

    if pGuard.state == eState.STATIC then
        pGuard.anim = action.IDLE
        pGuard.pace = 0
        return
    elseif pGuard.state == eState.PATROL then
        pGuard.anim = action.MOVE
        return
    elseif pGuard.state == eState.SUSPICIOUS then
        pGuard.anim = action.MOVE
        return
    elseif pGuard.state == eState.CHASE then
        pGuard.anim = action.MOVE
        return
    elseif pGuard.state == eState.SURPRISE then
        pGuard.anim = action.IDLE
        pGuard.pace = 0
        return
    elseif pGuard.state == eState.LOOK_AROUND then
        pGuard.anim = action.IDLE
        pGuard.pace = 0
        return
    elseif pGuard.state == eState.GETTING_CALM then
        pGuard.anim = action.MOVE
        return
    elseif pGuard.state == eState.HIT then
        pGuard.anim = action.STUNNED
        pGuard.pace = 0
        return
    elseif pGuard.state == eState.SLAY then
        pGuard.anim = action.ATTACK
        pGuard.pace = 0
        return
    elseif pGuard.state == eState.FALLING then
        pGuard.anim = action.MOVE
        return
    end

end


local function set_frames(pGuard, dt)

    if pGuard.currentAnim ~= pGuard.anim then
        pGuard.currentAnim = pGuard.anim
        pGuard.frame = 1
    end

    if pGuard.state == eState.STATIC then
        pGuard.frame = pGuard.frame + 3 * dt
    elseif pGuard.state == eState.PATROL then
        pGuard.frame = pGuard.frame + 3 * dt
    elseif pGuard.state == eState.GETTING_CALM then
        pGuard.frame = pGuard.frame + 3 * dt
    elseif pGuard.state == eState.SUSPICIOUS then
        pGuard.frame = pGuard.frame + 6 * dt
    elseif pGuard.state == eState.CHASE then
        pGuard.frame = pGuard.frame + 9 * dt
    elseif pGuard.state == eState.SURPRISE then
        pGuard.frame = pGuard.frame + 3 * dt
    elseif pGuard.state == eState.LOOK_AROUND then
        pGuard.frame = pGuard.frame + 5 * dt
    elseif pGuard.state == eState.HIT then
        pGuard.frame = pGuard.frame + 7 * dt
    elseif pGuard.state == eState.SLAY then
        pGuard.frame = pGuard.frame + 8 * dt
    elseif pGuard.state == eState.FALLING then
        pGuard.frame = pGuard.frame + 27 * dt
    end
    if pGuard.frame >= 3 and pGuard.state == eState.SLAY then
        if not pGuard.hasKilled then
            stereoChannel:push(sfx.attack)
            pGuard.hasKilled = true
        end
    end
    if pGuard.frame >= 5 then
        pGuard.frame = 1
        if pGuard.state == eState.LOOK_AROUND then
            if pGuard.lookDir > 3 then
                pGuard.state = eState.GETTING_CALM
                pGuard.hasCalledPath = false
                pGuard.pathIndex = 2
                pGuard.lookDir = 0
            else
                pGuard.facing = get_next_dir(pGuard.facing)
                pGuard.lookDir = pGuard.lookDir + 1
            end
        elseif pGuard.state == eState.SURPRISE then
            pGuard.state = pGuard.nextState
        elseif pGuard.state == eState.HIT then
            if pGuard.previousState == eState.CHASE then
                pGuard.state = eState.CHASE
            else
                pGuard.state = eState.SURPRISE
                pGuard.nextState = eState.SUSPICIOUS
            end
        elseif pGuard.state == eState.SLAY then
            pGuard.frame = 4
        end
    end

    if pGuard.frame >= 3 and pGuard.frame <= 4 and pGuard.anim == action.MOVE then
        if not pGuard.hasPlayedSound then
            if pGuard.state == eState.PATROL then
                if is_on_screen(pGuard.pos) then
                    local dist = math.floor(distance(pGuard.pos, PLAYER_POS))
                    monoChannel:push({obj = sType.GUARD, event = sfx.footsteps, param = dist})
                    pGuard.hasPlayedSound = true
                end
            elseif pGuard.state ~= eState.FALLING then
                local dist = math.floor(distance(pGuard.pos, PLAYER_POS))
                local pan = pGuard.pos.x - PLAYER_POS.x
                monoChannel:push({obj = sType.GUARD, event = sfx.footsteps, param = dist})
                pGuard.hasPlayedSound = true
            end
        end 
    else
        pGuard.hasPlayedSound = false
    end

end


function guard.load(list, level)

    guard.list = {}
    
    if level == levels.TUTORIAL then
        return nil
    end
    
    aStar.load()
  
    for i=1, #list do
        local newGuard = list[i]
        newGuard.pos = newGuard.initPos
        newGuard.sx = 0.8
        newGuard.sy = 0.8
        newGuard.sType = sType.GUARD
        newGuard.frame = 1
        newGuard.facing = dir.DOWN
        newGuard.anim = action.IDLE
        newGuard.currentAnim = newGuard.anim
        newGuard.lastDir = dir.DOWN
        newGuard.target = Vector2()
        newGuard.patrolIndex = 2
        newGuard.state = eState.STATIC
        newGuard.currentState = newGuard.state
        newGuard.speedFactor = love.math.random(85, 115)/100
        newGuard.pace = speed.WALK_SLOW * newGuard.speedFactor
        newGuard.colBox = Vector2()
        newGuard.colBoxWidth = Vector2(50, 0)
        newGuard.colBoxSize = 50
        newGuard.lookDir = 0
        newGuard.soundSource = Vector2()
        newGuard.soundOrigin = Vector2()
        newGuard.isFalling = false
        newGuard.isDead = false
        newGuard.hasKilled = false
        newGuard.hasCheckedSource = false
        newGuard.hasCalledPath = false
        newGuard.remove = false
        newGuard.pathIndex = 2
        newGuard.pathLength = 0
        newGuard.path = Vector2()
        newGuard.staticPos = world_to_tile(newGuard.pos)
        newGuard.hasPlayedSound = false

        if not newGuard.isStatic then
            newGuard.state = eState.PATROL
        end

        newGuard.previousState = newGuard.state
        newGuard.nextState = newGuard.state

        update_colBox(newGuard)
        table.insert(guard.list, newGuard)
    end
    
    return guard.list

end


function guard.update(dt)

    for i=#guard.list, 1, -1 do
        local g = guard.list[i]
        check_state(g, dt)
        set_movement(g, dt)
        set_anim(g)
        set_frames(g, dt)
        if g.isDead then
            table.remove(guard.list, i)
            return
        end
    end

end

                                            ----------------------------

return guard
