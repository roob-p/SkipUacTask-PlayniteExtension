#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=This utility checks if a game's exe (passed as a parameter) is still running. If not, it closes the SkipUacTask window (which ensures game time tracking), and you'll return to Playnite.
#AutoIt3Wrapper_Res_Fileversion=1.0.1.0
#AutoIt3Wrapper_Res_ProductName=BatKiller
#AutoIt3Wrapper_Res_ProductVersion=1.0.1
#AutoIt3Wrapper_Res_CompanyName=roob-p (author)
#AutoIt3Wrapper_Res_LegalCopyright=roob-p
#AutoIt3Wrapper_Res_Language=1040
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <MsgBoxConstants.au3>



sleep(3000)



$bat_title = "SkipUacTask"

$proc=$cmdline[1]
$wait=""

If UBound($cmdline) > 2 Then
    $wait = $cmdline[2]
EndIf


$hwnd1 = WinGetHandle($bat_title)
$hwnd2 = WinGetHandle($proc)
$pid1 = WinGetProcess($hwnd1)
$pid2 = WinGetProcess($hwnd2)

if $wait > 0 then
sleep ($wait*1000)

endif

While ProcessExists($proc)
    Sleep(4000)
WEnd
ProcessClose($pid1)
MsgBox($MB_OK, "Window closed", "The window '" & $bat_title & "' has been closed.",2)

