-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

local SCENE_NAME = "GAMING"
local WEBCAM_SOURCE = "Webcam"
local NO_WEBCAM_SOURCE = "No Webcam"

local last_webcam_visible = nil
local last_no_webcam_visible = nil

local function check_webcam()
    local scene_source = obs.obs_get_source_by_name(SCENE_NAME)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    local webcam_item = obs.obs_scene_find_source_recursive(scene, WEBCAM_SOURCE)
    local no_webcam_item = obs.obs_scene_find_source_recursive(scene, NO_WEBCAM_SOURCE)

    if webcam_item == nil or no_webcam_item == nil then
        obs.obs_source_release(scene_source)
        return
    end

    local webcam_visible = obs.obs_sceneitem_visible(webcam_item)
    local no_webcam_visible = obs.obs_sceneitem_visible(no_webcam_item)

    if last_webcam_visible == nil then
        last_webcam_visible = webcam_visible
        last_no_webcam_visible = no_webcam_visible
    end

    if not webcam_visible and not no_webcam_visible then
        if not no_webcam_visible then
            obs.obs_sceneitem_set_visible(no_webcam_item, true)
            no_webcam_visible = true
        end
    else
        local webcam_just_on = not last_webcam_visible and webcam_visible
        local no_webcam_just_on = not last_no_webcam_visible and no_webcam_visible

        if webcam_just_on then
            if no_webcam_visible then
                obs.obs_sceneitem_set_visible(no_webcam_item, false)
                no_webcam_visible = false
            end
        elseif no_webcam_just_on then
            if webcam_visible then
                obs.obs_sceneitem_set_visible(webcam_item, false)
                webcam_visible = false
            end
        elseif webcam_visible and no_webcam_visible then
            obs.obs_sceneitem_set_visible(no_webcam_item, false)
            no_webcam_visible = false
        end
    end

    last_webcam_visible = webcam_visible
    last_no_webcam_visible = no_webcam_visible

    obs.obs_source_release(scene_source)
end

function script_description()
    return [[
Ensures "Webcam" and "No Webcam" are never visible at the same time.
- If webcam is turned on, the fallback is hidden.
- If fallback is turned on, the webcam is hidden.
- If both are off, the fallback is shown.
]]
end

function script_load()
    obs.timer_add(check_webcam, 250)
    check_webcam()
end

function script_unload()
    obs.timer_remove(check_webcam)
end
