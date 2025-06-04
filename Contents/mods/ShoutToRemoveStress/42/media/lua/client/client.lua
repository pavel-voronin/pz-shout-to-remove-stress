-- imports
local config = require("options")
local fierceMoodle = require("fierceMoodle")
local sound = require("sound")

-- constants

local DEFAULT_SHOUT_BINDING_DELAY = 450
local EMOTE_REPEAT_INTERVAL = 500
local TARZAN_YELL_MESSAGE = "AAAAHHH!!!"
local HOLD_THRESHOLD = 2000
local RADIUS = 50
local VOLUME = 50
local MALE_SOUNDS = {"man_scream1"}
local FEMALE_SOUNDS = {"woman_scream1"}

-- working variables

local defaultShoutStartTime = nil
local fierceUntilGameMinute = 0
local lastEmoteTime = 0
local keyHoldStartTime = nil
local tarzanYelled = false

-- utils

local function isTarzanYellKey(key)
    return key == config.tarzanYellKey
end

local function getGameMinutes()
    return getGameTime():getMinutesStamp()
end

local function getRealMilliseconds()
    return getTimestampMs()
end

-- domain

local function wasItShout()
    return defaultShoutStartTime ~= nil and getRealMilliseconds() - defaultShoutStartTime < DEFAULT_SHOUT_BINDING_DELAY
end

local function wasItStrongEnough()
    return not getPlayer():isSneaking()
end

local function wasItInTime()
    if not getPlayer():isAlive() then
        return false
    end

    return getGameMinutes() >= fierceUntilGameMinute
end

local function stressRelief(amount, cooldown)
    local stats = getPlayer():getStats()
    local currentStress = stats:getStress()
    local newStress = math.max(0, currentStress - amount)
    stats:setStress(newStress)

    fierceUntilGameMinute = getGameMinutes() + cooldown
    fierceMoodle.BecomeFierce()
end

local function getRandomSound()
    local isFemale = getPlayer():isFemale()
    local list = isFemale and FEMALE_SOUNDS or MALE_SOUNDS
    local idx = ZombRand(#list) + 1
    return list[idx]
end

local function repeatEmote(emote, interval)
    local now = getRealMilliseconds()

    if now - lastEmoteTime > interval then
        getPlayer():playEmote(emote)
        lastEmoteTime = now
    end
end

-- events

local function onKeyStartPressed(key)
    if isKeyPressed("Shout") then
        defaultShoutStartTime = getRealMilliseconds()
    elseif isTarzanYellKey(key) and getPlayer():isCanShout() then
        sound.stop()
        sound.play(getRandomSound())

        setGameSpeed(1.0)
        getPlayer():playEmote("shout")
        getPlayer():addWorldSoundUnlessInvisible(RADIUS, VOLUME, true)
        getPlayer():SayShout(TARZAN_YELL_MESSAGE)
        keyHoldStartTime = getRealMilliseconds()
        tarzanYelled = false
    end
end

local function onKeyKeepPressed(key)
    if isTarzanYellKey(key) then
        local now = getRealMilliseconds()

        if not tarzanYelled and keyHoldStartTime and (now - keyHoldStartTime > HOLD_THRESHOLD) then
            if getGameMinutes() >= fierceUntilGameMinute then
                stressRelief(SandboxVars.ShoutToRemoveStress.TarzanYellReliefAmount,
                    SandboxVars.ShoutToRemoveStress.TarzanYellCooldown)
            end

            tarzanYelled = true
        end

        repeatEmote("shout", EMOTE_REPEAT_INTERVAL)
    end
end

local function onPlayerUpdate()
    if getGameMinutes() >= fierceUntilGameMinute then
        fierceMoodle.NotFierceAnymore()
    else
        local gameMinutesLeft = fierceUntilGameMinute - getGameMinutes()
        fierceMoodle.SetFierceDescription(gameMinutesLeft .. " min. remain")
    end
end

local function onKeyPressed(key)
    if wasKeyDown("Shout") and not isKeyDown("Shout") then
        if wasItShout() and wasItStrongEnough() and wasItInTime() then
            stressRelief(SandboxVars.ShoutToRemoveStress.DefaultShoutReliefAmount,
                SandboxVars.ShoutToRemoveStress.DefaultShoutCooldown)
        end
    elseif isTarzanYellKey(key) then
        if sound.isPlaying() then
            sound.fade()
        end
        keyHoldStartTime = nil
        tarzanYelled = false
    end
end

Events.OnKeyPressed.Add(onKeyPressed)
Events.OnKeyStartPressed.Add(onKeyStartPressed)
Events.OnKeyKeepPressed.Add(onKeyKeepPressed)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
