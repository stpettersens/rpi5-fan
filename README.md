### Rpi5 control fan program
This is a small D program to control a Rpi5 computer's fan based on:
https://github.com/NikPiermafrost/rpi5-ubuntu-server-fan-script

Requirements:

* [vcgencmd (Rpi utility)](https://www.raspberrypi.com/documentation/computers/os.html#vcgencmd)
* [ldc2 (D LLVM compiler](https://github.com/ldc-developers/ldc)
* [make](https://en.wikipedia.org/wiki/Make_(software))
* [upx](https://github.com/upx/upx)
* [SystemD (for provided service)](https://github.com/systemd/systemd)

SystemD service is configured to run at 3 speed (FanSpeed.HIGH), to use
automatic fan speed based on temperature thresholds, change
the following line in the `control_fan_systemd.service` file before
installing the service to be:
```
ExecStart=/usr/local/bin/control_fan 0
```

Build:
`make`

Install as service:
`sudo/doas make install`

Remove as service:
`sudo/doas make uninstall`:w
