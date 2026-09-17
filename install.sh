#!/bin/sh
set -e
cd "$(dirname "$0")"
install -Dm755 arctis7-watch ~/.local/bin/arctis7-watch
install -Dm644 arctis7-watch.service ~/.config/systemd/user/arctis7-watch.service
systemctl --user daemon-reload
sudo install -m644 70-arctis7.rules /etc/udev/rules.d/70-arctis7.rules
sudo udevadm control --reload
# Apply to an already plugged dongle.
sudo udevadm trigger --action=add --subsystem-match=hidraw
