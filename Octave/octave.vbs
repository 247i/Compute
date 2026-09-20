' script to run octave in gui/command mode

Set wshShell = CreateObject( "WScript.Shell" )

' If running with wscript.exe, "Exec" will flash a window for a split second.
' Relaunch with cscript.exe which doesn't show that window.
If InStr(1, WScript.FullName, "wscript.exe", vbTextCompare) > 0 Then
  AllArgs = ""
  Set wshArgs = WScript.Arguments
  For I = 0 to wshArgs.Count - 1
    AllArgs = AllArgs & " " & chr(34) & wshArgs(I) & chr(34)
  Next
  WScript.Quit wshShell.Run("cscript.exe """ & WScript.ScriptFullName & """" & AllArgs, 0, True)
End If

' get the directory that script resides in
Set fso = CreateObject("Scripting.FileSystemObject")
OctavePath = fso.GetParentFolderName(WScript.ScriptFullName)

' OctavePath is now the root of the install folder, but for msys2,
' OctavePath should be OctavePath/mingw64 or OctavePath/mingw32
MSysType = "MSYS"
MSysPath = OctavePath
Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(OctavePath & "\mingw64\bin\octave-cli.exe") Then
  MSysPath = OctavePath & "\usr"
  MSysType = "MINGW64"
  OctavePath = OctavePath & "\mingw64" 
ElseIf objFSO.FileExists(OctavePath & "\mingw32\bin\octave-cli.exe") Then
  MSysPath = OctavePath & "\usr"
  MSysType = "MINGW32"
  OctavePath = OctavePath & "\mingw32" 
End If

' get path as a 8.3 path
Set fo = fso.GetFolder(OctavePath)
OctavePath = fo.ShortPath
Set fo = Nothing

' set up path to ensure octave bin comes first
Set wshSystemEnv = wshShell.Environment( "PROCESS" )
if OctavePath <> MSysPath Then
  wshSystemEnv("PATH") = MSysPath  & "\bin;" & wshSystemEnv("PATH")
End If
wshSystemEnv("PATH") = OctavePath & "\bin;" & wshSystemEnv("PATH")

wshSystemEnv("MSYSTEM") = MSysType

' set terminal type
wshSystemEnv("TERM") = "cygwin"
wshSystemEnv("GNUTERM") = "wxt"

wshSystemEnv("GS") = "gs.exe"

If wshShell.ExpandEnvironmentStrings("%HOME%") = "%HOME%" Then
  Home = wshSystemEnv("USERPROFILE")
  Set fo = fso.GetFolder(Home)
  wshSystemEnv("HOME") = fo.ShortPath
  Set fo = Nothing
End If

' set Qt plugin directory and path 
If objFSO.FolderExists(OctavePath & "\qt6\bin") Then
  wshSystemEnv("PATH") = OctavePath & "\qt6\bin;" & wshSystemEnv("PATH")
  wshSystemEnv("QT_PLUGIN_PATH") = OctavePath & "\qt6\plugins"
ElseIf objFSO.FolderExists(OctavePath & "\qt5\bin") Then
  wshSystemEnv("PATH") = OctavePath & "\qt5\bin;" & wshSystemEnv("PATH")
  wshSystemEnv("QT_PLUGIN_PATH") = OctavePath & "\qt5\plugins"
Else
  wshSystemEnv("QT_PLUGIN_PATH") = OctavePath & "\plugins"
End If

' pkgconfig .pc files path
wshSystemEnv("PKG_CONFIG_PATH") = OctavePath & "\lib\pkgconfig"

If wshShell.ExpandEnvironmentStrings("%OPENBLAS_NUM_THREADS%") = "%OPENBLAS_NUM_THREADS%" Then
  ' Set OPENBLAS_NUM_THREADS to number of physical processor cores.
  On Error Resume Next
  Set wshExec = wshShell.Exec("wmic CPU Get NumberOfCores")
  If (Err.Number = 0) Then
    If Not wshExec.Stdout.atEndOfStream Then
      ' Check that first line contains "NumberOfCores".
      If (InStr(1, wshExec.StdOut.ReadLine(), "NumberOfCores") = 1) And (Not wshExec.Stdout.atEndOfStream) then
        ' The next line should contain the number of cores.
        wshSystemEnv("OPENBLAS_NUM_THREADS") = wshExec.StdOut.ReadLine()
      End If
    End If
  Else
    ' No wmic available. Attempt to use PowerShell.
    Set wshExec2 = wshShell.Exec("powershell -NoProfile -Command ""(Get-CimInstance Win32_Processor).NumberOfCores""")
    If (Err.Number = 0) Then
      wshSystemEnv("OPENBLAS_NUM_THREADS") = wshExec2.StdOut.ReadLine()
    End If
  End If
  On Error GoTo 0
End If

' check args to see if told to run gui or command line
' and build other args to use
GUI_MODE=1
AllArgs = ""
Set wshArgs = WScript.Arguments
For I = 0 to wshArgs.Count - 1
  If wshArgs(I) = "--no-gui" Then GUI_MODE=0
  AllArgs = AllArgs & " " & chr(34) & wshArgs(I) & chr(34)
Next

' start octave-gui, either with console shown or hidden
If GUI_MODE = 1 then
  AllArgs = AllArgs & " " & chr(34) & "--gui" & chr(34)
  wshShell.Run chr(34) & OctavePath & "\bin\octave-gui.exe" & Chr(34) & AllArgs, 0
Else
  wshShell.Run chr(34) & OctavePath & "\bin\octave-gui.exe" & Chr(34) & AllArgs, 1
End If

' free our objects
Set fso = Nothing
Set wshShell = Nothing
Set wshSystemEnv = Nothing
Set wshArgs = Nothing

