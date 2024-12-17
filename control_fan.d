/*
   This is a program to control the fan on a Rpi 4 or 5 computer.
   I have only tested it so far on an Rpi 5 with the official fan kit
   running Ubuntu 24.04.1 LTS ("noble") imaged with rpi-imager.
   Author: Sam Saint-Pettersen
   Version: 0.1.0
   Last updated: 2024-12-17
*/

import std.file;
import std.math;
import std.conv;
import std.stdio;
import std.format;
import std.string;
import std.process;
import core.thread;
import core.stdc.stdlib : exit;
import core.sys.posix.unistd : geteuid;

enum FanSpeed {
    FULL = 4,
    HIGH = 3,
    MEDIUM = 2,
    LOW = 1,
    AUTOMATIC = 0
}

void control_fan(string _interface, ubyte speed) {
    immutable string measure_temp = "vcgencmd measure_temp";
    while (true) {
        int temp = 0;
        try {
            auto response = executeShell(measure_temp);
            string s_temp = response.output[5..9];
            temp = to!int(round(to!float(s_temp)));

            writefln("System temperature is %d°C.", temp);
        }
        catch (Exception) {
            // We will probably never get here.
            writeln("Error: Could not get system temperature:");
            writeln("Does vcgencmd exist on your system?");
            writeln();
            exit(display_usage(-1));
        }

        // Manual speed setting.
        string control_fan = "";
        if (cast(FanSpeed)speed != FanSpeed.AUTOMATIC) {
            control_fan = format("echo %d > %s", speed, _interface);
            writefln("Running fan at FanSpeed.%s (%d) speed.",
            cast(FanSpeed)speed, speed);
        }
        else {
            // Automatic speed setting (FanSpeed.AUTOMATIC).
            FanSpeed temp_speed = FanSpeed.LOW;
            if (temp >= 50)
                temp_speed = FanSpeed.FULL;

            else if (temp >= 40)
                temp_speed = FanSpeed.HIGH;

            else if (temp >= 30)
                temp_speed = FanSpeed.MEDIUM;

            control_fan = format("echo %d > %s", cast(ubyte)temp_speed, _interface);
            writefln("Running fan at FanSpeed.%s (%d) speed.",
            temp_speed, cast(ubyte)temp_speed);
        }

        executeShell(control_fan);
        Thread.sleep(dur!("seconds")(1));
    }
}

int display_version() {
    writeln("rpi5 fan_control v0.1.0");
    return 0;
}

int display_usage(int exit_code) {
    writeln("Rpi5 control fan program.");
    writeln("Written by Sam Saint-Pettersen <s.stpettersen@pm.me>");
    writeln();
    writeln("Usage: control_fan [<speed>|-v|--version]");
    writeln();
    writeln("Where speed is required and between 0 (automatic) and 4 (full speed).");
    writeln();
    writeln("Speeds:");
    writeln("0 = FanSpeed.AUTOMATIC");
    writeln("1 = FanSpeed.LOW");
    writeln("2 = FanSpeed.MEDIUM");
    writeln("3 = FanSpeed.HIGH");
    writeln("4 = FanSpeed.FULL");
    writeln();
    writeln("Use -v or --version to get program version information and exit.");
    writeln();
    return exit_code;
}

int check_is_rpi_and_has_interface(string _interface) {
    version(X86_64) {
        writeln("This program was designed to run on a Raspberry Pi 4 or 5 computer.");
        return -1;
    }
    if (!_interface.exists) {
        writeln("Required interface does not exist:");
        writeln(_interface);
        return -1;
    }
    return 0;
}

int main(string[] args) {
    immutable string _interface = "/sys/class/thermal/cooling_device0/cur_state";
    if (check_is_rpi_and_has_interface(_interface) != 0)
        return -1;

    if (args.length > 1) {
        try {
            if (isNumeric(args[1])) {
                /* This program shoud be run as superuser
                   and as part of a service when invoked
                   to control the fan and not display usage
                   or program version information. */
                if (geteuid() != 0) {
                    writeln("This program should be run as a superuser");
                    writeln("and as part of a service (e.g. SystemD).");
                    return -1;
                }

                ubyte speed = to!ubyte(args[1]);
                if (speed > 4)
                    throw new Exception("Max speed = 4");

                control_fan(_interface, speed);
            }
            else if (args[1] == "-v" || args[1] == "--version") {
                return display_version();
            }
            else {
                writeln("Error: Invalid option given.");
                writeln();
                return display_usage(-1);
            }
        }
        catch (Exception) {
            writeln("Error: Speed provided was not in range 0-4.");
            writeln();
            return display_usage(-1);
        }
    }

    return display_usage(0);
}
