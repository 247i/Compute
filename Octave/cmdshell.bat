@echo off

set OCTAVE_HOME=%~dp0
Rem NOTE: OCTAVE_HOME has a end \
Rem convert to 8.3 format
for %%I in ("%OCTAVE_HOME%") do set OCTAVE_HOME=%%~sI

Rem set home if not already set
if "%HOME%"=="" set HOME=%USERPROFILE%
if "%HOME%"=="" set HOME=%HOMEDRIVE%%HOMEPATH%

Rem set HOME to 8.3 format
for %%I in ("%HOME%") do set HOME=%%~sI

set MSYSDIR=%OCTAVE_HOME%
set MSYSTEM=MSYS

Rem if no msys-1.0, must be msys2
if NOT EXIST "%OCTAVE_HOME%bin\msys-1.0.dll" set MSYSDIR=%OCTAVE_HOME%usr

Rem 32 or 64 bit
if EXIST "%OCTAVE_HOME%mingw32\bin\octave-cli.exe" set MSYSTEM=MINGW32
if EXIST "%OCTAVE_HOME%mingw64\bin\octave-cli.exe" set MSYSTEM=MINGW64

if EXIST "%OCTAVE_HOME%mingw32\bin\octave-cli.exe" set OCTAVE_HOME=%OCTAVE_HOME%mingw32\
if EXIST "%OCTAVE_HOME%mingw64\bin\octave-cli.exe" set OCTAVE_HOME=%OCTAVE_HOME%mingw64\

Rem pkgconfig .pc path
set PKG_CONFIG_PATH=%OCTAVE_HOME%\lib\pkgconfig

Rem   Set up PATH. Make sure the octave bin dir
Rem   comes first.
set PATH=%OCTAVE_HOME%qt5\bin;%OCTAVE_HOME%bin;%OCTAVE_HOME%python;%PATH%
set TERM=cygwin
set GS=gs.exe
set GNUTERM=wxt

Rem tell msys2 to use the paths we set here which matches what octave would do
set MSYS2_PATH_TYPE=inherit

"%MSYSDIR%\bin\bash.exe" --login -i

