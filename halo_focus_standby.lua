-- Copyright (c) 2026. Jericho Crosby (Chalwk)
-- MIT License

local obs = obslua

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

local user32 = ffi.load("user32")
local kernel32 = ffi.load("kernel32")

local PROCESS_QUERY_LIMITED_INFORMATION = 0x1000

local SCENE_NAME = "GAMING"
local STANDBY_SOURCE = "Standby"
local TARGET_EXE = "haloce.exe"

local last_visible = nil

local function get_foreground_exe()
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
    local scene_source = obs.obs_get_source_by_name(SCENE_NAME)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    local item = obs.obs_scene_find_source_recursive(scene, STANDBY_SOURCE)

    if item ~= nil then
        obs.obs_sceneitem_set_visible(item, visible)
    end

    obs.obs_source_release(scene_source)
end

local function check_focus()
    local exe = get_foreground_exe()
    local show_standby = true

    if exe ~= nil and exe == TARGET_EXE then
        show_standby = false
    end

    if show_standby ~= last_visible then
        last_visible = show_standby
        set_standby_visible(show_standby)
    end
end

function script_description()
    return [[
Shows the Standby image whenever Halo CE (haloce.exe)
is not the active foreground window.
]]
end

function script_load()
    obs.timer_add(check_focus, 250)
    check_focus()
end

function script_unload()
    obs.timer_remove(check_focus)
end
