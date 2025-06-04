local soundModule = {}

local FADE_OUT_TIME = 150

soundModule.fadeStartTime = nil
soundModule.soundHandle = nil

soundModule.isPlaying = function()
    return soundModule.soundHandle and getPlayer():getEmitter():isPlaying(soundModule.soundHandle)
end

soundModule.stop = function()
    Events.OnPlayerUpdate.Remove(fadeListener)

    if soundModule.isPlaying() then
        getPlayer():getEmitter():stopSound(soundModule.soundHandle)
    end

    soundModule.soundHandle = nil
    soundModule.fadeStartTime = nil
end

soundModule.play = function(sound)
    soundModule.soundHandle = getPlayer():playSound(sound)
    soundModule.fadeStartTime = nil
end

soundModule.volume = function(vol)
    if soundModule.soundHandle then
        getPlayer():getEmitter():setVolume(soundModule.soundHandle, vol)
    end
end

-- private
local function fadeListener()
    if soundModule.fadeStartTime and soundModule.isPlaying() then
        local elapsed = getTimestampMs() - soundModule.fadeStartTime
        local fade = math.max(0, 1 - (elapsed / FADE_OUT_TIME))
        soundModule.volume(fade)

        if fade > 0 then
            return
        end
    end

    soundModule.stop()
    Events.OnPlayerUpdate.Remove(fadeListener)
end

soundModule.fade = function()
    soundModule.fadeStartTime = getTimestampMs()
    Events.OnPlayerUpdate.Add(fadeListener)
end

return soundModule

