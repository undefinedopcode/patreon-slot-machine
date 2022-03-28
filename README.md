# patreon-slot-machine
Limited tier checker for patreon with notifications.

The script will poll at a configurable interval, and optionally send desktop notifications and/or a text message if a limited patreon tier is open. The sending currently uses textbelt, and you'll need a key (the default config will allow sending a single sms I think for testing). 

I will add support for MacOS/Windows desktop notifications at somepoint.

(and not stop bothering patreon to fix a gap in their platform that means this is necessary).

## Requirements
* curl
* htmlq (cargo install htmlq)
* jq (install from package manager)
* notify-send (part of linux)

### Setup (ubuntu)
```
sudo apt install cargo jq
cargo install htmlq
```

### Setup (arch/manjaro)
```
sudo pacman -S cargo jq
cargo install htmlq
```

## TODO
* Notifications on Windows (from WSL -- maybe powershell?).
* Notifications on MacOS (using osascript)


