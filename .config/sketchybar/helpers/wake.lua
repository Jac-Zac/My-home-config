-- Post-wake blackout: lid-open fires system_woke plus every routine timer at
-- once, which used to visibly flicker as staggered refreshes landed. The bar
-- keeps its painted state across sleep by itself, so on wake we only arm a
-- short quiet window: routine polls skip while quiet (cached values stay up),
-- user-initiated updates (clicks, volume keys, real change events) bypass it,
-- and normal polling converges gradually afterwards.
local M = {}

local BLACKOUT = 10 -- seconds of quiet after wake
local quiet_until = 0

function M.arm()
	quiet_until = os.time() + BLACKOUT
end

function M.quiet()
	return os.time() < quiet_until
end

return M
