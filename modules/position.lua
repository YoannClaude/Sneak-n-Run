local position = {}

local objectList = {}
local doorList = {}
local switchList = {}
local hidingPlaceList = {}
local trapList = {}
local lightList = {}
local batList = {}
local priestList = {}
local guardList = {}
local playerList = {}


function position.get_player_list()

    return playerList

end


function position.get_guard_list()

    return guardList
                        
end


function position.get_bat_list()

    return batList
                        
end


function position.get_priest_list()

    return priestList

end


function position.get_light_list()

    return lightList

end


function position.get_door_list()

    return doorList

end


function position.get_trap_list()

    return trapList

end


function position.get_switch_list()

    return switchList

end


function position.get_hidingPlace_list()

    return hidingPlaceList

end


function position.load()

    --load objects from map
    local objects = {}
    objects = MINE.layers[position_layer.OBJECTS].objects
    for i=1, #objects do
        local obj = objects[i]
        if obj.type == "Door" then
            local myDoor = {}
            myDoor.pos = Vector2(obj.x, obj.y)
            myDoor.id = obj.id
            myDoor.facing = obj.properties.facing
            table.insert(doorList, myDoor)
            table.insert(objectList, myDoor)
        elseif obj.type == "Switch" then
            local mySwitch = {}
            mySwitch.pos = Vector2(obj.x, obj.y)
            mySwitch.openId = obj.properties.open.id
            table.insert(switchList, mySwitch)
            table.insert(objectList, mySwitch)
        elseif obj.type == "HidingPlace" then
            local myHidingPlace = {}
            myHidingPlace.pos = Vector2(obj.x, obj.y)
            table.insert(hidingPlaceList, myHidingPlace)
            table.insert(objectList, myHidingPlace)
        elseif obj.type == "Trap" then
            local myTrap = {}
            myTrap.pos = Vector2(obj.x, obj.y)
            myTrap.id = obj.id
            table.insert(trapList, myTrap)
            table.insert(objectList, myTrap)
        elseif obj.type == "Light" then
            local myLight = {}
            myLight.pos = Vector2(obj.x, obj.y)
            table.insert(lightList, myLight)
        end
    end

    --load ennemies from map
    local ennemies = {}
    ennemies = MINE.layers[position_layer.ENNEMIES].objects
    for i=1, #ennemies do
        local enm = ennemies[i]
        if enm.type == "Bat" then
            local myBat = {}
            myBat.initPos = Vector2(enm.x, enm.y)
            table.insert(batList, myBat)
        elseif enm.type == "Priest" then
            local myPriest = {}
            myPriest.pos = Vector2(enm.x, enm.y)
            if enm.properties.facing == "up" then
                myPriest.dir = dir.UP
            elseif enm.properties.facing == "down" then
                myPriest.dir = dir.DOWN
            elseif enm.properties.facing == "left" then
                myPriest.dir = dir.LEFT
            elseif enm.properties.facing == "right" then
                myPriest.dir = dir.RIGHT
            end
            myPriest.isStatic = enm.properties.static
            table.insert(priestList, myPriest)
        elseif enm.type == "Guard" then
            local myGuard = {}
            myGuard.initPos = Vector2(enm.x, enm.y)
            if enm.properties.facing == "up" then
                myGuard.dir = dir.UP
            elseif enm.properties.facing == "down" then
                myGuard.dir = dir.DOWN
            elseif enm.properties.facing == "left" then
                myGuard.dir = dir.LEFT
            elseif enm.properties.facing == "right" then
                myGuard.dir = dir.RIGHT
            end
            myGuard.isStatic = true
            table.insert(guardList, myGuard)
        elseif enm.type == "Path" then
            --get 1st path point
            if enm.properties.startPoint then
                local myGuard = {}
                myGuard.isStatic = false
                myGuard.patrolPath = {}
                table.insert(myGuard.patrolPath, Vector2(enm.x, enm.y))
                --go through whole ennemies list to build path list
                local nextPoint, currentPoint
                nextPoint = enm.properties.nextPoint.id
                currentPoint = enm
                while not currentPoint.properties.lastPoint do
                    for i=1, #ennemies do
                        local e = ennemies[i]
                        if e.id == nextPoint then
                            table.insert(myGuard.patrolPath, Vector2(e.x, e.y))
                            nextPoint = e.properties.nextPoint.id
                            currentPoint = e
                            break
                        end
                    end
                end
                myGuard.initPos = Vector2(enm.x, enm.y)
                table.insert(guardList, myGuard)
            end
        end
    end
    --load player start point and checkpoints location
    local points = {}
    points = MINE.layers[position_layer.PLAYER].objects
    playerList.checkpoint = {}
    for i=1, #points do 
        local p = points[i]
        if p.type == "Tutorial" then
            playerList.tutorial = Vector2(p.x, p.y)
        elseif p.type == "Game" then
            playerList.game = Vector2(p.x, p.y)
        elseif p.type == "Checkpoint" then
            if p.name == "1" then
                playerList.checkpoint[1] = Vector2(p.x, p.y)
            elseif p.name == "2" then
                playerList.checkpoint[2] = Vector2(p.x, p.y)
            elseif p.name == "3" then
                playerList.checkpoint[3] = Vector2(p.x, p.y)
            end
        end
    end
end


return position