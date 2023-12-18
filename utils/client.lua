local awful = require("awful")
local gears = require("gears")

local _client = {}

function _client.sync(to_c, from_c)
    if not from_c or not to_c then
        return
    end
    if not from_c.valid or not to_c.valid then
        return
    end
    if from_c.modal then
        return
    end
    to_c.floating = from_c.floating
    to_c.maximized = from_c.maximized
    to_c.above = from_c.above
    to_c.below = from_c.below
    to_c:geometry(from_c:geometry())
    -- TODO: Should also copy over the position in a tiling layout
end

function _client.turn_off(c, current_tag)
    if current_tag == nil then
        current_tag = c.screen.selected_tag
    end
    local ctags = {}
    for k, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c.sticky = false
end

function _client.turn_on(c)
    local current_tag = c.screen.selected_tag
    ctags = { current_tag }
    for k, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c:raise()
    client.focus = c
end

function _client.get_by_direction(direction)
    local sel = client.focus
    if not sel then
        return nil
    end
    local cltbl = sel.screen:get_clients()
    local geomtbl = {}
    for i, cl in ipairs(cltbl) do
        geomtbl[i] = cl:geometry()
    end
    local target = gears.geometry.rectangle.get_in_direction(
        direction,
        geomtbl,
        sel:geometry()
    )
    return cltbl[target]
end

return _client
