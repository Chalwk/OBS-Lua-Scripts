-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

local SCENE_NAME = "GAMING"
local MIC_SOURCE_NAME = "MIC/AUX" -- set to "" to disable mic muting
local DESKTOP_SOURCE_NAME = ""    -- set to "" to disable desktop muting

local SPLASH_SOURCES = { "Starting Soon", "Be Right Back", "Stream Ended" }

local last_mic_muted = nil
local last_desktop_muted = nil

local function update_mic_mute()
    local scene_source = obs.obs_get_source_by_name(SCENE_NAME)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)

    local any_splash_visible = false
    for _, name in ipairs(SPLASH_SOURCES) do
        local item = obs.obs_scene_find_source_recursive(scene, name)
        if item ~= nil and obs.obs_sceneitem_visible(item) then
            any_splash_visible = true
            break
        end
    end

    obs.obs_source_release(scene_source)

    local should_mute = any_splash_visible

    ---@diagnostic disable-next-line: unnecessary-if
    if MIC_SOURCE_NAME ~= "" then
        local mic_source = obs.obs_get_source_by_name(MIC_SOURCE_NAME)
        if mic_source then
            if should_mute ~= last_mic_muted then
                last_mic_muted = should_mute
                obs.obs_source_set_muted(mic_source, should_mute)
            end
            obs.obs_source_release(mic_source)
        end
    else
        last_mic_muted = nil
    end

    ---@diagnostic disable-next-line: unnecessary-if
    if DESKTOP_SOURCE_NAME ~= "" then
        local desktop_source = obs.obs_get_source_by_name(DESKTOP_SOURCE_NAME)
        if desktop_source then
            if should_mute ~= last_desktop_muted then
                last_desktop_muted = should_mute
                obs.obs_source_set_muted(desktop_source, should_mute)
            end
            obs.obs_source_release(desktop_source)
        end
    else
        last_desktop_muted = nil
    end
end

function script_description()
    return [[
Mutes "MIC/AUX" and "DESKTOP" while any splash screen ("Starting Soon",
"Be Right Back", or "Stream Ended") is visible inside the GAMING scene.
]]
end

function script_load()
    obs.timer_add(update_mic_mute, 250)
    update_mic_mute()
end

function script_unload()
    obs.timer_remove(update_mic_mute)
end
