all: menus audio events kbswitch

menus:
	@(cd menus && $(MAKE))

audio: audio.swift
	swiftc -O $< -o $@

events: events.swift
	swiftc -O $< -o $@

kbswitch: kbswitch.swift
	swiftc -O $< -o $@

clean:
	rm -f audio events kbswitch
	@(cd menus && $(MAKE) clean)

.PHONY: all menus clean
