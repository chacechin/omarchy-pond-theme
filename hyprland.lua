-- Pond: niri focus ring (border off), 12px window corners (geometry-corner-radius 12).
-- niri draws the ring only around the active window; its inactive-color is for
-- the active window on an unfocused monitor. So unfocused windows get no outline.
local active_border_color = "rgba(8a8a8a99)"
local inactive_border_color = "rgba(00000000)"

hl.config({
  general = {
    -- The near-transparent bar's 30px strip already reads as margin, so the
    -- usual 10px top gap made the space under it look doubled. Top gap 0
    -- leaves bar-icons-to-window spacing about equal to the other sides.
    gaps_out = { top = 0, right = 10, bottom = 10, left = 10 },
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },
  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
  decoration = {
    rounding = 12,
    rounding_power = 2,
  },
})

-- Glass: frost the shell's floating surfaces. ignore_alpha 0.5 skips the
-- 0.4 scrims and soft shadows so only the 0.62-alpha cards are blurred.
-- The bar keeps its own blur rule from hypr/looknfeel.lua.
hl.layer_rule({
  match = { namespace = "^(omarchy-(keyboard-panel|menu|notifications|osd|polkit|clipboard|emojis|reminders)|oma-cast)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.5,
})

-- Pond motion (config/niri/shell/animation.kdl + shell PanelStyle):
-- 200ms ease-out-quad window open, 200ms ease-out-cubic close (not linear),
-- critically damped springs for movement/workspaces ~ emphasized decelerate
-- [0.2, 0, 0, 1], vertical workspace slide (matches the sidebar map), 220ms panel fade.
-- Hyprland speed unit = 100ms. OmaControl writes its own animations and
-- rounding (16) after the theme loads, so these are (re)applied once the whole
-- config has loaded. Window radius is Pond's geometry-corner-radius 12.
local function pond_motion()
  hl.curve("pondEaseOutQuad", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
  hl.curve("pondEaseOutCubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })
  hl.curve("pondEmphasized", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
  hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "pondEaseOutQuad", style = "popin 90%" })
  hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "pondEaseOutCubic", style = "popin 90%" })
  hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "pondEmphasized" })
  hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "pondEmphasized", style = "slidevert" })
  hl.animation({ leaf = "layersIn", enabled = true, speed = 2.2, bezier = "pondEmphasized", style = "fade" })
  hl.animation({ leaf = "layersOut", enabled = true, speed = 1.8, bezier = "pondEaseOutCubic", style = "fade" })
  hl.config({ decoration = { rounding = 12, rounding_power = 2 } })
end
hl.on("hyprland.start", pond_motion)
hl.on("config.reloaded", pond_motion)

-- Pond windows are opaque (only kitty is translucent, via its own
-- background_opacity). Override Omarchy's 0.985/0.96 default-opacity tag.
hl.window_rule({ match = { tag = "default-opacity" }, opacity = "1 1" })
