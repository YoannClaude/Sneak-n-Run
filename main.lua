io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

require "modules.utils"
require "modules.globals"

local position = require "modules.position"
local ui = require "modules.ui"
local tileset = require "modules.tileset"
local tutorial = require "modules.tutorial"
local game = require "modules.game"
local player = require "modules.player"

local state = mState.START
local restart = false

local currentLevel = levels.TUTORIAL
local audioThread = love.thread.newThread("modules/audioSystem.lua")
local masterVolChannel = love.thread.getChannel("masterVol")
local hiPassChannel = love.thread.getChannel("hiPass")
local musicChannel = love.thread.getChannel("music")
local stateChannel = love.thread.getChannel("state")
local quitChannel = love.thread.getChannel("quit")


local function reload(level)
    
    if level == levels.TUTORIAL then
        tutorial.load()
        stateChannel:push(gState.PASSIVE)
        musicChannel:push({play = false})
    elseif level == levels.MINE then
        game.load(restart)
    end
    restart = false

end


local function check_joystick(joystick)

    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        for i=1, #joysticks do
            if joysticks[i]:isGamepad() then
                GAMEPAD = joysticks[i]
                love.mouse.setVisible(false)
            return
            end
        end
        GAMEPAD = nil
        love.mouse.setVisible(true)
    else
        GAMEPAD = nil
        love.mouse.setVisible(true)
    end

end


function love.joystickadded(joystick)

    check_joystick()

end


function love.joystickremoved(joystick)

    check_joystick()

end


function love.gamepadpressed(joystick, button)

    if state ~= mState.PLAY then
        ui.get_gamepad_input(button)
        return
    end

    if button == 'start' then
        state = mState.MENU
        masterVolChannel:push(0.2)
    end
        
    if button == 'back' then
        if state == mState.PAUSE then
            state = mState.PLAY
            masterVolChannel:push(1)
        elseif state == mState.PLAY then
            state = mState.PAUSE
            masterVolChannel:push(0.2)
        end
    end

    if player.check_death() then
        return
    end

    if button == 'a' then
        player.action()
    end

    if button == 'x' and player.isVisible then
        hiPassChannel:push({value = true})
    end

    if button == 'rightshoulder' then
        player.shoot(GAMEPAD:getGamepadAxis('rightx'), GAMEPAD:getGamepadAxis('righty'))
    end

    if currentLevel == levels.TUTORIAL then
        tutorial.check_input(button)
    end

end


function love.keypressed(key)

    if GAMEPAD ~= nil then
        return
    end

    if state == mState.START then
        return
    end

    if key == 'escape' then
        state = mState.MENU
        masterVolChannel:push(0.2)
    end
    
    if key == 'return' then
        if state == mState.PAUSE then
            state = mState.PLAY
            masterVolChannel:push(1)
        elseif state == mState.PLAY then
            state = mState.PAUSE
            masterVolChannel:push(0.2)
        end
    end

    if player.check_death() then
        return
    end

    if currentLevel == levels.TUTORIAL then
        tutorial.check_input(key)
    end

    if key == 'e' then
        player.action()
    end

end


function love.gamepadreleased(joystick, button)

    if state ~= mState.PLAY then 
        ui.check_input_release(button)
        return
    end

    if button == 'x' and player.isVisible then
        hiPassChannel:push({value = false})
    end

end

function love.mousereleased(x, y, b, isTouch)

    if GAMEPAD ~= nil then
        return
    end

    if state ~= mState.PLAY then 
        ui.check_input_release()
        return
    end

    if b == 2 and player.isVisible then
        hiPassChannel:push({value = false})
    end

end


function love.mousepressed(x, y, b)

    if GAMEPAD ~= nil then
        return
    end

    if state ~= mState.PLAY then
        ui.check_input_click()
        return
    end

    if currentLevel == levels.TUTORIAL then
        tutorial.check_input(b)
    end

    if player.check_death() or not player.isVisible then
        return
    end
    
    if b == 1 then
        player.shoot(x, y)
    elseif b == 2 then
        hiPassChannel:push({value = true})
    end

end


function love.wheelmoved(x, y)

    if GAMEPAD ~= nil then
        return
    end

    if state ~= mState.PLAY then
        ui.check_mouse_wheel(y)
    end

end


function love.load()

    audioThread:start()
    masterVolChannel:push(0.2)
    ui.load()
    tileset.load()
    position.load()
  
end


function love.update(dt)
    
    if love.keyboard.isDown("lctrl") and love.keyboard.isDown('q') then
        love.event.quit()
    end
    
    if state == mState.PAUSE then
        return
    end

    if state ~= mState.PLAY then
        currentLevel, restart, state = ui.update(dt, state)
        if restart then
            reload(currentLevel)
        end
        return
    end
    
    if currentLevel == levels.TUTORIAL then
        currentLevel = tutorial.update(dt)
        if currentLevel == levels.MINE then
            reload(levels.MINE)
        end
    elseif currentLevel == levels.MINE then
        state = game.update(dt)
    end

end


function love.draw()

    if not state then
        ui.draw()
        return
    end

    if currentLevel == levels.TUTORIAL then
        tutorial.draw()
    elseif currentLevel == levels.MINE then
        game.draw()
    end
    
end


function love.threaderror(thread, errorstr)
    
    print("Thread error!\n"..errorstr)
    
end


function love.quit()

    quitChannel:push(true)
    local quit = quitChannel:demand()
    if quit then
        audioThread:release()
    end
    
end
