$global:directory= "C:\SkipUacTask"
$global:lnkstyle=2 # Style 2 keeps the .lnk file, while Style 1 uses the target of the .lnk file.
$global:newaction_actionstart=$True  #$True: The new SkipUacTask gameaction is a startup action. 
$global:oldaction_actionstart=$False #$True: Keep the existing startup option; $False: Remove the startup action from the old gameaction (non TaskSkipAction).
$global:client_wait=0 # Delay the game startup: some games "require" the client to be fully started. If you receive the "window has been closed" message from Batkiller, try setting a value like 5 (seconds).  
                      # You can also set this in the game's action script for games that require it.  

$global:wait_exe=3    # Delay the return to Playnite after the game has been closed. Sometimes, with some launchers (Ubisoft Connect, for now), the game's exe is closed and relaunched when started as admin.  
                      # This timeout prevents Batkiller from closing the batch file responsible for playtime tracking, making it "wait" to detect the game process again.  
                      # It does not delay the game's startup but introduces a delay after the game has been closed before returning to Playnite.  
                      # I set it to 3 seconds, but I think 10 seconds or more might be effective with some games. You can also set this in the game action's script.  




$global:Steam_location="C:\Program Files (x86)\Steam"
$global:Ubisoft_Connect_location="C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher"
$global:GOG_location="C:\Program Files (x86)\GOG Galaxy"
$global:EA_App_location="C:\Program Files\Electronic Arts\EA Desktop\EA Desktop"
$global:Epic_location="C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32"
$global:Amazon_location="C:\Users\$user\AppData\Local\Amazon Games\App"



function getGameMenuItems{
	
	param(
		$getGameMenuItemsArgs
	)

    $menuItem = New-Object Playnite.SDK.Plugins.ScriptGameMenuItem
	$menuItem.Description = "SkipUacTask"
    $menuItem.FunctionName = "SkipUacTask"
	#$menuItem.MenuSection = "SkipUacTask"
	$menuItem.Icon = "$PSScriptRoot"+"\icon.png"
    
    return $menuItem
}




function SkipUacTask()
{
	param(
		$getGameMenuItemsArgs
	)
	
$user = $env:USERNAME

$folder=$global:directory



$taskfolder="$($folder)\task"
$runfolder="$($folder)\run"


$Gamesel = $PlayniteApi.MainView.SelectedGames
$orderedGames = $Gamesel | Sort-Object -Property Name





foreach ($Game in $orderedGames) { 

#backtick: `


$gamename=$game.name
$gamename=$gamename -replace '[\/\:\*?"<>|]'
$gamenamess= $gamename -replace "'","''"

$pathnotempty=1


if(!$game.gameactions -and !$game.source){$playniteApi.Dialogs.ShowMessage("There aren't any game actions.")} 



if($game.gameactions){




if($game.gameactions[0].type -ne "Emulator"){
	

if($game.gameactions[0].path){
if($game.gameactions[0].path -like "*{InstallDir}*"){

	
	$bapath = $game.gameactions[0].path -replace "{InstallDir}",$game.installdirectory 
	$bafile = Get-Item $bapath -EA 0
	$baext = $bafile.extension


	} else {
		$bapath = $game.gameactions[0].path
		$bafile = Get-Item $bapath -EA 0
		$baext = $bafile.extension
		
}

if ($baext -ne ".lnk" -and $baext -ne ".exe" -and $baext -ne ".bat" -and $baext -ne ".cmd" -and !$game.source){ $playniteapi.dialogs.ShowMessage("$baext not supported!")}

}
}


if ($game.gameactions[0].name -notcontains "SkipUacTask"){
#if (($game.gameactions[0].name -notcontains "SkipUacTask") -and ($baext -eq ".lnk" -or $baext -eq ".exe")){


#$playniteApi.Dialogs.ShowMessage($game.gameactions[0].path) #In the case of an emu built-in profile, if it hasn't been modified at least once, it understandably doesn't find anything.


if ($game.gameactions[0].type -eq "Emulator"){


#$baext=""	

$emu=$PlayniteApi.Database.Emulators
$gaemuid=$game.gameactions[0].emulatorid
$gaemu=$emu[$gaemuid]
$gaemuproid=$game.gameactions[0].emulatorprofileid
$emupro=$emu[$gaemuid].allprofiles
$emuproid=$emu[$gaemuid].allprofiles.id	
$profilo = $gaemu.getprofile($gaemuproid)


		if($profilo.builtinprofilename -ne $null){
		
	$yaml = Get-Content -Path "c:\playnite\Emulation\Emulators\$gaemu\emulator.yaml"
	
	
	
	
$linenumber=0
$trovato=$false
foreach ($line in $yaml) {
if ($trovato -eq $false){
	$linenumber+=1
if($line -like "*Name: $profilo*"){

	$trline=$linenumber -1

	$i=0
	$j=0
	

		while (($yaml[$trline +$i] -notlike "*StartupExecutable*") -and ($trline + $i -le $yaml.Length)){	
		$i+=1
}
		
		while (($yaml[$trline +$j] -notlike "*StartupArguments*") -and ($trline + $j -le $yaml.Length)){
		$j+=1
	}
$trovato=$true

$emu_exe=$yaml[$trline +$i] -replace '.*StartupExecutable: ', ''
$arg=$yaml[$trline +$j] -replace '.*StartupArguments: ', ''



}#endif 
}#endif trovato
}#endif foreach (in yaml)	

		#$arg=$game.gameactions[0].arguments #no "If it's built-in and you have never manually checked the box from the interface, it won't take the value.



		## EMU BUILTIN                                   
		$emu_exe = $emu_exe -replace "\\|\^|\$"
		$exepath=$gaemu.installdir
		$emulator_exeS="$($exepath)\$emu_exe"
		
		$emulator_exe="$($exepath)\$emu_exe"
	
		$roms=$game.roms.path -replace "{InstallDir}", $game.installdirectory
		$roms= $roms -replace '\\+', '\'

		$arg = $arg.TrimStart("'")  #nel file yaml i parametri erano indicati con '   '
		$arg = $arg.TrimEnd("'")  

		$arg= $arg -replace "\.\\","$exepath" #sarebbe '.\'

		$arg=$arg -replace "`"","```"" #pare bene

		$arg=$arg -replace "{ImagePath}","$($roms)"

	

		$addarg=$game.gameactions[0].additionalarguments
		$addarg=$addarg -replace "`"","```"" #new R5
	
	$argaction= $game.gameactions[0].arguments
	$argaction= $argaction -replace "\.\\","$exepath"
	$argaction=$argaction -replace "`"","```"" 
	$argaction= $argaction -replace "{ImagePath}","$roms"

	
	
		$game_fold = $emulator_exeS 
		
		
		if($game.gameactions[0].OverrideDefaultArgs -eq $false){   
			if (($addarg -ne $null) -and ($addarg -ne '')) {   #attenzione se almeno una volta hai messo un parametro e poi l'hai cancellato in questo casto non sarà $null ma sarà tipo '' (vuota) quindi meglio mettere 2 check
		$path="$($emulator_exe) $($arg) $($addarg)"
		$pathA="$($emulator_exe)"
		$pathB="$($arg) $($addarg)"
		}
		else{
			$path="$($emulator_exe) $($arg)"
			$pathA="$($emulator_exe)"
			$pathB="$($arg)"
				}
		}else{$path="$($emulator_exe) $($argaction)"        
		$pathA="$($emulator_exe)"
		$pathB="$($argaction)"
		}



	}else{ #custom profile:



		##EMU CUSTOM PROFILE    

$roms=$game.roms.path -replace "{InstallDir}", $game.installdirectory
$roms= $roms -replace '\\+', '\'

$arg=$game.gameactions[0].arguments    #FUNZIONA SOLO SE SOVRASCRIVI; DA DOC, POI SE GAMEACTIONS TYPE E' EMULATORE NON RESTITUISCE NULLA; ARG FUNZIONA SOLO SE E' DI TIPO FILE, NON MENZIONA QUANDO SOVRASCRIVI


$profexe=$profilo.executable


		$arg= $arg -replace "\.\\","$exepath\" #sarebbe '.\' 
		

		$arg = $arg -replace "`"","```"" 
		$arg=$arg -replace "{ImagePath}","$($roms)" 
		
		
##





$addarg=$game.gameactions[0].additionalarguments

$proarg=$profilo.arguments
$proarg = $proarg -replace "`"","```""

$proarg=$proarg -replace "{ImagePath}","$($roms)" 
$game_fold = $profilo.executable 







if($game.gameactions[0].OverrideDefaultArgs -eq $false){     	#NO OVERRIDE:		

	$pathA="$($profexe)"
	$pathB="$($proarg)"


	if (($addarg -ne '') -and ($addarg -ne $null)){

		$addarg = $addarg -replace "`"","```""
		$pathB="$($pathB) $($addarg)"
	}
	$path= "$($pathA) $($pathB)"

	}else{ 														#SI OVERRIDE: 


	$pathA="$($profexe)"
	$pathB="$($arg)"
	$path="$($profexe) $($arg)"

	}




#create
	}#end else, customprofile
	
	create
}#endif Emulator




#####->
##
##if ((($game.gameactions[0].type -eq "File") -or ($game.gameactions[0].type -eq "URL")) -and (($baext -ne ".lnk" -and $baext -ne ".exe" -and $baext -ne ".bat" -and $baext -ne ".cmd") -or ($game.gameactions[0].path -eq "")) -and $game.source) {
if ((($game.gameactions[0].type -eq "File") -or ($game.gameactions[0].type -eq "URL")) -and ($baext -ne ".lnk" -and $baext -ne ".exe" -and $baext -ne ".bat" -and $baext -ne ".cmd") -and $game.source) {
	
	create3
}




if ((($game.gameactions[0].type -eq "File") -or ($game.gameactions[0].type -eq "URL")) -and ($baext -eq ".lnk" -or $baext -eq ".exe" -or $baext -eq ".bat" -or $baext -eq ".cmd")) {
#if (($game.gameactions[0].type -eq "File")){


if ($baext -eq ".lnk"){
	 
	$exxx=[System.Environment]::Is64BitProcess


$command = "`$shortcut =(New-Object -COM WScript.Shell).CreateShortcut('$bafile');write `$shortcut; `$pathshoo = `$Shortcut.TargetPath; write `$pathshoo; `$pathshoo | Out-File 'C:\Temp\powershelloutput.txt'; `$argT = `$Shortcut.Arguments; write `$argT; `$argT | Out-File 'C:\Temp\powershelloutput2.txt'" #OK!!!
$output = start-process "C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -Argumentlist $command -WindowStyle Minimized -PassThru 
$output.WaitForExit()
$returnValue = Get-Content -Path 'C:\Temp\powershelloutput.txt'

$pathsho=$returnvalue
$returnValue2 = Get-Content -Path 'C:\Temp\powershelloutput2.txt'
$argT=$returnvalue2
$argT=$argT -replace "`"","```""



}#endif lnk





elseif ($baext -eq ".exe"){



$arg  = $game.gameactions[0].Arguments
$arg = $arg -replace "`"","```""

$path = $game.gameactions[0].path


if($game.gameactions[0].path -like "*{InstallDir}*"){ 
$path = $game.gameactions[0].path -replace "{InstallDir}",$game.installdirectory 

}

}#endif exe


if (!$game.source){create}elseif (($game.source) -and ($game.source.name -ne "GOG") -and ($game.source.name -ne "EA app") -and ($game.source.name -ne "Origin") -and ($game.source.name -ne "Amazon") -and ($game.source.name -ne "Bethesda") -and ($game.source.name -ne "Xbox Game") -and ($game.source.name -ne "Xbox Game Pass") -and ($game.source.name -ne "Indiegala")){create2}  
#elseif{($game.source) -and ($game.source.name -eq "Amazon"){amazon_create}
}#endif GameActionType File or Url


}#endif SkipUacTask
else {$playniteapi.dialogs.ShowMessage("SkipUacTask is already the 1st entry in gameactions.")}
}#end gameaction 

#else{   									#SI SOURCE
#elseif ($game.source){   					#SI SOURCE
elseif (($game.source) -and (($game.source.name -ne "GOG") -and ($game.source.name -ne "EA app" -and $game.source.name -ne "Origin") -and ($game.source.name -ne "Amazon") -and ($game.source.name -ne "Bethesda") -and ($game.source.name -ne "Xbox Game") -and ($game.source.name -ne "Xbox Game Pass") -and ($game.source.name -ne "Indiegala"))){

#if(!$game.gameactions){
if(!$game.gameactions){
	create4_noGA
	  }#endif
    }#end elseif





}#foearch 


} #endfunc



##crea:
function create()
{
		param(
		$getGameMenuItemsArgs
	)


$taskfolder="$($folder)\task"
$runfolder="$($folder)\run"


$time=(Get-Date).AddMinutes(-30).ToString("HH:mm")


New-Item -Path $taskFolder -ItemType Directory -Force
New-Item -Path $runFolder -ItemType Directory -Force


	if ($game.gameactions[0].type -eq "Script") {

}

if ($game.gameactions[0].type -eq "Emulator") {

	
	
$commandsBt="
`$Action = New-ScheduledTaskAction -Execute `"```"$pathA```"`" -Argument `"```"$pathB```"`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.platforms.name))`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
exit
#pause
"


$commands="
`$Action = New-ScheduledTaskAction -Execute `"```"$pathA```"`" -Argument `"$pathB`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.platforms.name))`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
exit
#pause
"
	
	$batfile="$($taskfolder)\$($gamename) ($($game.platforms.name)).ps1"
	$batcontent= $commands | Out-File -FilePath $batfile -Encoding ASCII

}#end gameactiontype emulator

		#mod
if ($game.gameactions[0].type -eq "File" -or $game.gameactions[0].type -eq "URL") {
##if ($game.gameactions[0].type -eq "File") {

if ($baext -eq ".exe"){
	

if(($arg -ne $null)-and ($arg -ne '')){
$argu= "-Argument `"$arg`""
}else{$argu= ""}

$commands ="
`$Action = New-ScheduledTaskAction -Execute `"```"$path```"`" $argu
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.platforms.name))`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
exit
#pause
"



$batfile="$($taskfolder)\$($gamename) ($($game.platforms.name)).ps1"
$batcontent= $commands | Out-File -FilePath $batfile -Encoding ASCII
} elseif(($baext -eq ".lnk") -and ($global:lnkstyle -eq 2)){         				 #lnk e style2
 

	
	$commands ="
`$Action = New-ScheduledTaskAction -Execute `"cmd.exe`" -Argument `"/c ```"$bapath```"`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.platforms.name))`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
exit
#pause
"

$batfile="$($taskfolder)\$($gamename) ($($game.platforms.name)).ps1"
$batcontent= $commands | Out-File -FilePath $batfile -Encoding ASCII
}elseif(($baext -eq ".lnk") -and ($global:lnkstyle -eq 1)){      				 #lnk e style1



$commands ="
`$Action = New-ScheduledTaskAction -Execute `"```"$pathsho```"`" -Argument `"$argT`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.platforms.name))`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
#exit
#pause
"

$batfile="$($taskfolder)\$($gamename) ($($game.platforms.name)).ps1"
$batcontent= $commands | Out-File -FilePath $batfile -Encoding ASCII
	
}

}#endif type File


$runfile=    "$($runfolder)\$($gamename) ($($game.platforms.name)).bat"
$runcommand = "schtasks /run /tn `"SkipUacTask\$($gamename) ($($game.platforms.name))`""
$titlecommand = "title SkipUacTask"
$pausecommand=  "pause" 
$runcommands = "$runcommand`r`n$titlecommand`r`n$pausecommand"
$runcontent= $runcommands | Out-File -FilePath $runfile -Encoding ASCII



start-process "powershell" -Argumentlist "-file `"$($taskfolder)\$($gamename) ($($game.platforms.name)).ps1`"" -Verb RunAs




if (($game.gameactions[0].type -eq "File") -or ($game.gameactions[0].type -eq "URL")){

if ($baext -eq ".lnk"){
$game_fold=$pathsho
 $game_fold = $game_fold.Trim('"')
 $game_fold = $game_fold.TrimEnd('\')
 $game_exe  = [System.IO.Path]::GetFileName($game_fold)

}else{	

$game_fold = $game.gameactions[0].path
$game_exe  = [System.IO.Path]::GetFileName($game_fold)
}
}elseif ($game.gameactions[0].type -eq "Emulator"){

 $game_exe  = [System.IO.Path]::GetFileName($game_fold)
 }

$actionempty = New-Object Playnite.SDK.Models.GameAction
$game.Gameactions.Add($actionempty)

for($i=$game.gameactions.count -1; $i -gt 0;$i--){
	$game.gameactions[$i] 		= $game.gameactions[$i-1].getcopy()
}

	$game.gameactions[0].name 					=	"SkipUacTask"	 
	$game.gameactions[0].path		 		  	=	"$runfile"
	$game.gameactions[0].arguments 				=	""	 
	$game.gameactions[0].additionalarguments 	=	""
	$game.gameactions[0].type 					=	[Playnite.SDK.Models.GameActionType]::Script			
	$game.gameactions[0].IsplayAction			=	$newaction_actionstart	
	$game.gameactions[0].WorkingDir  			= 	""
	#$game.gameactions[0].TrackingMode 			= 	[Playnite.SDK.Models.TrackingMode]
	#$game.gameactions[0].TrackingPath 			= 	""

if (($game.gameactions[1].IsPlayaction -eq $True) -and ($global:oldaction_actionstart -eq $False)) {
$game.gameactions[1].IsplayAction=$False
}

#ACTIONSCRIPT:
$game.gameactions[0].script="`$game_exe = `"$game_exe`"
`$proc = Start-Process `"$runfolder\$($gamename) ($($game.platforms.name)).bat`" -WindowStyle Minimized -PassThru
start-process `"$PSScriptRoot\batKiller.exe`" -Argument `$game_exe
`$proc.WaitForExit()
#`$game_fold = `"$($game.gameactions[$game.gameactions.count-1].path)`"
"

#}#non contiene SkipUacTask2

	



#}#endif exe

#}#non contiene  SkipUacTask1

}#endfunc create


function create2()
{
		param(
		$getGameMenuItemsArgs
	)
	


$source=""
$game_fold = $game.gameactions[0].path




$actionempty = New-Object Playnite.SDK.Models.GameAction
$game.Gameactions.Add($actionempty)

for($i=$game.gameactions.count -1; $i -gt 0;$i--){
	$game.gameactions[$i] 		= $game.gameactions[$i-1].getcopy()
}

	$game.gameactions[0].name 					=	"SkipUacTask"	 
	$game.gameactions[0].path		 		  	=	"$runfile"
	$game.gameactions[0].arguments 				=	""	 
	$game.gameactions[0].additionalarguments 	=	""
	$game.gameactions[0].type 					=	[Playnite.SDK.Models.GameActionType]::Script			
	$game.gameactions[0].IsplayAction			=	$newaction_actionstart	
	$game.gameactions[0].WorkingDir  			= 	""
	#$game.gameactions[0].TrackingMode 			= 	[Playnite.SDK.Models.TrackingMode]
	#$game.gameactions[0].TrackingPath 			= 	""

	if (($game.gameactions[1].IsPlayaction -eq $True) -and ($global:oldaction_actionstart -eq $False)) {
	$game.gameactions[1].IsplayAction=$False}
	
	f2-3-4build

	
	
}



function create3()
{
		param(
		$getGameMenuItemsArgs
	)





$initialDirectory=$game.installdirectory	
	
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Exe files (*.exe)|*.exe|Tutti i file (*.*)|*.*"
$dialog.InitialDirectory = $game.installdirectory  


if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
	$game_fold = $dialog.FileName

   
}

#$baext= $game_exe.extension
#$game_exe  = [System.IO.Path]::GetFileName($game_fold)
#$gamee=[System.IO.Path]::GetFileNameWithoutExtension($game_exe)
$game_dir=[System.IO.Path]::GetDirectoryName($game_fold)
#$source=$game.source

	


#$game.gameactions = New-Object System.Collections.Generic.List[Playnite.SDK.Models.GameAction]
$newgameaction = New-Object Playnite.SDK.Models.GameAction
$game.gameactions.Add($newgameaction)
for($i=$game.gameactions.count -1; $i -gt 0;$i--){
	$game.gameactions[$i] 		= $game.gameactions[$i-1].getcopy()
}
	
	
	
	$game.gameactions[0].name 					=	"SkipUacTask"	 
	$game.gameactions[0].path		 		  	=	"$runfile"
	$game.gameactions[0].arguments 				=	""	 
	$game.gameactions[0].additionalarguments 	=	""
	$game.gameactions[0].type 					=	[Playnite.SDK.Models.GameActionType]::Script			
	$game.gameactions[0].IsplayAction			=	$newaction_actionstart	
	$game.gameactions[0].WorkingDir  			= 	""
	#$game.gameactions[0].TrackingMode 			= 	[Playnite.SDK.Models.TrackingMode]
	#$game.gameactions[0].TrackingPath 			= 	""

	$game.gameactions[0].ISplayAction			=	$global:newaction_actionstart
	
	if (($game.gameactions[1].IsPlayaction -eq $True) -and ($global:oldaction_actionstart -eq $False)) {
	$game.gameactions[1].IsplayAction=$False}
	
	f2-3-4build

}#end create3

function create4_noGA()
{
		param(
		$getGameMenuItemsArgs
	)
	
$initialDirectory=$game.installdirectory	
	
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Exe files (*.exe)|*.exe|Tutti i file (*.*)|*.*"
$dialog.InitialDirectory = $game.installdirectory  


if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
	$game_fold = $dialog.FileName

   
}

#$baext= $game_exe.extension
#$game_exe  = [System.IO.Path]::GetFileName($game_fold)
#$gamee=[System.IO.Path]::GetFileNameWithoutExtension($game_exe)
$game_dir=[System.IO.Path]::GetDirectoryName($game_fold)
#$source=$game.source

	


$game.gameactions = New-Object System.Collections.Generic.List[Playnite.SDK.Models.GameAction]
$newgameaction = New-Object Playnite.SDK.Models.GameAction


	$newgameaction.name 				=	"SkipUacTask"	 
	$newgameaction.path		 		  	=	"$runfile"
	$newgameaction.arguments 			=	""	 
	$newgameaction.additionalarguments 	=	""
	$newgameaction.type 				=	[Playnite.SDK.Models.GameActionType]::Script			
	$newgameaction.ISplayAction			=	$global:newaction_actionstart	
	$newgameaction.WorkingDir  			= 	""
	#$game.gameactions[0].TrackingMode 			= 	[Playnite.SDK.Models.TrackingMode]
	#$game.gameactions[0].TrackingPath 			= 	""
	$game.gameactions.Add($newgameaction)
	
	$game.gameactions[0].ISplayAction			=	$global:newaction_actionstart	
	
	f2-3-4build


}





function f2-3-4build {
		
		param(
		$getGameMenuItemsArgs
	)
	

$game_exe  = [System.IO.Path]::GetFileName($game_fold)
$gamee=[System.IO.Path]::GetFileNameWithoutExtension($game_exe)
$game_dir=[System.IO.Path]::GetDirectoryName($game_fold)
if($game.source.name -eq "GOG"){$source="GalaxyClient"}elseif($game.source.name -eq "Epic"){$source="EpicGamesLauncher"}elseif(($game.source.name -eq "Ubisoft Connect") -or ($game.source.name -eq "Uplay")){$source="upc"}elseif($game.source.name -eq "EA App"){$source="EA Desktop"}elseif($game.source.name -eq "Amazon"){$source="Amazon Games"}else{$source=$game.source.name}
if($game.source.name -eq "Steam"){$source_path="$global:steam_location\steam.exe"}elseif($game.source.name -eq "Epic"){$source_path="$global:Epic_location\EpicGamesLauncher.exe"}elseif(($game.source.name -eq "Ubisoft Connect") -or ($game.source.name -eq "Uplay")){$source_path="$global:Ubisoft_Connect_location\upc.exe"}elseif($game.source.name -eq "EA App"){$source_path="$global:EA_App_location\EA Desktop.exe"}elseif($game.source.name -eq "GOG"){$source_path="$global:GOG_location\GalaxyClient.exe"}elseif($game.source.name -eq "Amazon"){$source_path="$global:Amazon_location\Amazon Games.exe"}
if($game.source.name -eq "Steam"){$source_param="-silent -nobootstrapupdate -skipinitialbootstrap -skipStartScreen"}else{$source_param=""}
$source_exe="$source.exe"


$taskfolder="$($folder)\task"
$runfolder="$($folder)\run"
$scriptfolder="$($folder)\client\script"
$progfolder="$($folder)\client\prog"
$progrunfolder="$($folder)\client\prog\run"
$progtaskfolder="$($folder)\client\prog\task"


$clientkill="$($source)kill"


$time=(Get-Date).AddMinutes(-30).ToString("HH:mm")


New-Item -Path $taskFolder -ItemType Directory -Force
New-Item -Path $runFolder -ItemType Directory -Force
New-Item -Path $scriptfolder -ItemType Directory -Force
New-Item -Path $progFolder -ItemType Directory -Force
New-Item -Path $progrunfolder -ItemType Directory -Force
New-Item -Path $progtaskfolder -ItemType Directory -Force


$commandskill="	
`$Action = New-ScheduledTaskAction -Execute `"$($progfolder)\$clientkill.bat`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($source)kill`" -User `"$($user)`" -RunLevel Highest -Force
start-sleep -s 2
exit
#pause
	"

	$batclientkill="$progfolder\$clientkill.bat"
	$batclientcontent= "taskkill /F /IM $source_exe" | Out-File -FilePath $batclientkill -Encoding ASCII

	$batclientkillrun="$progrunfolder\$clientkill.bat"
	$batclientcontentrun= "schtasks /run /tn `"SkipUacTask\$($clientkill)`"" | Out-File -FilePath $batclientkillrun -Encoding ASCII
	
	$batclientkilltask="$progtaskfolder\$clientkill.ps1"
	$batclientcontenttask= $commandskill | Out-File -FilePath $batclientkilltask -Encoding ASCII
	

if($source_param -ne ""){
$sourcepam="-Argument `"$source_param`""
} else{$sourcepam=""}

#ACTIONSCRIPT:
$game.gameactions[0].script="`$game_exe = `"$game_exe`"
`$proc = Start-Process `"$runfolder\$($gamename) ($($game.source.name)).bat`" -WindowStyle Minimized -PassThru
`$client_wait=$global:client_wait
`$client_wait |Out-String |Out-File -FilePath `"c:\temp\clientwait.txt`" -Encoding ASCII
`$gamee = `"$gamee`"
while (-not (Get-Process -Name `"$gamee`" -EA 0)) {
    Start-Sleep -Seconds 2}
`$wait_exe=$global:wait_exe
start-process `"$PSScriptRoot\batKiller.exe`" -Argument `$game_exe,`$wait_exe
`$proc.WaitForExit()
`$proc.Dispose()
#`$game_fold = `"$($game_fold)`"
`$proc2= Start-Process `"$($progrunfolder)\$($clientkill).bat`" -WindowStyle Minimized -PassThru
while (Get-Process -Name $source -EA 0) {
    Start-Sleep -Seconds 1}
start-process `"$source_path`" $sourcepam
"

<# #Useless: if you enter custom parameters, Steam will prompt you if you want to start the game with these.
if (($arg)-and ($game.source.name -ne "Steam")){
$commandsscr="
taskkill /F /IM $source_exe

:wait_for_termination
tasklist /FI `"IMAGENAME eq $source_exe`" | find /I `"$source_exe`"
if not errorlevel 1 (
    timeout /t 1 /nobreak
    goto wait_for_termination
)

start `"`" /min `"$source_path`" $source_param

:wait_for_client
tasklist /FI `"IMAGENAME eq $source_exe`" | find /I `"$source_exe`"
if errorlevel 1 (
    timeout /t 1 /nobreak
    goto wait_for_client
)
set /p client_wait=<`"C:\temp\clientwait.txt`"
timeout /t %client_wait%
start `"`" /d `"$game_dir`" `"$game_exe`" $arg
"
}else{
#> 
$commandsscr="
taskkill /F /IM $source_exe

:wait_for_termination
tasklist /FI `"IMAGENAME eq $source_exe`" | find /I `"$source_exe`"
if not errorlevel 1 (
    timeout /t 1 /nobreak
    goto wait_for_termination
)

start `"`" /min `"$source_path`" $source_param

:wait_for_client
tasklist /FI `"IMAGENAME eq $source_exe`" | find /I `"$source_exe`"
if errorlevel 1 (
    timeout /t 1 /nobreak
    goto wait_for_client
)
set /p client_wait=<`"C:\temp\clientwait.txt`"
timeout /t %client_wait%
start `"`" /d `"$game_dir`" `"$game_exe`"
"
#}#endif disabled if (if (($arg)-and ($game.source.name -ne "Steam"))) 

$commands="
`$Action = New-ScheduledTaskAction -Execute `"powershell`" -Argument `"-WindowStyle Hidden -Command ```"Start-Process ```'$($scriptfolder)\$($gamenamess) ($($game.source.name)).bat```' -NoNewWindow```"`"
`$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable:`$false
`Register-ScheduledTask -Action `$Action -Settings `$Settings -TaskName `"SkipUacTask\$($gamename) ($($game.source.name))`" -User `"$($user)`" -RunLevel Highest -Force
"
#pause	
	$batscr="$($scriptfolder)\$($gamename) ($($game.source.name)).bat"
	$batscrcontent= $commandsscr | Out-File -FilePath $batscr -Encoding ASCII
	
	$batfile="$($taskfolder)\$($gamename) ($($game.source.name)).ps1"
	$batcontent=$commands + "`r`n" + $commandskill| Out-File -FilePath $batfile -Encoding ASCII


$runfile=    "$($runfolder)\$($gamename) ($($game.source.name)).bat"
$runcommand = "schtasks /run /tn `"SkipUacTask\$($gamename) ($($game.source.name))`""
$titlecommand = "title SkipUacTask"
$pausecommand=  "pause" 
$runcommands = "$runcommand`r`n$titlecommand`r`n$pausecommand"
$runcontent= $runcommands | Out-File -FilePath $runfile -Encoding ASCII


start-process "powershell" -Argumentlist "-file `"$($taskfolder)\$($gamename) ($($game.source.name)).ps1`"" -Verb RunAs
	
	
}
