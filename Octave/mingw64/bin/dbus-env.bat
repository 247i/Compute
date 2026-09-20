:: environment setting for dbus clients
@echo off

:: session bus address
set DBUS_SESSION_BUS_ADDRESS=autolaunch:

:: system bus address
set DBUS_SYSTEM_BUS_DEFAULT_ADDRESS=unix:path=/scratch/build/mxe-octave-w64/usr/x86_64-w64-mingw32/var/run/dbus/system_bus_socket
