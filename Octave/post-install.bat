@echo off
Rem   Run on initial install /update
set ROOT_DIR=%~dp0
Rem Convert to 8.3 format so we don't have to worry about spaces.
for %%I in ("%ROOT_DIR%") do set ROOT_DIR=%%~sI

set MSYSDIR=%ROOT_DIR%
set MSYSTEM=MSYS

if NOT EXIST "%ROOT_DIR%\bin\msys-1.0.dll" set MSYSDIR=%ROOT_DIR%\usr
if EXIST "%ROOT_DIR%\mingw32\bin\octave.bat" set MSYSTEM=MINGW32
if EXIST "%ROOT_DIR%\mingw64\bin\octave.bat" set MSYSTEM=MINGW64

if %MSYSTEM%==MSYS (
 set OCTAVE_HOME=%ROOT_DIR%
) else (
 if %MSYSTEM%==MINGW32 (
 set OCTAVE_HOME=%ROOT_DIR%mingw32
) else (
 set OCTAVE_HOME=%ROOT_DIR%mingw64
))

Rem QT subdir path
IF EXIST "%OCTAVE_HOME%\qt6" (
  set QT_SUBDIR=qt6/
) ELSE (
  IF EXIST "%OCTAVE_HOME%\qt5" (
    set QT_SUBDIR=qt5/
  ) ELSE (
    set QT_SUBDIR=
  )
)

Rem Create qt.conf
set QT_CONF=%OCTAVE_HOME%\bin\qt.conf
echo [Paths] > "%QT_CONF%"
echo Prefix="%OCTAVE_HOME:\=/%" >> "%QT_CONF%"
echo Documentation=%QT_SUBDIR%doc >> "%QT_CONF%"
echo Headers=%QT_SUBDIR%include >> "%QT_CONF%"
echo Libraries=%QT_SUBDIR%libs >> "%QT_CONF%"
echo Plugins=%QT_SUBDIR%plugins >> "%QT_CONF%"
echo Translations=%QT_SUBDIR%translations >> "%QT_CONF%"

Rem Run bash to register the initial environment
echo "Setting up MSYS system ..."
"%MSYSDIR%\bin\bash.exe" --login -c echo
echo "Updating fc-cache (may take a while) ..."
"%OCTAVE_HOME%\bin\fc-cache.exe" -v
echo "Updating octave packages ..."
"%OCTAVE_HOME%\bin\octave.bat" --no-gui -W -H -f -q --eval "if version()(1) < '6', pkg rebuild, end"

