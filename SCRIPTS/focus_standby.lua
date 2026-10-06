-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua
---@diagnostic disable-next-line: unresolved-require
local ffi = require("ffi")

ffi.cdef [[
typedef void* HANDLE;
typedef void* HWND;
typedef unsigned long DWORD;
typedef int BOOL;

HWND GetForegroundWindow(void);
DWORD GetWindowThreadProcessId(HWND hWnd, DWORD *lpdwProcessId);
HANDLE OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId);
BOOL QueryFullProcessImageNameA(HANDLE hProcess, DWORD dwFlags, char *lpExeName, DWORD *lpdwSize);
BOOL CloseHandle(HANDLE hObject);
]]

-- Attempt to load Win32 libraries. On non-Windows systems this will fail and
-- the script becomes a no-op instead of throwing errors into the OBS log.
local user32, kernel32
local win32_available = pcall(function ()
    user32 = ffi.load("user32")
    kernel32 = ffi.load("kernel32")
end)

local PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
local POLL_INTERVAL_MS = 250

-- Configured via script properties (Tools -> Scripts)
local scene_name = ""
local standby_source_name = ""
local target_exe = ""

local last_standby_visible = nil

local function get_foreground_exe()
    if not win32_available then return nil end

    local hwnd = user32.GetForegroundWindow()
    if hwnd == nil then return nil end

    local pid = ffi.new("DWORD[1]", 0)
    user32.GetWindowThreadProcessId(hwnd, pid)

    local process = kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, pid[0])
    if process == nil then return nil end

    local buffer = ffi.new("char[1024]")
    local size = ffi.new("DWORD[1]", 1024)
    local success = kernel32.QueryFullProcessImageNameA(process, 0, buffer, size)
    kernel32.CloseHandle(process)

    if success == 0 then return nil end

    local path = ffi.string(buffer, size[0])
    local exe = path:match("([^\\/]+)$")
    if exe then return exe:lower() end
    return nil
end

local function set_standby_visible(visible)
    local scene_source = obs.obs_get_source_by_name(scene_name)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    if scene ~= nil then
        local item = obs.obs_scene_find_source_recursive(scene, standby_source_name)
        if item ~= nil then
            obs.obs_sceneitem_set_visible(item, visible)
        end
    end

    obs.obs_source_release(scene_source)
end

local function check_focus()
    if not win32_available then return end
    if scene_name == "" or standby_source_name == "" or target_exe == "" then return end

    local exe = get_foreground_exe()
    local show_standby = (exe == nil) or (exe ~= target_exe)

    if show_standby ~= last_standby_visible then
        last_standby_visible = show_standby
        set_standby_visible(show_standby)
    end
end

function script_description()
    return [[
Shows a standby source whenever a specified game executable is NOT the
foreground window.

Useful for automatically switching away from a game view when you alt-tab
to another application, and back again when you return.

Windows only. Configure the scene, source, and executable below.
]]
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(
        props, "scene_name", "Scene name (containing the standby source):", obs.OBS_TEXT_DEFAULT
    )
    obs.obs_properties_add_text(props, "standby_source", "Standby source name:", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "target_exe", "Target executable (e.g. game.exe):", obs.OBS_TEXT_DEFAULT)

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "scene_name", "")
    obs.obs_data_set_default_string(settings, "standby_source", "")
    obs.obs_data_set_default_string(settings, "target_exe", "")
end

function script_update(settings)
    scene_name = obs.obs_data_get_string(settings, "scene_name")
    standby_source_name = obs.obs_data_get_string(settings, "standby_source")
    target_exe = obs.obs_data_get_string(settings, "target_exe"):lower()
    last_standby_visible = nil
end

function script_load(settings)
    script_update(settings)
    obs.timer_add(check_focus, POLL_INTERVAL_MS)
    check_focus()
end

function script_unload()
    obs.timer_remove(check_focus)
end
