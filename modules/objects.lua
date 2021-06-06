local objects = {}


local position = require "modules.position"
local ennemies = require "modules.ennemies"

local doorList
local switchList
local trapList
local lightList
local hidingPlaceList
local onScreenList
local sfx = {
    door = "event:/SFX/Objects/Door",
    trap = "event:/SFX/Objects/Trap",
    switch = "event:/SFX/Objects/Switch"
    }
local monoChannel = love.thread.getChannel("monoSfx")
local stereoChannel = love.thread.getChannel("stereoSfx")




local function toggle_related_object(switch)

    for i=1, #onScreenList do
        local obj = onScreenList[i]
        if obj.id == switch.openId then
            obj.isOpen = switch.isOpen
            local dist = math.floor(distance(obj.pos, PLAYER_POS))
            if obj.sType == sType.DOOR then
                monoChannel:push({obj = sType.DOOR, event = sfx.door, param = dist})
            elseif obj.sType == sType.TRAP then
                monoChannel:push({obj = sType.TRAP, event = sfx.trap, param = dist})
            end
            break
        end
    end

end


function objects.get_objects_on_screen()

    onScreenList = {}
    for i = 1, #doorList do
        if is_on_screen(doorList[i].pos) then
            table.insert(onScreenList, doorList[i])
        end
    end
    for i = 1, #switchList do
        if is_on_screen(switchList[i].pos) then
            table.insert(onScreenList, switchList[i])
        end
    end
    for i = 1, #trapList do
        if is_on_screen(trapList[i].pos) then
            table.insert(onScreenList, trapList[i])
        end
    end
    for i = 1, #hidingPlaceList do
        if is_on_screen(hidingPlaceList[i].pos) then
            table.insert(onScreenList, hidingPlaceList[i])
        end
    end

    return onScreenList

end


function objects.get_light_on_screen()

    local list = {}
    for i = 1, #lightList do
        if is_on_screen(lightList[i].pos) then
            table.insert(list, lightList[i])
        end
    end

    return list

end


function objects.toggle_switch(switch)

    if not switch.isToggle then
        switch.isToggle = true
        switch.isOpen = not switch.isOpen
        stereoChannel:push(sfx.switch)
    end

end


function objects.load()

    doorList = position.get_door_list()

    for i=1, #doorList do
        local d = doorList[i]
        d.isOpen = false
        d.sType = sType.DOOR
        if d.facing == "down" or d.facing == "up" then
            d.colBox = {d.pos.x - 60, d.pos.y - 32, 120, 27}
        else
            d.colBox = {d.pos.x - 27, d.pos.y - 60, 59, 120}
        end
    end
    switchList = position.get_switch_list()
    for i=1, #switchList do
        local s = switchList[i]
        s.isOpen = false
        s.sType = sType.SWITCH
        s.soundDraw = false
        s.radius = 200
        s.frame = 1
        s.currentFrame = 1
        s.colBox = {s.pos.x - QUADSIZE/4, s.pos.y - QUADSIZE/4 + 10, QUADSIZE/2 - 5, QUADSIZE/2 - 40}
    end
    trapList = position.get_trap_list()
    for i=1, #trapList do
        local t =trapList[i]
        t.isOpen = false
        t.sType = sType.TRAP
        t.colBox = {t.pos.x - QUADSIZE/2, t.pos.y - QUADSIZE/2, QUADSIZE, QUADSIZE}
    end
    hidingPlaceList = position.get_hidingPlace_list()
    for i=1, #hidingPlaceList do
        local hp = hidingPlaceList[i]
        hp.isOpen = true
        hp.sType = sType.HIDING_PLACE
        hp.colBox = {hp.pos.x - QUADSIZE/4, hp.pos.y - QUADSIZE/4 + 10, QUADSIZE/2, QUADSIZE/2}
    end
    lightList = position.get_light_list()

end


function objects.update(dt)

    if #onScreenList > 0 then
        for i=1, #onScreenList do
            local obj = onScreenList[i]
            if obj.sType == sType.SWITCH then
                if obj.isToggle then
                    obj.soundDraw = true
                    if obj.isOpen then
                        obj.frame = obj.frame + 5 * dt
                        obj.currentFrame = math.floor(obj.frame)
                        if obj.currentFrame == 3 then
                            obj.isToggle = false
                            toggle_related_object(obj)
                        end
                    else
                        obj.frame = obj.frame - 5 * dt
                        obj.currentFrame = math.floor(obj.frame)
                        if obj.currentFrame == 1 then
                            obj.isToggle = false
                            toggle_related_object(obj)
                        end
                    end
                else
                    obj.soundDraw = false
                end
            end
        end
    end
    for i=1, #trapList do
        local trap = trapList[i]
        if trap.isOpen then
            local eList = ennemies.get_guard_list()
            if #eList > 0 then
                for i=1, #eList do
                    local ennemy = eList[i]
                    if ennemy.sType == sType.GUARD then
                        if check_colPoint_to_colBox(ennemy.pos.x, ennemy.pos.y,
                        trap.colBox[1], trap.colBox[2], trap.colBox[3], trap.colBox[4]) then
                            ennemy.state = eState.FALLING
                            ennemy.target = trap.pos
                        end
                    end
                end
            end 
        end
    end
end


return objects