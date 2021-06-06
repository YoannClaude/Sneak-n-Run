local audioSystem = {}

                            ------------------------------------
                            
require "love.system"
require "modules.utils"
require "modules.globals"

local fmod
local os = love.system.getOS( )
local sourceDirectory = love.filesystem.getSourceBaseDirectory()

if os == "Windows" then
    fmod = require("fmodlove")
else
    local cpath = package.cpath
    if os == "Linux" then
        package.cpath = string.format("%s/fmod/linux/?.so;%s",
                        sourceDirectory,sourceDirectory,cpath)
    elseif os == "OS X" then
        package.cpath = string.format("%s/fmod/macos/?.dylib;%s",
                        sourceDirectory,sourceDirectory,cpath)
    end
    fmod = require("libfmodlove")
end

fmod.init(0, 32, 128, 1)
fmod.setNumListeners(1)
local bankPath = sourceDirectory.."/fmod/banks/Desktop/"
local bank = {
    masterBank = fmod.loadBank(bankPath.."Master.bank", 0),
    masterStringBank = fmod.loadBank(bankPath.."Master.strings.bank", 0),
    musicBank = fmod.loadBank(bankPath.."Music.bank", 0),
    sfxBank = fmod.loadBank(bankPath.."SFX.bank", 0),
    uiBank = fmod.loadBank(bankPath.."UI.bank", 0),
    ambientBank = fmod.loadBank(bankPath.."Ambient.bank", 0)
        }
local instance = {
    music = fmod.createInstance("event:/Music/MainSystem"),
    passive = fmod.createInstance("event:/Music/Passive"),
    siren = fmod.createInstance("event:/Ambient/Siren")
        }
local bus = {
    master = fmod.getBus("bus:/Global"),
    music = fmod.getBus("bus:/Global/Music"),
    sfx = fmod.getBus("bus:/Global/SFX"),
    ambient = fmod.getBus("bus:/Global/Ambient"),
    ui = fmod.getBus("bus:/Global/UI")
    }
local playerFootsteps = "event:/SFX/Player/Footsteps"

local monoChannel = love.thread.getChannel("monoSfx")
local stereoChannel = love.thread.getChannel("stereoSfx")
local playerChannel = love.thread.getChannel("player")
local loPassChannel = love.thread.getChannel("loPass")
local hiPassChannel = love.thread.getChannel("hiPass")
local sirenChannel = love.thread.getChannel("siren")
local musicVolChannel = love.thread.getChannel("musicVol")
local sfxVolChannel = love.thread.getChannel("sfxVol")
local masterVolChannel = love.thread.getChannel("masterVol")
local musicChannel = love.thread.getChannel("music")
local stateChannel = love.thread.getChannel("state")
local quitChannel = love.thread.getChannel("quit")
local updateChannel = love.thread.getChannel("posUpdate")

local running = true

local instanceTest = fmod.createInstance("event:/SFX/Arrow/Stone")

local function play_mono_sfx(obj, param, event)
    
    if obj == sType.GUARD then
        fmod.setGlobalParameterByName("GuardDistance", param)
    elseif obj == sType.BAT then
        fmod.setGlobalParameterByName("BatDistance", param)
    elseif obj == sType.SPELL then
        fmod.setGlobalParameterByName("SpellDistance", param)
    elseif obj == sType.DOOR then
        fmod.setGlobalParameterByName("DoorDistance", param)
    elseif obj == sType.TRAP then
        fmod.setGlobalParameterByName("TrapDistance", param)
    elseif obj == sType.ARROW then
        fmod.setGlobalParameterByName("ArrowDistance", param)
    end
    fmod.playOneShot2D(event)
    
end


local function play_stereo_sfx(event)
    
    fmod.playOneShot2D(event)
    
end


local function play_siren()
   
   if not fmod.isPlaying(instance.siren) then
       fmod.startInstance(instance.siren)
   end
    
end


local function play_player_footsteps(state, loud)
    
    if state == pState.WALKING then
        fmod.setGlobalParameterByName("playerAction", 0)
    elseif state ==pState.RUNNING then
        fmod.setGlobalParameterByName("playerAction", 1)
    elseif state == pState.SNEAKING then
        fmod.setGlobalParameterByName("playerAction", 2)
    end
    
    if loud then
        fmod.setGlobalParameterByName("playerLoud", 1)
    else
        fmod.setGlobalParameterByName("playerLoud", 0)
    end
    
    fmod.playOneShot2D(playerFootsteps)
    
end


local function update_sound_pos(obj, distance)
   
    if obj == sType.SPELL then
        fmod.setGlobalParameterByName("SpellDistance", distance)
    end

end


local function set_hiPass(bool)
    
    if bool then
        fmod.setGlobalParameterByName("hiPass", 1)
    else
        fmod.setGlobalParameterByName("hiPass", 0)
    end
    
end


local function set_loPass(bool)
    
    if bool then
        fmod.setGlobalParameterByName("loPass", 1)
    else
        fmod.setGlobalParameterByName("loPass", 0)
    end
    
end


local function set_sfx_volume(vol)

    local volume = vol / 100
    fmod.setBusVolume(bus.sfx, volume)
    fmod.setBusVolume(bus.ui, volume)
    fmod.setBusVolume(bus.ambient, volume)

end


local function set_music_volume(vol)

    local volume = vol / 100
    fmod.setBusVolume(bus.music, volume)

end


local function set_master_volume(vol)
    
    fmod.setBusVolume(bus.master, vol)

end


local function play_music(bool)
    
    if bool then
        fmod.startInstance(instance.music)
    else
        fmod.stopInstance(instance.music, 1)
    end
    
end


local function set_state(state)

    local value
    if state == gState.PASSIVE then
        value = 0
    elseif state == gState.SUSPICIOUS then
        value = 1
    elseif state == gState.ACTIVE then
        value = 2
    end
    
    fmod.setGlobalParameterByName("State", value)

end


local function shutdown()
    
    for i=1, #instance do
        local instanceId = instance[i]
        fmod.stopInstance(instanceId, 1)
    end
    
    for i=1, #bank do
        local bankId = bank[i]
        fmod.unloadBank(bankId)
    end
    
    running = false
    
end


while running do
    
    fmod.update()
    
    local monoSfx = monoChannel:pop()
    if monoSfx then
        play_mono_sfx(monoSfx.obj, monoSfx.param, monoSfx.event)
    end
    
    local stereoSfx = stereoChannel:pop()
    if stereoSfx then
        play_stereo_sfx(stereoSfx)
    end
    
    local footsteps = playerChannel:pop()
    if footsteps then
        play_player_footsteps(footsteps.action, footsteps.loud)
    end
    
    local hiPass = hiPassChannel:pop()
    if hiPass then
        set_hiPass(hiPass.value)
    end
    
    local loPass = loPassChannel:pop()
    if loPass then
        set_loPass(loPass.value)
    end
    
    local update = updateChannel:pop()
    if update then
        update_sound_pos(update.obj, update.param)
    end
    
    local musicVol = musicVolChannel:pop()
    if musicVol then
        set_music_volume(musicVol)
    end
    
    local sfxVol = sfxVolChannel:pop()
    if sfxVol then
        set_sfx_volume(sfxVol)
    end
    
    local masterVol = masterVolChannel:pop()
    if masterVol then
        set_master_volume(masterVol)
    end
    
    local music = musicChannel:pop()
    if music then
        play_music(music.play)
    end
    
    local siren = sirenChannel:pop()
    if siren then
        play_siren()
    end
    
    local state = stateChannel:pop()
    if state then
        set_state(state)
    end
    
    local quit = quitChannel:pop()
    if quit then
        shutdown()
    end
    
end

quitChannel:supply(true)
                        ---------------------------------------
                            
return audioSystem