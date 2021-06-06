local priest = {}


local spell = require "modules.spell"
local position = require "modules.position"


local function update_colBox(pPriest)

    pPriest.colBox = pPriest.pos - pPriest.colBoxWidth/2

end


local function set_dir(pPriest)

    local dir = PLAYER_POS - pPriest.pos
    pPriest.facing = get_direction(dir, pPriest.facing)

end


local function check_state(pPriest)

    if pPriest.state == eState.HIT then
        return
    elseif pPriest.state == eState.KO then
        return
    elseif pPriest.state == eState.TURNING then
        return
    elseif pPriest.state == eState.STATIC then
        pPriest.facing = pPriest.dir
        return
    end

    set_dir(pPriest)

end


local function set_anim(pPriest)

    if pPriest.currentState == pPriest.state then
        return
    end

    pPriest.currentState = pPriest.state

    if pPriest.state == eState.STATIC then
        pPriest.anim = action.IDLE
        return
    elseif pPriest.state == eState.SURPRISE then
        pPriest.anim = action.IDLE
        return
    elseif pPriest.state == eState.TURNING then
        pPriest.anim = action.IDLE
        return
    elseif pPriest.state == eState.HIT then
        pPriest.anim = action.STUNNED
        return
    elseif pPriest.state == eState.KO then
        pPriest.anim = action.STUNNED
        return
    elseif pPriest.state == eState.CHASE then
        pPriest.anim = action.ATTACK
        return
    end

end


local function set_frames(pPriest, dt)

    if pPriest.state == eState.KO then
        return
    end

    if pPriest.currentAnim ~= pPriest.anim then
        pPriest.currentAnim = pPriest.anim
        pPriest.frame = 1
    end

    if pPriest.state == eState.STATIC then
        pPriest.frame = pPriest.frame + 3 * dt
    elseif pPriest.state == eState.SURPRISE then
        pPriest.frame = pPriest.frame + 3 * dt
    elseif pPriest.state == eState.TURNING then
        pPriest.frame = pPriest.frame + 3 * dt
    elseif pPriest.state == eState.HIT then
        pPriest.frame = pPriest.frame + 7 * dt
    elseif pPriest.state == eState.CHASE then
        pPriest.frame = pPriest.frame + 2 * dt
    end
    if pPriest.frame >= 5 then
        pPriest.canCast = true
        pPriest.frame = 1
        if pPriest.state == eState.TURNING then
            pPriest.facing = get_next_dir(pPriest.facing)
        elseif pPriest.state == eState.SURPRISE then
            pPriest.state = eState.CHASE
        elseif pPriest.state == eState.HIT then 
            pPriest.frame = 4
            pPriest.state = eState.KO
        end
    end
    if pPriest.frame >= 3 and pPriest.state == eState.CHASE and pPriest.canCast then
        spell.new(pPriest.pos)
        pPriest.canCast = false
    end
    
end


function priest.load(list, level)
  
    spell.load()

    priest.list = {}
    
    if level == levels.TUTORIAL then
        return nil
    end
    
    for i=1, #list do
        local newPriest = list[i]
        newPriest.sType = sType.PRIEST
        newPriest.frame = 1
        newPriest.facing = newPriest.dir
        newPriest.anim = action.IDLE
        newPriest.currentAnim = newPriest.anim
        newPriest.state = eState.STATIC
        newPriest.lastDir = dir.DOWN
        newPriest.colBox = Vector2(0, 0)
        newPriest.colBoxWidth = Vector2(50, 0)
        newPriest.colBoxSize = 50
        newPriest.lookDir = 0
        newPriest.soundSource = {}
        newPriest.soundOrigin = {}
        newPriest.remove = false
        newPriest.canCast = true

        if newPriest.isStatic then
            newPriest.state = eState.STATIC
        else
            newPriest.state = eState.TURNING
        end
        newPriest.initState = newPriest.state
        newPriest.currentState = newPriest.state

        update_colBox(newPriest)
        table.insert(priest.list, newPriest)
    end
    return priest.list
    
end


function priest.update(dt)


    for i=1, #priest.list do
        local p = priest.list[i]
        if is_on_screen(p.pos) then
            check_state(p)
            set_anim(p)
            set_frames(p, dt)
        end
    end

end



return priest
