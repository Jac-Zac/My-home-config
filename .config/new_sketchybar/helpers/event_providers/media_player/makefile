BINARY_NAME = media_player
FRAMEWORKS = -framework Cocoa -framework SwiftUI -framework MediaPlayer

bin/$(BINARY_NAME): media_player.swift | bin
	swiftc $< $(FRAMEWORKS) -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean 