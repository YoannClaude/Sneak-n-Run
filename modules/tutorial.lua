local tutorial = {}

local player = require "modules.player"
local tileset = require "modules.tileset"
local camera = require "modules.camera"
local objects = require "modules.objects"
local ennemies = require "modules.ennemies"
local sprites = require "modules.sprites"

local font = love.graphics.newFont("assets/ui/font.ttf", 48)

local moveMsgKey = "ZQSD, WASD = MOVE"
local runMsgKey = "SPACE = RUN"
local sneakMsgKey = "SHIFT = SNEAK"
local soundMsgKey = "RIGHT-CLICK = CHECK SOUND \n    AND ENNEMIES' VISION"
local attackMsgKey = "LEFT-CLICK = SHOOT"
local switchMsgKey = "E = TOGGLE SWITCH"
local hideMsgKey = "E = HIDE"
local menuMsgKey = "  ESCAPE = MENU \n RETURN = PAUSE"
local moveMsgJoy = "LEFT STICK = MOVE"
local runMsgJoy = "RIGHT TRIGGER = RUN"
local sneakMsgJoy = "LEFT TRIGGER = SNEAK"
local soundMsgJoy = "X = CHECK SOUND AND\n   ENNEMIES' VISION"
local attackMsgJoy = "    RIGHT STICK = AIM \nRIGHT BUMPER = SHOOT"
local switchMsgJoy = "A = TOGGLE SWITCH"
local hideMsgJoy = "A = HIDE"
local menuMsgJoy = "START = MENU \n BACK = PAUSE"

local moveWidthKey = font:getWidth(moveMsgKey)
local runWidthKey = font:getWidth(runMsgKey)
local sneakWidthKey = font:getWidth(sneakMsgKey)
local soundWidthKey = font:getWidth(soundMsgKey)
local attackWidthKey = font:getWidth(attackMsgKey)
local switchWidthKey = font:getWidth(switchMsgKey)
local hideWidthKey = font:getWidth(hideMsgKey)
local menuWidthKey = font:getWidth(menuMsgKey)
local moveWidthJoy = font:getWidth(moveMsgJoy)
local runWidthJoy = font:getWidth(runMsgJoy)
local sneakWidthJoy = font:getWidth(sneakMsgJoy)
local soundWidthJoy = font:getWidth(soundMsgJoy)
local attackWidthJoy = font:getWidth(attackMsgJoy)
local switchWidthJoy = font:getWidth(switchMsgJoy)
local hideWidthJoy = font:getWidth(hideMsgJoy)
local menuWidthJoy = font:getWidth(menuMsgJoy)
local msgHeight = font:getHeight(moveMsgKey)

local printMsgn, printWidth


local areas = {MOVE = 0, MENU = 1, SWITCH = 2, ATTACK = 3, HIDE = 4, SOUND = 5, SNEAK = 6, RUN = 7, END = 8}
local message = areas.MOVE
local currentMsg
local drawMsg = true
local eraseMsg = false

local ColBox = {    
                    END = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.END].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.END].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.END].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.END].height
                                },

                    RUN = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.RUN].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.RUN].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.RUN].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.RUN].height
                                },
                    
                    SNEAK = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.SNEAK].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.SNEAK].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.SNEAK].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.SNEAK].height
                                },

                    SOUND = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.SOUND].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.SOUND].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.SOUND].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.SOUND].height
                                },
                    HIDE = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.HIDE].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.HIDE].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.HIDE].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.HIDE].height
                                },
                    ATTACK = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.ATTACK].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.ATTACK].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.ATTACK].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.ATTACK].height
                                },

                    SWITCH = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.SWITCH].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.SWITCH].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.SWITCH].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.SWITCH].height
                                },
                    MENU = {
                                x = MINE.layers[position_layer.TUTORIAL].objects[areas.MENU].x,
                                y = MINE.layers[position_layer.TUTORIAL].objects[areas.MENU].y,
                                width = MINE.layers[position_layer.TUTORIAL].objects[areas.MENU].width,
                                height = MINE.layers[position_layer.TUTORIAL].objects[areas.MENU].height
                                }
                                
                }

local checkSound = false
local hasStarted = false
local hasEnded = false
local r, g, b, a, aMsg = 1, 1, 1, 1, 1


local function check_player_pos()


    if check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.END.x, ColBox.END.y, ColBox.END.width, ColBox.END.height) then
        return true
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.RUN.x, ColBox.RUN.y, ColBox.RUN.width, ColBox.RUN.height) then
        message = areas.RUN
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.SNEAK.x, ColBox.SNEAK.y, ColBox.SNEAK.width, ColBox.SNEAK.height) then
        message = areas.SNEAK
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.SOUND.x, ColBox.SOUND.y, ColBox.SOUND.width, ColBox.SOUND.height) then
        message = areas.SOUND
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.ATTACK.x, ColBox.ATTACK.y, ColBox.ATTACK.width, ColBox.ATTACK.height) then
        message = areas.ATTACK
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.SWITCH.x, ColBox.SWITCH.y, ColBox.SWITCH.width, ColBox.SWITCH.height) then
        message = areas.SWITCH
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.HIDE.x, ColBox.HIDE.y, ColBox.HIDE.width, ColBox.HIDE.height) then
        message = areas.HIDE
    elseif check_colPoint_to_colBox(PLAYER_POS.x, PLAYER_POS.y, ColBox.MENU.x, ColBox.MENU.y, ColBox.MENU.width, ColBox.MENU.height) then
        message = areas.MENU
    end
    return false

end


local function draw_messages()

    love.graphics.setColor(1, 1, 1, aMsg)

    if currentMsg == message then
        if drawMsg then
            love.graphics.printf(printMsg, SCREEN.WIDTH/2, SCREEN.HEIGHT/2, SCREEN.WIDTH, "left", 0, 1, 1, printWidth/2, msgHeight/2)
        end
        return
    else
        if GAMEPAD ~= nil then
            if message == areas.MOVE then
                printMsg = moveMsgJoy
                printWidth = moveWidthJoy
            elseif message == areas.RUN then
                printMsg = runMsgJoy
                printWidth = runWidthJoy
            elseif message == areas.SNEAK then
                printMsg = sneakMsgJoy
                printWidth = sneakWidthJoy
            elseif message == areas.SOUND then
                printMsg = soundMsgJoy
                printWidth = soundWidthJoy
            elseif message == areas.ATTACK then
                printMsg = attackMsgJoy
                printWidth = attackWidthJoy
            elseif message == areas.SWITCH then
                printMsg = switchMsgJoy
                printWidth = switchWidthJoy
            elseif message == areas.HIDE then
                printMsg = hideMsgJoy
                printWidth = hideWidthJoy
            elseif message == areas.MENU then
                printMsg = menuMsgJoy
                printWidth = menuWidthJoy
            end
        else
            if message == areas.MOVE then
            printMsg = moveMsgKey
            printWidth = moveWidthKey
            elseif message == areas.RUN then
                printMsg = runMsgKey
                printWidth = runWidthKey
            elseif message == areas.SNEAK then
                printMsg = sneakMsgKey
                printWidth = sneakWidthKey
            elseif message == areas.SOUND then
                printMsg = soundMsgKey
                printWidth = soundWidthKey
            elseif message == areas.ATTACK then
                printMsg = attackMsgKey
                printWidth = attackWidthKey
            elseif message == areas.SWITCH then
                printMsg = switchMsgKey
                printWidth = switchWidthKey
            elseif message == areas.HIDE then
                printMsg = hideMsgKey
                printWidth = hideWidthKey
            elseif message == areas.MENU then
                printMsg = menuMsgKey
                printWidth = menuWidthKey
            end
        end
        drawMsg = true
        eraseMsg = false
        aMsg = 1
        currentMsg = message
    end

end


local function tuto_end(dt)

    if hasEnded then
      r = r - 1.5 * dt
      g = g - 1.5 * dt
      b = b - 1.5 * dt  
      if r < 0 then
        return levels.MINE
      end
    end
    return levels.TUTORIAL
  
end


local function tuto_start(dt)

    r = r + 1.5 * dt
    g = g + 1.5 * dt
    b = b + 1.5 * dt  
    if r > 1 then
        r, g, b = 1, 1, 1
        hasStarted = true
    end
  
end


function tutorial.check_input(key)

    if GAMEPAD ~= nil then
        if  (key == 'move' and message == areas.MOVE) or 
            (key == 'run' and message == areas.RUN) or 
            (key == 'sneak' and message == areas.SNEAK) or
            (key == 'a' and message == areas.SWITCH) or
            (key == 'rightshoulder' and message == areas.ATTACK) or
            (key == 'a' and message == areas.HIDE) or
            ((key == 'start' or key == 'back') and message == areas.MENU) or
            (key == 'x' and message == areas.SOUND) then
            eraseMsg = true
        end

    else
        if ((key == 'z' or key == 's' or key =='q' or key == 'd' or key == 'a' or key == 'w') and message == areas.MOVE) or 
            (key == 'space' and message == areas.RUN) or 
            (key == 'lshift' and message == areas.SNEAK) or
            (key == 'e' and message == areas.SWITCH) or
            (key == 1 and message == areas.ATTACK) or
            (key == 'e' and message == areas.HIDE) or
            ((key == 'return' or key == 'escape') and message == areas.MENU) or
            (key == 2 and message == areas.SOUND) then
            eraseMsg = true
        end
    end

end


function tutorial.load()

    ennemies.load(levels.TUTORIAL)
    player.load(levels.TUTORIAL)
    camera.load()
    camera.set_globalState(gState.PASSIVE)
    objects.load()
    sprites.load()
    hasStarted = false
    message = areas.MOVE
    r, g, b = 0, 0, 0

end


function tutorial.update(dt)

    if hasEnded then
        return tuto_end(dt)
    end
    
    if not hasStarted then
        tuto_start(dt)
    end

    player.update(dt)
    hasEnded = check_player_pos()
    camera.follow_player()
    ennemies.update(dt)
    sprites.update(state, dt)
    objects.update(dt)

    if drawMsg and eraseMsg then
        aMsg = aMsg - 1 * dt
        if aMsg < 0 then
            drawMsg = false
            aMsg = 1
        end
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
        if  GAMEPAD:getGamepadAxis("leftx") > 0.25 or 
            GAMEPAD:getGamepadAxis("leftx") < -0.25 or
            GAMEPAD:getGamepadAxis("lefty") > 0.25 or
            GAMEPAD:getGamepadAxis("lefty") < -0.25 then
            tutorial.check_input('move')
        end
        if GAMEPAD:getGamepadAxis("triggerleft") > 0.5 then
            tutorial.check_input('sneak')
        end
        if GAMEPAD:getGamepadAxis("triggerright") > 0.5 then
            tutorial.check_input('run')
        end
    else
        if love.mouse.isDown(2) and player.isVisible then
            a = 0.5
            checkSound = true
            sprites.set_soundCheck(true)
        else
            a = 1
            checkSound = false
            sprites.set_soundCheck(false)
        end
    end
    return levels.TUTORIAL

end


function tutorial.draw()

    love.graphics.setColor(r, g, b, a)
    
    camera.set()
    tileset.draw()
    sprites.draw()
    tileset.draw_on_top()
    if checkSound then
        sprites.draw_shapes()
    end
    camera.unset()
    sprites.draw_fog()
    if hasStarted then
        draw_messages()
    end

end


return tutorial