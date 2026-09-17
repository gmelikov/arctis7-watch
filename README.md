# arctis7-watch

Switches the default PipeWire/PulseAudio output and input when a
SteelSeries Arctis 7 (2019) wireless headset (dongle `1038:1260`) is turned
on or off. It only runs while the USB dongle is plugged in.

## How it works

- `70-arctis7.rules`: on dongle plug-in, udev grants the session user
  access to the vendor HID interface (interface 5), creates `/dev/arctis7`
  and starts the user service `arctis7-watch.service`.
- `arctis7-watch.service` is bound to `dev-arctis7.device`, so systemd stops
  it when the dongle is unplugged. On stop, it switches audio to the
  fallback devices.
- `arctis7-watch` polls the dongle once a second and calls
  `pactl set-default-sink/source` when the headset state changes.

## Protocol

The dongle does not report power changes by itself, so it has to be polled.
Write to hidraw:

| Request (+29 zero bytes) | Reply byte `[2]`                 |
|--------------------------|----------------------------------|
| `06 14`                  | `03` headset on, `01` headset off |
| `06 18`                  | battery %, `00` when off         |

The remaining reply bytes are garbage.

## Install

Requires `pactl` (`pulseaudio-utils`).

```sh
./install.sh
systemctl --user status arctis7-watch
journalctl --user -u arctis7-watch -f
```

## Configuration

Environment variables (e.g. via `systemctl --user edit arctis7-watch`).
Device values are substrings of `pactl list short sinks/sources` names.

| Variable                | Default                | Meaning                          |
|-------------------------|------------------------|----------------------------------|
| `ARCTIS_ON_SINK`        | `SteelSeries_Arctis_7` | output when headset is on        |
| `ARCTIS_ON_SINK_PREFER` | `game`                 | preferred among matching outputs |
| `ARCTIS_ON_SOURCE`      | `SteelSeries_Arctis_7` | input when headset is on         |
| `ARCTIS_OFF_SINK`       | `AKG_C44-USB`          | output when off / unplugged      |
| `ARCTIS_OFF_SOURCE`     | `AKG_C44-USB`          | input when off / unplugged       |
| `ARCTIS_POLL`           | `1`                    | poll interval, seconds           |
| `ARCTIS_HIDRAW`         | `/dev/arctis7`         | hidraw device                    |
| `ARCTIS_DRY_RUN`        | unset                  | `1`: only print pactl commands   |

`arctis7-watch --off` switches to the fallback devices once and exits.
