-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

local SCENE_NAME = "GAMING"
local WEBCAM_SOURCE = "Webcam"
local NO_WEBCAM_SOURCE = "No Webcam"

local last_no_webcam_visible = nil

local function check_webcam()
    local scene_source = obs.obs_get_source_by_name(SCENE_NAME)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    local webcam_item = obs.obs_scene_find_source_recursive(scene, WEBCAM_SOURCE)
    local no_webcam_item = obs.obs_scene_find_source_recursive(scene, NO_WEBCAM_SOURCE)

    if webcam_item ~= nil and no_webcam_item ~= nil then
        local webcam_visible = obs.obs_sceneitem_visible(webcam_item)
        local show_no_webcam = not webcam_visible

        if show_no_webcam ~= last_no_webcam_visible then
            last_no_webcam_visible = show_no_webcam
            obs.obs_sceneitem_set_visible(no_webcam_item, show_no_webcam)
        end
    end

    obs.obs_source_release(scene_source)
end

function script_description()
    return [[
When the "Webcam" source in the GAMING scene is hidden,
the "No Webcam" image becomes visible.
]]
end

function script_load()
    obs.timer_add(check_webcam, 250)
    check_webcam()
end

function script_unload()
    obs.timer_remove(check_webcam)
end