local icons = require("icons")
local colors = require("colors")

local whitelist = {
    ["Spotify"] = true,
    ["Zen Browser"] = true,
}

local media_cover = sbar.add("item", {
    position = "right",
    background = {
        image = {
            string = "media.artwork",
            scale = 0.75,
        },
        color = colors.transparent,
    },
    label = { drawing = false },
    icon = { drawing = false },
    drawing = false,
    updates = true,
})

local media_artist = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    width = 0,
    icon = { drawing = false },
    label = {
        width = 0,
        font = { size = 9 },
        color = colors.with_alpha(colors.white, 0.6),
        max_chars = 18,
        y_offset = 6,
    },
})

local media_title = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    icon = { drawing = false },
    label = {
        font = { size = 11 },
        width = 0,
        max_chars = 16,
        y_offset = -5,
    },
})

local interrupt = 0
local function animate_detail(detail)
    -- Don't show details if player is visible
    if player_visible then
        return
    end

    if not detail then
        interrupt = interrupt - 1
    end
    if interrupt > 0 and not detail then
        return
    end

    sbar.animate("tanh", 30, function()
        media_artist:set({ label = { width = detail and "dynamic" or 0 } })
        media_title:set({ label = { width = detail and "dynamic" or 0 } })
    end)
end

media_cover:subscribe("media_change", function(env)
    if whitelist[env.INFO.app] then
        local drawing = (env.INFO.artist ~= "" or env.INFO.title ~= "")
        media_artist:set({ drawing = drawing, label = env.INFO.artist })
        media_title:set({ drawing = drawing, label = env.INFO.title })
        media_cover:set({
            drawing = drawing,
            background = {
                image = {
                    string = "media.artwork",
                    scale = 0.75,
                },
            },
        })

        -- Only show details if player isn't visible
        if drawing and not player_visible then
            animate_detail(true)
            interrupt = interrupt + 1
            sbar.delay(5, animate_detail)
        end
    end
end)

local player_visible = false

-- Add a function to handle player visibility
local function show_player()
    if not player_visible then
        sbar.exec("~/.config/sketchybar/helpers/event_providers/media_player/bin/media_player")
        player_visible = true
    end
end

local function hide_player()
    if player_visible then
        sbar.exec("pkill -SIGUSR1 media_player")
        player_visible = false
    end
end

media_cover:subscribe("mouse.entered", function(env)
    interrupt = interrupt + 1
    animate_detail(true)
    show_player()
end)

media_cover:subscribe("mouse.exited", function(env)
    animate_detail(false)
end)

-- Keep click handler for closing
media_cover:subscribe("mouse.clicked", function(env)
    if player_visible then
        hide_player()
    else
        show_player()
    end
end)

-- Add this to prevent window from closing when clicking inside it
media_cover:subscribe("mouse.clicked.inside", function(env)
    return
end)

-- Add this to track when the player closes itself
media_cover:subscribe("mouse.exited.global", function(env)
    player_visible = false
end)
