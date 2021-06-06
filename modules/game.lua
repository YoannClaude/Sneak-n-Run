local game = {}

                            --------------------------------------------

local player = require "modules.player"
local tileset = require "modules.tileset"
local camera = require "modules.camera"
local ennemies = require "modules.ennemies"
local sprites = require "modules.sprites"
local objects = require "modules.objects"

local musicChannel = love.thread.getChannel("music")
local sirenChannel = love.thread.getChannel("siren")
local stateChannel = love.thread.getChannel("state")

local passive, active, suspicious, siren
local state

local currentState = nil
local hasStarted = false
local hasAlert = false
local checkSound = false
local victory = false
local checkpoint = 0
local areas = {END = 1, CHECKPOINT_1 = 2, CHECKPOINT_2 = 3, CHECKPOINT_3 = 4}

local r, g, b, a = 0, 0, 0, 1

local ColBox = {    
    END = {
                x = MINE.layers[position_layer.GAME].objects[areas.END].x,
                y = MINE.layers[position_layer.GAME].objects[areas.END].y,
                width = MINE.layers[position_layer.GAME].objects[areas.END].width,
                height = MINE.layers[position_layer.GAME].objects[areas.END].height
                },

    CHECKPOINT_1 = {
                x = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_1].x,
                y = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_1].y,
                width = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_1].width,
                height = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_1].height
                },
    
    CHECKPOINT_2 = {
                x = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_2].x,
                y = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_2].y,
                width = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_2].width,
                height = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_2].height
                },

    CHECKPOINT_3 = {
                x = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_3].x,
                y = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_3].y,
                width = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_3].width,
                height = MINE.layers[position_layer.GAME].objects[areas.CHECKPOINT_3].height
                }
                
}


local function check_player_pos()

    if check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.END.x, ColBox.END.y, ColBox.END.width, ColBox.END.height) then
        return true
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.CHECKPOINT_1.x, ColBox.CHECKPOINT_1.y, ColBox.CHECKPOINT_1.width, ColBox.CHECKPOINT_1.height) then
        checkpoint = 1
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.CHECKPOINT_2.x, ColBox.CHECKPOINT_2.y, ColBox.CHECKPOINT_2.width, ColBox.CHECKPOINT_2.height) then
        checkpoint = 2
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.CHECKPOINT_3.x, ColBox.CHECKPOINT_3.y, ColBox.CHECKPOINT_3.width, ColBox.CHECKPOINT_3.height) then
        checkpoint = 3
    end
    return false

end


local function player_death(dt)

    if player.check_death() then
        r = r - 1.5 * dt
        g = g - 1.5 * dt
        b = b - 1.5 * dt
        if r < 0 then
            game.load()
        end
    end

end


local function game_start(dt)

    r = r + 1.5 * dt
    g = g + 1.5 * dt
    b = b + 1.5 * dt  
    if r > 1 then
        r, g, b = 1, 1, 1
        hasStarted = true
    end
  
end


local function game_end(dt)

    if victory then
        r = r - 1.5 * dt
        g = g - 1.5 * dt
        b = b - 1.5 * dt  
        if r < 0 then
            return mState.END
        end
    end
    
    return mState.PLAY
  
end


local function check_state(dt)

    if state == gState.DEFEAT then
        player_death(dt)
        return
    end

    state = ennemies.check_state(state)

    if currentState == state then
        return
    end

    currentState = state
    camera.set_globalState(state)
    stateChannel:push(state)

    if state == gState.PASSIVE then
        if hasAlert then
            ennemies.get_back_home()
            hasAlert = false
        end
    elseif state == gState.ACTIVE then
        sirenChannel:push(true)
        if not hasAlert then
            ennemies.alert()
            hasAlert = true
        end
    elseif state == gState.DEFEAT then
        player.game_over()
        ennemies.get_back_home()
    end

end


function game.load(restart)

    r, g, b, a = 0, 0, 0, 1
    state = gState.PASSIVE
    stateChannel:push(state)
    musicChannel:push({play = true})
    objects.load()
    ennemies.load(levels.MINE)
    player.load(levels.MINE, checkpoint, restart)
    camera.load()
    sprites.load()
    victory = false
    hasStarted = false
    hasAlert = false
    currentState = nil
    
end


function game.update(dt)

    if victory then
        return game_end(dt)
    end

    if not hasStarted then
        game_start(dt)
    end

    player.update(dt)
    victory = check_player_pos()
    camera.follow_player()
    ennemies.update(dt)
    sprites.update(state, dt)
    objects.update(dt)

    check_state(dt)

    if player.check_death() or not player.isVisible then
        return mState.PLAY
    end
        
    if GAMEPAD ~= nil then
        if GAMEPAD:isGamepadDown('x') and player.isVisible then
            a = 0.5
            checkSound = true
            sprites.set_soundCheck(true)
        else
            a = 1
            checkSound = false
            sprites.set_soundCheck(false)
        end
    else
        if love.mouse.isDown(2) then
            a = 0.5
            checkSound = true
            sprites.set_soundCheck(true)
        else
            a = 1
            checkSound = false
            sprites.set_soundCheck(false)
        end
    end
    
    return mState.PLAY

end


function game.draw()

    love.graphics.setColor(r, g, b, a)
        
    camera.set()
    tileset.draw()
    sprites.draw()
    tileset.draw_on_top()
    sprites.draw_lights(state)
    if checkSound then
        sprites.draw_shapes()
    end
    camera.unset()
    if state == gState.PASSIVE then
        sprites.draw_fog()
    end

end

                            ---------------------------------

return game
