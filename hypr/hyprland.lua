-- Hyprland 配置 (Lua, 0.57+)
-- 目标机器: MacBook Pro 2016 15" (MacBookPro14,2) - Intel HD530 + AMD Polaris
-- 由 hyprland.conf 迁移而来, 键位习惯参考仓库中 i3/config: $mod=Super(cmd⌘), vim 风格 hjkl, gaps 7/3

local mod = "SUPER"

------------------
---- 显示器 ----
------------------
-- Retina 2880x1800 缩放 1.2x; 如外接显示器在此追加:
--   hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 1.2,
})

-----------------------------
---- 环境变量 (输入法等) ----
-----------------------------
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
-- 2x 缩放下光标大小
hl.env("XCURSOR_SIZE", "24")
-- Electron 应用优先走 Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

------------------
---- 自启动 ----
------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("fcitx5 -d --replace")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    -- 剪贴板历史 (cliphist)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

------------------
---- 外观 ----
------------------
hl.config({
    general = {
        gaps_in  = 7,
        gaps_out = 3,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(7aa2f7ff)", "rgba(bb9af7ff)" }, angle = 45 },
            inactive_border = "rgba(3b4261aa)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = false,
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.97,
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
        },
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = 0x66000000,   -- rgba(00000066) = ARGB
        },
    },
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        disable_hyprland_logo = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        focus_on_activate = true,
    },
})

------------------
---- 动画 ----
------------------
hl.curve("easeOut", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3, bezier = "default" })

------------------
---- 输入 ----
------------------
-- Mac 键盘 (hid_apple): cmd⌘ -> Super, option⌥ -> Alt
hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            clickfinger_behavior = true,
            disable_while_typing = true,
        },
    },
})

-- 触摸板三指横滑切工作区
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- grim 截图免密码提示
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")

------------------
---- 快捷键 ----
------------------

-- --- 启动器 / 终端 ---
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd("fuzzel"))
-- 下拉终端 (对应 i3 的 tdrop)
hl.bind(mod .. " + grave", hl.dsp.exec_cmd("~/.config/hypr/script/dropterm.sh"))
-- 重启状态栏 (对应 i3 的 $mod+b)
hl.bind(mod .. " + B", hl.dsp.exec_cmd("~/.config/hypr/script/restart-waybar.sh"))

-- --- 常用应用 (对齐 i3: $mod+z/x/c/v; 未安装的应用按键无反应) ---
hl.bind(mod .. " + Z", hl.dsp.exec_cmd("jetbrains-toolbox"))
hl.bind(mod .. " + X", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("slack"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("feishu"))

-- --- 窗口 ---
hl.bind(mod .. " + Q", hl.dsp.window.close())                                        -- killactive
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))            -- fullscreen 0
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))     -- fullscreen 1
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float())                            -- i3: floating toggle
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))                                 -- i3: toggle split
hl.bind(mod .. " + W", hl.dsp.group.toggle())                                        -- ≈ i3: tabbed (分组)
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pseudo())                               -- Hyprland 特有 (i3 无对应)
-- 说明: i3 的 $mod+s (stacking) / $mod+space (focus mode_toggle) / $mod+a (focus parent)
--       在 Hyprland 无等价功能, 未绑定

-- --- 焦点移动 (vim 风格 + 方向键) ---
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- --- 移动窗口 ---
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- --- 工作区 1-10 ---
for i = 1, 10 do
    local key = i % 10   -- 10 映射到按键 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- 鼠标滚动切工作区
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- 下拉终端特殊工作区
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:dropterm" }))

-- --- 会话 ---
hl.bind(mod .. " + SHIFT + C", hl.dsp.reload_config())                -- hyprctl reload
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())                         -- hyprctl dispatch exit
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))

-- --- 音量备用键 (对齐 i3: $mod+Shift+= / - / . ; Touch Bar 黑屏时的主力音量键) ---
hl.bind(mod .. " + SHIFT + equal", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind(mod .. " + minus",         hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind(mod .. " + period",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))

-- --- 音量/亮度 (Mac 键盘 F10-F12; locked=锁屏时生效, repeating=长按重复) ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- --- 截图 (替代 flameshot) ---
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/script/screenshot.sh region"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd("~/.config/hypr/script/screenshot.sh full"))

-- --- 剪贴板历史 (i3 无对应; Super+C 已对齐 i3 留给 slack) ---
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("~/.config/hypr/script/clipboard.sh"))

------------------
---- 子模式 ----
------------------

-- i3 风格 window_split 模式: $mod+p 进入; j=水平分割, l=垂直分割
hl.bind(mod .. " + P", hl.dsp.submap("window_split"))
hl.define_submap("window_split", function()
    hl.bind("j", hl.dsp.layout("preselect r"))
    hl.bind("l", hl.dsp.layout("preselect d"))
    hl.bind("RETURN", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind(mod .. " + P", hl.dsp.submap("reset"))
end)

-- i3 风格 resize 模式: $mod+r 进入 (j/k/l/分号/方向键, 同 i3)
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local function rz(x, y)
        return hl.dsp.window.resize({ x = x, y = y, relative = true })
    end
    hl.bind("j",         rz(-40, 0),  { repeating = true })
    hl.bind("k",         rz(0, 40),   { repeating = true })
    hl.bind("l",         rz(0, -40),  { repeating = true })
    hl.bind("semicolon", rz(40, 0),   { repeating = true })
    hl.bind("left",      rz(-40, 0),  { repeating = true })
    hl.bind("down",      rz(0, 40),   { repeating = true })
    hl.bind("up",        rz(0, -40),  { repeating = true })
    hl.bind("right",     rz(40, 0),   { repeating = true })
    hl.bind("RETURN",    hl.dsp.submap("reset"))
    hl.bind("Escape",    hl.dsp.submap("reset"))
    hl.bind(mod .. " + R", hl.dsp.submap("reset"))
end)

------------------
---- 窗口规则 ----
------------------
hl.window_rule({
    name  = "float-copyq",
    match = { class = "^(copyq)$" },
    float = true,
})
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})
hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})
-- 下拉终端: 浮动 + 顶部 60% + 归入特殊工作区
hl.window_rule({
    name  = "dropterm",
    match = { class = "^(dropterm)$" },
    float = true,
    size  = "100% 60%",
    move  = "0 0",
    workspace = "special:dropterm silent",
})
