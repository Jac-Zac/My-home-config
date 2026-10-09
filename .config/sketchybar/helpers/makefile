all: menus audio events kbswitch cc clickaway calgrid

menus:
	@(cd menus && $(MAKE))

audio: audio.swift
	swiftc -O $< -o $@

events: events.swift
	swiftc -O $< -o $@

kbswitch: kbswitch.swift
	swiftc -O $< -o $@

cc: cc.swift
	swiftc -O $< -o $@

clickaway: clickaway.swift
	swiftc -O $< -o $@

calgrid: calgrid.swift
	swiftc -O $< -o $@

clean:
	rm -f audio events kbswitch cc clickaway calgrid
	@(cd menus && $(MAKE) clean)

.PHONY: all menus clean
