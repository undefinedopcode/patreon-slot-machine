# patreon-slot-machine
Limited tier checker for patreon with notifications.

The script will poll 

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


