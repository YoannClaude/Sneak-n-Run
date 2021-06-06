local ennemies = {}


local position = require "modules.position"
local guards = require "modules.guard"
local priests = require "modules.priest"
local bats = require "modules.bat"
local spells = require "modules.spell"

local eList = {}
local guardList = {}
local priestList = {}


function ennemies.get_back_home()

    for i= 1, #eList do
        local e = eList[i]
        if e.sType == sType.GUARD and e.state == eState.CHASE then
            e.state = eState.GETTING_CALM
            e.hasCalledPath = false
            e.pathIndex = 2
        elseif e.sType == sType.PRIEST and e.state ~= eState.KO and e.state ~= eState.HIT then
            e.state = e.initState
        end
    end

end


function ennemies.get_guard_list()

    return guardList

end


function ennemies.alert()

    local list = ennemies.on_screen()
    if #list > 0 then
        for i=1, #list do
            list[i].state = eState.CHASE
        end
    end

end


function ennemies.on_screen()

    local list = {}
    for i=1, #eList do
        local e = eList[i]
        if is_on_screen(e.pos) then
        table.insert(list, e)
        end
    end
    return list

end


function ennemies.get_vision_points(e)

    if e.facing == dir.DOWN then
        return {e.pos, e.pos + Vector2(120, 260), 
                e.pos + Vector2(0, 280),
                e.pos + Vector2(-120, 260),
                e.pos}
    elseif e.facing == dir.UP then
        return {e.pos, e.pos + Vector2(120, -260),
                e.pos + Vector2(0, -280),
                e.pos + Vector2(-120, -260),
                e.pos}
    elseif e.facing == dir.LEFT then
        return {e.pos, e.pos + Vector2(-260, 120),
                e.pos + Vector2(-280, 0),
                e.pos + Vector2(-260, -120),
                e.pos}
    elseif e.facing == dir.RIGHT then
        return {e.pos, e.pos + Vector2(260, 120),
                e.pos + Vector2(280, 0),
                e.pos + Vector2(260, -120),
                e.pos}
    end

end


function ennemies.get_vision_triangles(e)

    local p1, p2, p3, p4, t1, t2, t3
    
    if e.facing == dir.DOWN then
        p1 = e.pos + Vector2(120, 260)
        p2 = e.pos + Vector2(0, 280)
        p3 = e.pos + Vector2(-120, 260)
        p4 = e.pos + Vector2(0, 260)
    elseif e.facing == dir.UP then
        p1 = e.pos + Vector2(120, -260)
        p2 = e.pos + Vector2(0, -280)
        p3 = e.pos + Vector2(-120, -260)
        p4 = e.pos + Vector2(0, -260)
    elseif e.facing == dir.LEFT then
        p1 = e.pos + Vector2(-260, 120)
        p2 = e.pos + Vector2(-280, 0)
        p3 = e.pos + Vector2(-260, -120)
        p4 = e.pos + Vector2(-260, 0)
    elseif e.facing == dir.RIGHT then
        p1 = e.pos + Vector2(260, 120)
        p2 = e.pos + Vector2(280, 0)
        p3 = e.pos + Vector2(260, -120)
        p4 = e.pos + Vector2(260, 0)
    end
    
    t1 = {e.pos, p1, p4}
    t2 = {e.pos, p4, p3}
    t3 = {p1, p2, p3}
    
    return {t1, t2, t3}

end


function ennemies.get_stunned(source, origin, pEnnemy)

    pEnnemy.soundSource = source
    pEnnemy.soundOrigin = origin
    pEnnemy.previousState = pEnnemy.state
    pEnnemy.state = eState.HIT
    pEnnemy.hasCheckedSource = true

end


function ennemies.see_player(pEnnemy, pos)

    if  pEnnemy.state == eState.CHASE or
        pEnnemy.state == eState.KO or
        pEnnemy.state == eState.HIT or
        pEnnemy.state == eState.SLAY or
        pEnnemy.state == eState.CAST or
        pEnnemy.state == eState.FALLING or
        pEnnemy.sType == sType.BAT then
        return
    end

    if pEnnemy.sType == sType.GUARD then
        pEnnemy.nextState = eState.CHASE
        pEnnemy.hasCalledPath = false
    end
    
    pEnnemy.state = eState.SURPRISE

end

function ennemies.hear_sound(source, origin, pEnnemy)

    if  pEnnemy.state == eState.CHASE or
        pEnnemy.state == eState.KO or
        pEnnemy.state == eState.HIT or
        pEnnemy.state == eState.SLAY or
        pEnnemy.state == eState.CAST or
        pEnnemy.sType == sType.SPELL or
        pEnnemy.state == eState.FALLING or
        pEnnemy.sType == sType.BAT or
        pEnnemy.nextState == eState.CHASE then
        return
    end

    if pEnnemy.sType == sType.GUARD then
        pEnnemy.soundSource = source
        pEnnemy.soundOrigin = origin
        pEnnemy.hasCheckedSource = false
        pEnnemy.hasCalledPath = false
        pEnnemy.state = eState.SURPRISE
        pEnnemy.nextState = eState.SUSPICIOUS
    elseif pEnnemy.sType == sType.PRIEST then
        pEnnemy.state = eState.SURPRISE
    end

end


function ennemies.lost_player()

    for i=1, #eList do
        local ennemy = eList[i]
        if ennemy.state == eState.CHASE or ennemy.state == CAST then
            if ennemy.sType == sType.GUARD then
                ennemy.soundOrigin = PLAYER_POS
                ennemy.hasCheckedSource = true
                ennemy.hasCalledPath = false
                ennemy.state = eState.SUSPICIOUS
            elseif ennemy.sType == sType.PRIEST then
                ennemy.state = eState.STATIC
            end
        end
    end

end


function ennemies.check_state(st)

    local pEnnemy
    for i = #eList, 1, -1 do
        pEnnemy = eList[i]
        if pEnnemy.isDead then
            table.remove(eList, i)
        end
    end
    for i=1, #eList do
        pEnnemy = eList[i]
        if pEnnemy.sType == sType.GUARD and pEnnemy.hasKilled then
            return gState.DEFEAT
        end
    end
    for i=1, #eList do
        pEnnemy = eList[i]
        if pEnnemy.state == eState.CHASE or pEnnemy.state == eState.CAST or
                pEnnemy.state == eState.SLAY or
                (pEnnemy.sType == sType.GUARD and pEnnemy.state == eState.HIT and
                st == gState.ACTIVE) then
            return gState.ACTIVE
        end
    end
    for i=1, #eList do
        pEnnemy = eList[i]
        if pEnnemy.state == eState.SUSPICIOUS or
                pEnnemy.state == eState.SURPRISE or
                pEnnemy.state == eState.LOOK_AROUND then
            return gState.SUSPICIOUS
        end
    end
      
    return gState.PASSIVE
    
end


function ennemies.load(level)

    eList = {}

    guardList = position.get_guard_list()
    guardList = guards.load(guardList, level)
    if guardList then
        for i=1,#guardList do
            table.insert(eList, guardList[i])
        end
    end

    priestList = position.get_priest_list()
    priestList = priests.load(priestList, level)
    if priestList then
        for i=1,#priestList do
            table.insert(eList, priestList[i])
        end
    end

    local batList = position.get_bat_list()
    batList = bats.load(batList, level)
    if batList then
        for i=1,#batList do
            table.insert(eList, batList[i])
        end
    end

end


function ennemies.update(dt)

    if guards.list ~= nil then
        guards.update(dt)
    end
    if priests.list ~= nil then
        priests.update(dt)
        spells.update(dt)
    end
    bats.update(dt)

end



return ennemies
