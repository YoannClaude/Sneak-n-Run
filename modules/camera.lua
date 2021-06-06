local camera = {}


local ennemies = require "modules.ennemies"
local sprites = require "modules.sprites"

local x, y = 0, 0
local state = gState.PASSIVE
local sirenChannel = love.thread.getChannel("siren")


function camera.set()   

    love.graphics.push()
    love.graphics.translate(-x, -y)

end


function camera.unset()

    love.graphics.pop()

end


function camera.check_screen(pX, pY)

    if pX > x and pX < x + SCREEN.WIDTH and pY > y and pY < y + SCREEN.HEIGHT then
        return true
    end
    return false

end


function camera.follow_player()

    local change = false
    if PLAYER_POS.x > SCREEN.WIDTH + x then
        x = x + SCREEN.WIDTH
        change = true
    elseif PLAYER_POS.x < x then
        x = x - SCREEN.WIDTH
        change = true
    elseif PLAYER_POS.y > SCREEN.HEIGHT + y then
        y = y + SCREEN.HEIGHT
        change = true
    elseif PLAYER_POS.y < y then
        y = y - SCREEN.HEIGHT
        change = true
    end

    if change then
        set_cameraPos(Vector2(x, y))
        sprites.update_objects()
        if state == gState.ACTIVE then
            ennemies.alert()
            sirenChannel:push(true)
        end
    end

end


function camera.set_globalState(s)

    state = s

end


function camera.load()

    x = math.floor(PLAYER_POS.x / SCREEN.WIDTH) * SCREEN.WIDTH
    y = math.floor(PLAYER_POS.y / SCREEN.HEIGHT) * SCREEN.HEIGHT
    set_cameraPos(Vector2(x, y))

end



return camera