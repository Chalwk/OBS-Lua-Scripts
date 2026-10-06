-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

local POLL_INTERVAL_MS = 250

-- Configured via script properties (Tools -> Scripts)
local scene_name = ""
local webcam_source_name = ""
local fallback_source_name = ""

local last_webcam_visible = nil
local last_fallback_visible = nil

local function check_webcam()
    if scene_name == "" or webcam_source_name == "" or fallback_source_name == "" then
        return
    end

    local scene_source = obs.obs_get_source_by_name(scene_name)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    if scene == nil then
        obs.obs_source_release(scene_source)
        return
    end

    local webcam_item = obs.obs_scene_find_source_recursive(scene, webcam_source_name)
    local fallback_item = obs.obs_scene_find_source_recursive(scene, fallback_source_name)

    if webcam_item == nil or fallback_item == nil then
        obs.obs_source_release(scene_source)
        return
    end

    local webcam_visible = obs.obs_sceneitem_visible(webcam_item)
    local fallback_visible = obs.obs_sceneitem_visible(fallback_item)

    -- First run: adopt the current state and do nothing.
    if last_webcam_visible == nil then
        last_webcam_visible = webcam_visible
        last_fallback_visible = fallback_visible
        obs.obs_source_release(scene_source)
        return
    end

    local webcam_just_on = (not last_webcam_visible) and webcam_visible
    local fallback_just_on = (not last_fallback_visible) and fallback_visible

    if webcam_just_on then
        -- Webcam just turned on: hide the fallback.
        if fallback_visible then
            obs.obs_sceneitem_set_visible(fallback_item, false)
            fallback_visible = false
        end
    elseif fallback_just_on then
        -- Fallback just turned on: hide the webcam.
        if webcam_visible then
            obs.obs_sceneitem_set_visible(webcam_item, false)
            webcam_visible = false
        end
    elseif webcam_visible and fallback_visible then
        -- Both visible with no fresh toggle: webcam wins.
        obs.obs_sceneitem_set_visible(fallback_item, false)
        fallback_visible = false
    elseif not webcam_visible and not fallback_visible then
        -- Both off: show the fallback.
        obs.obs_sceneitem_set_visible(fallback_item, true)
        fallback_visible = true
    end

    last_webcam_visible = webcam_visible
    last_fallback_visible = fallback_visible

    obs.obs_source_release(scene_source)
end

function script_description()
    return [[
Keeps a webcam source and a fallback image from being visible at the same
time.

- If the webcam turns on, the fallback is hidden.
- If the fallback turns on, the webcam is hidden.
- If both are off, the fallback is shown automatically.

Lets you toggle your webcam on and off in OBS without juggling overlays.
Configure the scene and both source names below.
]]
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "scene_name", "Scene name:", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "webcam_source", "Webcam source name:", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(
        props, "fallback_source", "Fallback source name (shown when webcam is off):", obs.OBS_TEXT_DEFAULT
    )

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "scene_name", "")
    obs.obs_data_set_default_string(settings, "webcam_source", "")
    obs.obs_data_set_default_string(settings, "fallback_source", "")
end

function script_update(settings)
    scene_name = obs.obs_data_get_string(settings, "scene_name")
    webcam_source_name = obs.obs_data_get_string(settings, "webcam_source")
    fallback_source_name = obs.obs_data_get_string(settings, "fallback_source")

    last_webcam_visible = nil
    last_fallback_visible = nil
end

function script_load(settings)
    script_update(settings)
    obs.timer_add(check_webcam, POLL_INTERVAL_MS)
    check_webcam()
end

function script_unload()
    obs.timer_remove(check_webcam)
end
