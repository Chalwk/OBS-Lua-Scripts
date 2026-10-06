-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

local POLL_INTERVAL_MS = 250

-- Configured via script properties (Tools -> Scripts)
local scene_name = ""
local mic_source_name = ""
local desktop_source_name = ""
local splash_sources = {}

local last_mic_muted = nil
local last_desktop_muted = nil

-- Retrieve an editable string list from obs_data settings.
local function get_string_list(settings, name)
    local result = {}
    local array = obs.obs_data_get_array(settings, name)
    if array == nil then return result end

    local count = obs.obs_data_array_count(array)
    for i = 0, count - 1 do
        local item = obs.obs_data_array_item(array, i)
        local value = obs.obs_data_get_string(item, "value")
        if value ~= nil and value ~= "" then
            table.insert(result, value)
        end
        obs.obs_data_release(item)
    end

    obs.obs_data_array_release(array)
    return result
end

-- Set defaults for an editable string list.
local function set_default_string_list(settings, name, values)
    local array = obs.obs_data_array_create()
    for _, v in ipairs(values) do
        local item = obs.obs_data_create()
        obs.obs_data_set_string(item, "value", v)
        obs.obs_data_array_push_back(array, item)
        obs.obs_data_release(item)
    end
    obs.obs_data_set_default_array(settings, name, array)
    obs.obs_data_array_release(array)
end

local function any_splash_visible(scene)
    for _, name in ipairs(splash_sources) do
        local item = obs.obs_scene_find_source_recursive(scene, name)
        if item ~= nil and obs.obs_sceneitem_visible(item) then
            return true
        end
    end
    return false
end

local function update_mute()
    if scene_name == "" then return end
    if #splash_sources == 0 then return end

    local scene_source = obs.obs_get_source_by_name(scene_name)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    local should_mute = false

    if scene ~= nil then
        should_mute = any_splash_visible(scene)
    end

    obs.obs_source_release(scene_source)

    -- Microphone
    if mic_source_name ~= "" then
        local mic = obs.obs_get_source_by_name(mic_source_name)
        if mic ~= nil then
            if should_mute ~= last_mic_muted then
                last_mic_muted = should_mute
                obs.obs_source_set_muted(mic, should_mute)
            end
            obs.obs_source_release(mic)
        end
    else
        last_mic_muted = nil
    end

    -- Desktop audio
    if desktop_source_name ~= "" then
        local desktop = obs.obs_get_source_by_name(desktop_source_name)
        if desktop ~= nil then
            if should_mute ~= last_desktop_muted then
                last_desktop_muted = should_mute
                obs.obs_source_set_muted(desktop, should_mute)
            end
            obs.obs_source_release(desktop)
        end
    else
        last_desktop_muted = nil
    end
end

function script_description()
    return [[
Mutes one or more audio sources while any configured splash source is
visible in the scene. Useful for automatically muting your microphone during
"Starting Soon", "Be Right Back", or "Stream Ended" screens.

Leave the microphone or desktop field empty to disable muting for that
channel. Add or remove splash sources in the list below.
]]
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "scene_name", "Scene name:", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(
        props, "mic_source", "Microphone source (leave blank to disable):", obs.OBS_TEXT_DEFAULT
    )
    obs.obs_properties_add_text(
        props, "desktop_source", "Desktop audio source (leave blank to disable):", obs.OBS_TEXT_DEFAULT
    )
    obs.obs_properties_add_editable_list(
        props, "splash_sources", "Splash sources (one per line):", obs.OBS_EDITABLE_LIST_TYPE_STRINGS, nil, nil
    )

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "scene_name", "")
    obs.obs_data_set_default_string(settings, "mic_source", "Mic/Aux")
    obs.obs_data_set_default_string(settings, "desktop_source", "")
    set_default_string_list(settings, "splash_sources", {
        "Starting Soon",
        "Be Right Back",
        "Stream Ended"
    })
end

function script_update(settings)
    scene_name = obs.obs_data_get_string(settings, "scene_name")
    mic_source_name = obs.obs_data_get_string(settings, "mic_source")
    desktop_source_name = obs.obs_data_get_string(settings, "desktop_source")
    splash_sources = get_string_list(settings, "splash_sources")

    last_mic_muted = nil
    last_desktop_muted = nil
end

function script_load(settings)
    script_update(settings)
    obs.timer_add(update_mute, POLL_INTERVAL_MS)
    update_mute()
end

function script_unload()
    obs.timer_remove(update_mute)
end
