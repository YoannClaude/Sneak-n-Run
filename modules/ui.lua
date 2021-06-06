local ui = {}


local button = love.graphics.newImage("assets/ui/button.png")
local buttonClick = love.graphics.newImage("assets/ui/button_selected.png")
local buttonLight = love.graphics.newImage("assets/ui/button_highlight.png")
local arrowButton = love.graphics.newImage("assets/ui/arrow_button.png")
local arrowButtonLight = love.graphics.newImage("assets/ui/arrow_button_highlight.png")
local logo = love.graphics.newImage("assets/ui/FMOD_logo.png")

local menu = love.graphics.newImage("assets/ui/menu.png")

local font = love.graphics.newFont("assets/ui/font.ttf", 48)
local titleFont = love.graphics.newFont("assets/ui/font.ttf", 84)

local mesTitle = "SNEAK'n'RUN"
local mesPlay = "Play"
local mesSkip = "Skip Tutorial"
local mesQuit = "Quit"
local mesResume = "Resume"
local mesSet = "Settings"
local mesStart = "Start Menu"
local mesVolume = "Volume"
local mesNumber1 = "0"
local mesNumber2 = "00"
local mesNumber3 = "000"
local mesSound = "Sound FX"
local mesMusic = "Music"
local mesBack = "Back"
local mesVictory = "VICTORY!"
local mesReplay = "Play again"
local mesThanks = "THANKS FOR PLAYING!"

local topIsLight = false
local topIsClick = false
local middleIsLight = false
local middleIsClick = false
local bottomIsLight = false
local bottomIsClick = false
local arrowUpIsLight = false
local arrowDownIsLight = false
local mouseIsOnNumber = false
local mainState = mState.START
local currentLevel, restart

local buttonWidth, buttonHeight = button:getDimensions()
local arrowButtonWidth, arrowButtonHeight = arrowButton:getDimensions()
local menuWidth, menuHeight = menu:getDimensions()
local logoWidth, logoHeight = logo:getDimensions()

local titleWidth = titleFont:getWidth(mesTitle)
local titleHeight = titleFont:getHeight(mesTitle)
local playWidth = font:getWidth(mesPlay)
local playHeight = font:getHeight(mesPlay)
local skipWidth = font:getWidth(mesSkip)
local skipHeight = font:getHeight(mesSkip)
local quitWidth = font:getWidth(mesQuit)
local quitHeight = font:getHeight(mesQuit)
local resumeWidth = font:getWidth(mesResume)
local resumeHeight = font:getHeight(mesResume)
local setWidth = font:getWidth(mesSet)
local setHeight = font:getHeight(mesSet)
local volumeWidth = font:getWidth(mesVolume)
local volumeHeight = font:getHeight(mesVolume)
local number1Width = font:getWidth(mesNumber1)
local number2Width = font:getWidth(mesNumber2)
local number3Width = font:getWidth(mesNumber3)
local numberHeight = font:getHeight(mesNumber)
local startWidth = font:getWidth(mesStart)
local startHeight = font:getHeight(mesStart)
local soundWidth = font:getWidth(mesSound)
local soundHeight = font:getHeight(mesSound)
local musicWidth = font:getWidth(mesMusic)
local musicHeight = font:getHeight(mesMusic)
local backWidth = font:getWidth(mesBack)
local backHeight = font:getHeight(mesBack)
local victoryWidth = font:getWidth(mesVictory)
local victoryHeight = font:getHeight(mesVictory)
local replayWidth = font:getWidth(mesReplay)
local replayHeight = font:getHeight(mesReplay)
local thanksWidth = font:getWidth(mesThanks)
local thanksHeight = font:getHeight(mesThanks)

local menuX, menuY
local topButtonX, topButtonY
local midButtonX, midButtonY
local botButtonX, botButtonY
local arrowDownButtonX, arrowDownButtonY
local arrowUpButtonX, arrowUpButtonY
local numX, numY

local gamePadPosY = 1
local gamePadPosX = 1

local soundVolume = 100
local musicVolume = 100

local state = menus.START
local bufferState = state
local currentLevel = levels.TUTORIAL

local timer = 0.6
local quitTimer = 1.5

local tweenIn = {}
local tweenOut = {}
local tween

local isTweening = false

local sfx = {
    forward = "event:/UI/Forward",
    backward = "event:/UI/Backward",
    scroll = "event:/UI/Scroll"
}

local stereoChannel = love.thread.getChannel("stereoSfx")
local musicVolChannel = love.thread.getChannel("musicVol")
local sfxVolChannel = love.thread.getChannel("sfxVol")
local masterVolChannel = love.thread.getChannel("masterVol")


local function return_parameters()
    
    musicVolChannel:push(musicVolume)
    masterVolChannel:push(1)
    return currentLevel, restart, mainState

end


local function update_menu_pos()

    if isTweening then
        menuX = tween
    else
        menuX = SCREEN.WIDTH/2
    end
    topButtonX = menuX - buttonWidth/2
    midButtonX = menuX - buttonWidth/2
    botButtonX = menuX - buttonWidth/2
    arrowDownButtonX = menuX - buttonWidth/2 + arrowButtonWidth * 1.5
    arrowUpButtonX = menuX + buttonWidth/2 - arrowButtonWidth * 2.5
    numX = menuX - number3Width/2

end


local function init_tween()

    if mainState ~= mState.START then
        tweenOut.time = 0
        tweenOut.value = SCREEN.WIDTH/2
        tweenOut.distance = SCREEN.WIDTH
        tweenOut.duration = 0.5
    else
        tweenIn.time = 0
        tweenIn.value = -menuWidth
        tweenIn.distance = SCREEN.WIDTH/2 + menuWidth
        tweenIn.duration = 0.5
        tweenOut.time = 0
        tweenOut.value = SCREEN.WIDTH/2
        tweenOut.distance = SCREEN.WIDTH
        tweenOut.duration = 0.5
    end

end


function ui.reset_timer()

    timer = 0.6

end


function ui.set_state(pState)

    state = pState

end


local function check_mouse_pos()

    local x, y = love.mouse.getPosition( )

    if not isTweening then

        if state ~= menus.SFX and state ~= menus.MUSIC then
            if x > topButtonX and x < topButtonX + buttonWidth and y > topButtonY and y < topButtonY + buttonHeight then
                topIsLight = true
            else
                topIsLight = false
            end

        else

            topIsLight = false
            if x > arrowUpButtonX and x < arrowUpButtonX + arrowButtonWidth and y > arrowUpButtonY and y < arrowUpButtonY + arrowButtonHeight then
                arrowUpIsLight = true
            else
                arrowUpIsLight = false
            end

            if x > arrowDownButtonX and x < arrowDownButtonX + arrowButtonWidth and y > arrowDownButtonY and y < arrowDownButtonY + arrowButtonHeight then
                arrowDownIsLight = true
            else
                arrowDownIsLight = false
            end

            if x > numX and x < numX + number3Width and y > numY and y < numY + numberHeight then
                mouseIsOnNumber = true
            else
                mouseIsOnNumber = false
            end
        end

    end

    if x > midButtonX and x < midButtonX + buttonWidth and y > midButtonY and y < midButtonY + buttonHeight then
        middleIsLight = true
    else
        middleIsLight = false
    end

    if x > botButtonX and x < botButtonX + buttonWidth and y > botButtonY and y < botButtonY + buttonHeight then
        bottomIsLight = true
    else
        bottomIsLight = false
    end

end


function ui.get_gamepad_input(button)

    if isTweening then
        return
    end

    if button == "dpup" and gamePadPosY > 1 then
        if not (arrowDownIsLight or arrowUpIsLight) then
            gamePadPosY = gamePadPosY - 1
        end
    elseif button == "dpdown"  and gamePadPosY < 3 then
        gamePadPosY = gamePadPosY + 1
    elseif button == "dpleft" and gamePadPosX == 2 and gamePadPosY == 2 then
        gamePadPosX = 1
    elseif button == "dpright" and gamePadPosX == 1 and gamePadPosY == 2 then
        gamePadPosX = 2
    elseif button == "a" then
        ui.check_input_click()
    end

end


function ui.check_input_down(dt)

    if not arrowDownIsLight and not arrowUpIsLight then
        return
    end
  
    timer = timer - 1 * dt

    if timer <= 0 then

        if state == menus.SFX then
            if soundVolume < 100 and arrowUpIsLight then
                soundVolume = soundVolume + 1
                stereoChannel:push(sfx.scroll)
            end
            if soundVolume > 0 and arrowDownIsLight then
                soundVolume = soundVolume - 1
                stereoChannel:push(sfx.scroll)
            end
            sfxVolChannel:push(soundVolume)
        end

        if state == menus.MUSIC then
            if musicVolume < 100 and arrowUpIsLight then
                musicVolume = musicVolume + 1
                stereoChannel:push(sfx.scroll)
            end
            if musicVolume > 0 and arrowDownIsLight then
                musicVolume = musicVolume - 1
                stereoChannel:push(sfx.scroll)
            end
        end

    end

end


function ui.check_mouse_wheel(y)

    if not mouseIsOnNumber and not arrowDownIsLight and not arrowUpIsLight then
        return
    end

    if state == menus.SFX then
        if ((y > 0 and soundVolume < 100) or (y < 0 and soundVolume > 0)) and
                (not arrowDownIsLight and not arrowUpIsLight) then
            soundVolume = soundVolume + y
            stereoChannel:push(sfx.scroll)
        end
        if y > 0 and soundVolume < 100 and not arrowDownIsLight then
            soundVolume = soundVolume + y
            stereoChannel:push(sfx.scroll)
        end
        if y < 0 and soundVolume > 0 and not arrowUpIsLight then
            soundVolume = soundVolume + y
            stereoChannel:push(sfx.scroll)
        end
        sfxVolChannel:push(soundVolume)
    end

    if state == menus.MUSIC then
        if ((y > 0 and musicVolume < 100) or (y < 0 and musicVolume > 0)) and
                (not arrowDownIsLight and not arrowUpIsLight) then
            musicVolume = musicVolume + y
            stereoChannel:push(sfx.scroll)
        end
        if y > 0 and musicVolume < 100 and not arrowDownIsLight then
            musicVolume = musicVolume + y
            stereoChannel:push(sfx.scroll)
        end
        if y < 0 and musicVolume > 0 and not arrowUpIsLight then
            musicVolume = musicVolume + y
            stereoChannel:push(sfx.scroll)
        end
    end

end


function ui.check_input_release(button)

    if isTweening then
        return
    end

    if topIsLight and topIsClick then
        if state == menus.START then
            gamePadPosY = 1
            currentLevel = levels.TUTORIAL
            bufferState = menus.PAUSE
            topIsClick = false
            isTweening = true
            restart = true
            mainState = mState.PLAY
            stereoChannel:push(sfx.forward)
        elseif state == menus.PAUSE then
            gamePadPosY = 1
            topIsClick = false
            isTweening = true
            restart = false
            mainState = mState.PLAY
            stereoChannel:push(sfx.backward)
        elseif state == menus.SETTINGS then
            state = menus.SFX
            gamePadPosY = 2
            stereoChannel:push(sfx.forward)
        elseif state == menus.VICTORY then
            gamePadPosY = 1
            currentLevel = levels.MINE
            bufferState = menus.PAUSE
            topIsClick = false
            isTweening = true
            restart = true
            mainState = mState.PLAY
            stereoChannel:push(sfx.forward)
        end
        topIsClick = false
    else
        topIsClick = false
    end
    if middleIsLight and middleIsClick then
        if state == menus.START then
            gamePadPosY = 1
            currentLevel = levels.MINE
            bufferState = menus.PAUSE
            middleIsClick = false
            isTweening = true
            restart = true
            mainState = mState.PLAY
            stereoChannel:push(sfx.forward)
        elseif state == menus.PAUSE then
            state = menus.SETTINGS
            gamePadPosY = 1
            stereoChannel:push(sfx.forward)
        elseif state == menus.SETTINGS then
            state = menus.MUSIC
            gamePadPosY = 2
            stereoChannel:push(sfx.forward)
        elseif state == menus.VICTORY then
            gamePadPosY = 1
            currentLevel = levels.MINE
            bufferState = menus.START
            topIsClick = false
            isTweening = true
            restart = true
            mainState = mState.START
            stereoChannel:push(sfx.forward)
        end
        middleIsClick = false
    else
        middleIsClick = false
    end
    if bottomIsLight and bottomIsClick then
        if state == menus.START or state == menus.VICTORY then
            state = menus.QUIT
            stereoChannel:push(sfx.backward)
        elseif state == menus.PAUSE then
            state = menus.START
            gamePadPosY = 1
            stereoChannel:push(sfx.backward)
        elseif state == menus.SETTINGS then
            state = menus.PAUSE
            gamePadPosY = 2
            stereoChannel:push(sfx.backward)
        elseif state == menus.SFX then
            state = menus.SETTINGS
            gamePadPosY = 1
            stereoChannel:push(sfx.backward)
        elseif state == menus.MUSIC then
            state = menus.SETTINGS
            gamePadPosY = 2
            stereoChannel:push(sfx.backward)
        end
        bottomIsClick = false
        else
        bottomIsClick = false
    end
    if GAMEPAD ~= nil then
        if button == 'a' then
            if arrowUpIsLight then
                if state == menus.SFX and soundVolume < 100 then
                    soundVolume = soundVolume + 1
                    sfxVolChannel:push(soundVolume)
                elseif state == menus.MUSIC and musicVolume < 100 then
                    musicVolume = musicVolume + 1
                end
            end
            if arrowDownIsLight then
                if state == menus.SFX and soundVolume > 0 then
                    soundVolume = soundVolume - 1
                    sfxVolChannel:push(soundVolume)
                elseif state == menus.MUSIC and musicVolume > 0 then
                    musicVolume = musicVolume - 1
                end
            end
        end
    else
        if arrowUpIsLight then
            if state == menus.SFX and soundVolume < 100 then
                soundVolume = soundVolume + 1
                sfxVolChannel:push(soundVolume)
                stereoChannel:push(sfx.scroll)
            elseif state == menus.MUSIC and musicVolume < 100 then
                musicVolume = musicVolume + 1
                stereoChannel:push(sfx.scroll)
            end
        end
        if arrowDownIsLight then
            if state == menus.SFX and soundVolume > 0 then
                soundVolume = soundVolume - 1
                stereoChannel:push(sfx.scroll)
                sfxVolChannel:push(soundVolume)
            elseif state == menus.MUSIC and musicVolume > 0 then
                musicVolume = musicVolume - 1
                stereoChannel:push(sfx.scroll)
            end
        end
    end

end


function ui.check_input_click()

    if not isTweening then
        if topIsLight then
            topIsClick = true
        end
        if middleIsLight then
            middleIsClick = true
        end
        if bottomIsLight then
            bottomIsClick = true
        end
    end

end


function ui.load()

    mainState = mState.START
    init_tween()
    isTweening = true

    menuX = SCREEN.WIDTH/2
    menuY = SCREEN.HEIGHT/2
    topButtonX = menuX - buttonWidth/2
    topButtonY = menuY - buttonHeight * 1.5
    midButtonX = menuX - buttonWidth/2
    midButtonY = menuY - buttonHeight/2
    botButtonX = menuX - buttonWidth/2
    botButtonY = menuY + buttonHeight/2
    arrowDownButtonX = menuX - buttonWidth/2 + arrowButtonWidth * 1.5
    arrowDownButtonY = menuY - arrowButtonHeight/2
    arrowUpButtonX = menuX + buttonWidth/2 - arrowButtonWidth * 2.5
    arrowUpButtonY = menuY - arrowButtonHeight/2
    numX = menuX - number3Width/2
    numY = menuY - numberHeight/2

end


function ui.update(dt, st)

    if st == mState.END then
        state = menus.VICTORY
    end

    if state == menus.START then
        if isTweening then
            if mainState == mState.START then
                tween = easeOutSin(tweenIn.time, tweenIn.value,
                                   tweenIn.distance, tweenIn.duration)
                if tweenIn.time < tweenIn.duration then
                tweenIn.time = tweenIn.time + dt
                else
                    isTweening = false
                    mainState = mState.PLAY
                end
            else
                tween = easeOutSin(tweenOut.time, tweenOut.value,
                               tweenOut.distance, tweenOut.duration)
                if tweenOut.time < tweenOut.duration then
                    tweenOut.time = tweenOut.time + dt
                else
                    isTweening = false
                    state = bufferState
                    init_tween()
                    return return_parameters()
                end
            end
        end
    elseif state == menus.PAUSE or state == menus.VICTORY then
        if isTweening then
            tween = easeOutSin(tweenOut.time, tweenOut.value,
                                tweenOut.distance, tweenOut.duration)
            if tweenOut.time < tweenOut.duration then
                tweenOut.time = tweenOut.time + dt
            else
                isTweening = false
                state = bufferState
                init_tween()
                return return_parameters()
            end
        end
    elseif state == menus.QUIT then
        quitTimer = quitTimer - dt
        if quitTimer <= 0 then
            love.event.quit()
        end
    end
    update_menu_pos()

    if GAMEPAD ~= nil then
        if gamePadPosY == 1 then
            topIsLight = true
            middleIsLight = false
            bottomIsLight = false
            arrowDownIsLight = false
            arrowUpIsLight = false
        elseif gamePadPosY == 2 then
            if state == menus.SFX or state == menus.MUSIC then
                if gamePadPosX == 1 then
                    arrowDownIsLight = true
                    arrowUpIsLight = false
                else
                    arrowDownIsLight = false
                    arrowUpIsLight = true
                end
                bottomIsLight = false
            else
                topIsLight = false
                middleIsLight = true
                bottomIsLight = false
            end
        elseif gamePadPosY == 3 then
            topIsLight = false
            middleIsLight = false
            bottomIsLight = true
            arrowDownIsLight = false
            arrowUpIsLight = false
        end
        if GAMEPAD:isGamepadDown('a') then
            ui.check_input_down(dt)
            hasSetTimer = false
        else
            if not hasSetTimer then
                ui.reset_timer()
                hasSetTimer = true
            end
        end
    else
        check_mouse_pos()
        if love.mouse.isDown(1) then
            ui.check_input_down(dt)
            hasSetTimer = false
        else
            if not hasSetTimer then
                ui.reset_timer()
                hasSetTimer = true
            end
        end
    end
  
end


local function draw_buttons()

    love.graphics.draw(menu, menuX, menuY, 0, 1, 1, menuWidth/2, menuHeight/2)

    if state == menus.SFX or state == menus.MUSIC then
        love.graphics.draw(button, menuX, menuY - buttonHeight, 0, 1, 1,
                            buttonWidth/2, buttonHeight/2)
        if arrowDownIsLight then
            love.graphics.draw(arrowButtonLight, menuX - buttonWidth/2 + arrowButtonWidth * 2,
                          menuY, math.rad(180), 1, 1, arrowButtonWidth/2, arrowButtonHeight/2)
        else
            love.graphics.draw(arrowButton, menuX - buttonWidth/2 + arrowButtonWidth * 2,
                          menuY, math.rad(180), 1, 1, arrowButtonWidth/2, arrowButtonHeight/2)
        end

        if arrowUpIsLight then
            love.graphics.draw(arrowButtonLight, menuX + buttonWidth/2 - arrowButtonWidth * 2,
                          menuY, 0, 1, 1, arrowButtonWidth/2, arrowButtonHeight/2)
        else
          love.graphics.draw(arrowButton, menuX + buttonWidth/2 - arrowButtonWidth * 2,
                          menuY, 0, 1, 1, arrowButtonWidth/2, arrowButtonHeight/2)
        end

    else

        if topIsLight then
            if topIsClick then
                love.graphics.draw(buttonClick, menuX, menuY - buttonHeight, 0, 1, 1,   
                          buttonWidth/2, buttonHeight/2)
            else
                love.graphics.draw(buttonLight, menuX, menuY - buttonHeight, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
            end
        else
            love.graphics.draw(button, menuX, menuY - buttonHeight, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
        end

        if middleIsLight then
            if middleIsClick then
                love.graphics.draw(buttonClick, menuX, menuY, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
            else
                love.graphics.draw(buttonLight, menuX, menuY, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
            end
        else
            love.graphics.draw(button, menuX, menuY, 0, 1, 1, buttonWidth/2, buttonHeight/2)
        end

    end

    if bottomIsLight then
        if bottomIsClick then
            love.graphics.draw(buttonClick, menuX, menuY + buttonHeight, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
        else
          love.graphics.draw(buttonLight, menuX, menuY + buttonHeight, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
        end
    else
        love.graphics.draw(button, menuX, menuY + buttonHeight, 0, 1, 1,
                          buttonWidth/2, buttonHeight/2)
    end

end


local function draw_text()

    --draw text
    love.graphics.setColor(0, 0, 0, 1)

    if state == menus.START then
        love.graphics.printf(mesPlay, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1, playWidth/2, playHeight/2)
        love.graphics.printf(mesSkip, menuX, menuY, menuX,
                            "left", 0, 1, 1, skipWidth/2, skipHeight/2)
        love.graphics.printf(mesQuit, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, quitWidth/2, quitHeight/2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(mesTitle, SCREEN.WIDTH/2, SCREEN.HEIGHT/2 - menuHeight/2,
                            SCREEN.WIDTH/2, "center", 0, 1, 1, titleWidth/2, titleHeight/2)
    elseif state == menus.PAUSE then
        love.graphics.printf(mesResume, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1,resumeWidth/2, resumeHeight/2)
        love.graphics.printf(mesSet, menuX, menuY, menuX,
                            "left", 0, 1, 1, setWidth/2, setHeight/2)
        love.graphics.printf(mesStart, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, startWidth/2, startHeight/2)
    elseif state == menus.SETTINGS then
        love.graphics.printf(mesSound, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1, soundWidth/2, soundHeight/2)
        love.graphics.printf(mesMusic, menuX, menuY, menuX,
                            "left", 0, 1, 1, musicWidth/2, musicHeight/2)
        love.graphics.printf(mesBack, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, backWidth/2, backHeight/2)
    elseif state == menus.SFX then
        love.graphics.printf(mesVolume, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1, volumeWidth/2, volumeHeight/2)
        love.graphics.printf(mesBack, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, backWidth/2, backHeight/2)
    if soundVolume < 10 then
        love.graphics.print(tostring(soundVolume), menuX, menuY, 0, 1, 1,
                            number1Width/2, numberHeight/2)
    elseif soundVolume >= 10 and soundVolume < 100 then
        love.graphics.print(tostring(soundVolume), menuX, menuY, 0, 1, 1,
                            number2Width/2, numberHeight/2)
    elseif soundVolume > 99 then
        love.graphics.print(tostring(soundVolume), menuX, menuY, 0, 1, 1,
                            number3Width/2, numberHeight/2)
    end
    elseif state == menus.MUSIC then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(mesVolume, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1, volumeWidth/2, volumeHeight/2)
        love.graphics.printf(mesBack, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, backWidth/2, backHeight/2)
    if musicVolume < 10 then
        love.graphics.print(tostring(musicVolume), menuX, menuY, 0, 1, 1,
                            number1Width/2, numberHeight/2)
    elseif musicVolume >= 10 and musicVolume < 100 then
        love.graphics.print(tostring(musicVolume), menuX, menuY, 0, 1, 1,
                            number2Width/2, numberHeight/2)
    elseif musicVolume > 99 then
        love.graphics.print(tostring(musicVolume), menuX, menuY, 0, 1, 1,
                            number3Width/2, numberHeight/2)
    end
    elseif state == menus.VICTORY then
        love.graphics.printf(mesReplay, menuX, menuY - buttonHeight, menuX,
                            "left", 0, 1, 1, replayWidth/2, replayHeight/2)
        love.graphics.printf(mesStart, menuX, menuY, menuX,
                            "left", 0, 1, 1, startWidth/2, startHeight/2)
        love.graphics.printf(mesQuit, menuX, menuY + buttonHeight, menuX,
                            "left", 0, 1, 1, quitWidth/2, quitHeight/2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(mesVictory, SCREEN.WIDTH/2, SCREEN.HEIGHT/2 - menuHeight/2,
                            SCREEN.WIDTH/2, "left", 0, 1, 1, victoryWidth/2, victoryHeight/2)
    end

end


function ui.draw()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font)

    if state == menus.QUIT then
        love.graphics.printf(mesThanks, SCREEN.WIDTH/2, SCREEN.HEIGHT/2, SCREEN.WIDTH/2,
                            "center", 0, 1, 1, thanksWidth/2, thanksHeight/2)
        love.graphics.draw(logo, SCREEN.WIDTH/2, SCREEN.HEIGHT - logoHeight/2,
                            0, 0.5, 0.5, logoWidth/2, logoHeight/2)
        return
    end

    draw_buttons()
      
    draw_text()

end



return ui