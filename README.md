# 🛡️ SkipUacTask (PlayniteExtension)
✨ Play your favourite games with elevated rights, without being interrupted by UAC prompts.
<!--✨ An extension for launching games that require admin privileges without Uac prompt. !-->

- This extension allows you to automatically create administrator tasks in Task Scheduler for games that require elevated rights, allowing them to run without triggering any UAC prompts. A new Script action named SkipUacTask, containing all the necessary commands, will be created.
- It works with emulated games that require privileges (such as Bluestack games), standalone games and with Steam, Epic and Ubisoft Connect games. 
- For client-based games the extension employs a workaround: the launcher is terminated and restarted with elevated privileges, after which the game is launched. This ensures that certain titles, like GTA V on Epic, will not trigger any UAC prompts.
- Game time tracking works flawlessly, thanks to a background process launched by the script.
- Please read how this extension works. Some games may also require setting two parameters for running.

## 🛠️ How it works:

- For standalone titles (non-client-based games) where the executable is defined in the game action's path, SkipUacTask takes the path from the first game action (the topmost one). For ROMs, it automatically retrieves all emulation-related information, specifically the emulator used, profile, arguments, and additional arguments. A new Script-type game action (SkipUacTask) will be created and placed above the existing ones. The extension then creates a task in Task Scheduler with administrator privileges.
- When launching a game with the SkipUacTask action, a batch file (.bat) is executed to start the associated task in Task Scheduler, allowing the game to run with elevated privileges without a UAC prompt.
- Game time tracking works perfectly: the script first creates a background window `(SkipUacTask)` that ensures the tracking with its presence, then starts a program `(Batkiller)` that checks the presence of game's exe. Once the game is closed, Batkiller terminates the `SkipUacTask window` and you'll return to Playnite. 
- **For games managed by launchers (Steam, Epic, Ubisoft Connect):**
  - If there isn't any action and the game is managed by the library integration, a file dialog pointing on install folder appears, prompting you to choose the game's exe.
  - If there's a gameaction with an empty path on top, or if the path content is unsopported (e.g, a manual in .pdf) the same file dialog appears.
  - If there's an action with an exe defined on top, the path content will be taken.
- **For Steam, Epic, and Ubisoft Connect games, the client process will be terminated, restarted with elevated privileges, and then the game will be launched through the chosen executable. Once the game is closed, the client will be ended and relaunched without administrative rights.**

## ⚙️ Troubleshooting and Configuration:

- Some games require to being started with a delay to ensure that the client has been fully started. If you launch a game and get `"The SkipUacTask window has been closed"`, set the `$client_wait` variable to a value like 5 (this is the value I set for GTAV for Epic). You can adjust it per game in the game's action script, or globally. 
- With some games (so far, I've only noticed this with Ubisoft Connect and Splinter Cell Conviction) the launcher will terminate game's exe and relaunch it, so `Batkiller` will close the SkipUacTask window and you'll return to Playnite. In these cases you need to set the `$wait_exe` variable to a higher value such as 15 or 20 (seconds), so when a game's process will be terminated `Batkiller` will wait for the game's process for the defined amount of time. The variable (available only on client-managed games) does not delay the game start, but will delay the return to Playnite once the game is closed. The default value is 3 seconds. You can edit it in game's action script or alter globally editing the extension and reloading it.
- Other than these, you can edit the following variables:
  - `$global:directory` Contains the path where all task and runfiles are stored.
  - `$global:newaction_actionstart` Defines the behaviour of the mew SkipUacTask action created. If $True the new action is set like IsPlay, which means that the new can starts the game.
  - `$global:oldaction_actionstart` Defines the behaviour of the previous top action. If $False IsPlay is turned off. If $True the setting will not be changed.
  - `$global:lnkstyle` defines the behavior of SkipUacTask when a .lnk file is defined in the action's path. When lnkstyle is set to 2, the .lnk file will be maintained, so the Task Scheduler task will launch the .lnk file directly. When lnkstyle is set to 1, SkipUacTask retrieves the target of the .lnk file, so the Task Scheduler task will launch the pointed executable along with its parameters.
  - You can also edit the installation path of each launcher by modifying variables like `$global:Steam_location`, `$global:Epic_location`, `$global:Ubisoft_Connect_location`, etc. 
- When using emulators, **relative paths** (e.g., `.\cores\pcsx1_libretro.dll`) specified in the **Parameters** and **Additional arguments** fields (both in customs and integrated profiles) are automatically **converted to absolute paths** when the Task Scheduler task is created. This ensures the task runs correctly.  
For example, in a RetroArch profile where Integrated Parameters are: `-L ".\cores\pcsx1_libretro.dll" "{ImagePath}"` and RetroArch is installed in `C:\RetroArch`, the final command in the task will be:  
`-L "C:\RetroArch\cores\pcsx1_libretro.dll" "X:\Games\MyGame.iso"`  
Any path starting with `.\` will be replaced by the full path of the emulator defined in the action or profile.


## ⚠️ Warning:
This extension comes with no warranties. Please read the instructions and be aware that, in order to make this extension work, I had to find some workarounds. Some features may not work, there could be bugs, and other issues. Please, be cautios when you're downloading a game. In my tests, the client resumes from where it leff off, but I can't bee sure about all the cases.

## 📝 Notes:
- Feel free to report bugs or problems, and let me know if you'd like a new feature or support for another launcher.. 
- In future I may add support for other launchers. I haven't try Bethesda, Indiegala, Xbox Game and Xbox Game Pass.
- If you start Steam games with parameters, Steam will ask you if you want to run the game with those parameters. Therefore, I have disabled the arguments for Steam (I've left comments).
- From what I've observed, GOG launcher has a service that ensures to execute things with elevated privileges when needed, so SkipUacTask will not affect GOG's games.
- Based on my tests, EA App can't run games like administrator.
- Amazon Games doesn't require the launcher to be started. However, I haven't added support for it yet. Let me know if there are Amazon Games that require administrator privileges.
- I'm not sure if Splinter Cell Conviction is closed and restarted to run without administrator privileges. However, I haven't tested what happens with other Ubisoft Connect games.
- When launching GTAV after a long time with TaskSkipUac, a message appeared while logging into Rockstar stating that the game couldn't be found on the account. I'm not sure if this issue was caused by launching the game with administrator privileges, but running it with elevated rights didn't cause any other problems.
- For some launchers, I've only tested one game (Burnout Paradise for EA App, Splinter Cell Conviction for Ubisoft Connect, Grand Theft Auto V for Epic). I've done several tests with Steam games, although I don't have any games that require administrator privileges.

If you enjoy the extension, you can buy me a coffee. It will be very appreciated ;)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E214R1KB)

- Install directly:
  [SkipUacTask](https://playnite.link/addons.html#SkipUacTask)
- Download last version:
[v1.0.3]( https://github.com/roob-p/SkipUacTask-PlayniteExtension/releases/download/v1.0.3/SkipUacTask_v1.0.3.pext)

<table style="width: 100%; text-align: left;">
  <tr>
    <td style="padding: 0; vertical-align: top;">
      <img src="https://github.com/roob-p/SkipUacTask-PlayniteExtension/blob/main/media/1.gif" style="width: 100%; height: auto;" />
    </td>
  </tr>
  <tr>
    <td style="padding: 0; vertical-align: top;">
      <img src="https://github.com/roob-p/SkipUacTask-PlayniteExtension/blob/main/media/2.gif" style="width: 100%; height: auto;" />
    </td>
  </tr>
</table>
