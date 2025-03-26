# SkipUacTask (PlayniteExtension)

- This extension allows you to automatically create administrator tasks in Task Scheduler for games that require elevated rights, in order to run them without triggering any UAC prompts. A new Script action, containing all the necessary commands, will be created.
- It works with emulated games that require privileges (such as Bluestack games), standalone games and with Steam, Epic and Ubisoft Connect games. 
- For client-based games the extension employs a workaround: the launcher is terminated and restarted with elevated privileges, after which the game is launched. This ensures that certain titles, like GTA V on Epic, will not trigger any UAC prompts.
- Game time tracking works flawlessly, thanks to a background process launched by the script.
- To use this extension you need to read how it works. Some games may also require setting two parameters for running.

## How it works:

- For non-client based games (such as ROMs, or standalone titles where the exe is defined in the game action's path) SkipUacTask takes the path of the 1st game action (at the top). A new Script-type game action will be created and placed above the existing ones, then the extension creates a task in the Taskscheduler with administrator privileges. 
- When launching a game with SkipUacTask action, a batch file (.bat) is executed to start the associated task in TaskScheduler, allowing the game to run with elevated privileges without UAC prompt.
- Game time tracking works perfectly: the script first creates a background window (SkipUacTask) that ensures the tracking with its presence, then starts a program (Batkiller) that checks the presence of game's exe. Once the game is closed Batkiller terminates the SkipUacTask window and you'll return to Playnite. 
- **For games managed by launchers (Steam, Epic, Ubisoft Connect):**
  - If there isn't any action and the game is managed by the library integration, a file dialog pointing on install folder appears, prompting you to choose the game's exe.
  - If there's a gameaction with an empty path on top, or if the path content is unsopported (e.g, a manual in .pdf) the same file dialog appears.
  - If there's an action with an exe defined on top, the path content will be taken.
- **For Steam, Epic, and Ubisoft Connect games, the client process will be terminated, restarted with elevated privileges, and then the game will be launched through the chosen executable.**

## Troubleshooting and Configuration:

- Some games require to be started with a delay to ensure that the client has been fully started. If you launch a game and receive "The SkipUacTask window has been closed" message, change the $client_wait variable to a value like 5 (this is the value I set for GTAV for Epic). You can adjust it per game on game's action script, or globally. 
- Some games (so far, I've only noticed this with Ubisoft Connect and Splinter Cell Conviction) will terminate game's exe and releaunch it, so Batkiller will close the SkipUacTask window and you'll return to Playnite. In these cases you need to set the $wait_exe variable to a higher value such as 15 or 20 (seconds), so when a game's process will be terminated Batkiller will wait the game's process for the defined time. $wait_exe (available only on client-managed games) does not delay the game starts, but will delay the return to Playnite once the games is closed. The default value is 3 seconds. You can edit it in game's action script or alter globally editing the extension and reloading it.
- You can edit these variables:
  - $global:directory: Contains the path where all task and runfiles are stored.
  - $global:newaction_actionstart: This variable defines the behaviour of the SkipUacTask new action created. If $True the new action is set like IsPlay, which mean that the new can starts the game.
  - $global:oldaction_actionstart: This variable defines the behaviour of the previous top action. If $False IsPlay is turned off. If $True the setting will not be changed. 


## Warning:
This extension comes with no warranties. Please, read the instructions and be aware that to make this extension work, it involves a bit of a workaround. Some features may not work, there could be bugs, and other issues. Please, be cautios when you're downloading a game. In my tests, the client resumes from where it leff off, but I can't bee sure about all the cases.

## Notes:
- Tell me if you would you like to have a new feature or the support for an other launcher. Feel free to report bugs or problems.
- In future I may add support for other launchers. I haven't try Bethesda, Indiegala, Xbox Game and Xbox Game Pass.
- From what I've observed, GOG launcher has a service that ensures to execute things with elevated privileges when needed, so SkipUacTask will not affect GOG's games.
- Based on my tests, EA App can't run games like administrator.
- Amazon Games doesn't require the launcher to be started. However, I haven't added support for it yet. Let me know if there are Amazon Games that require administrator privileges.
- I'm not sure if Splinter Cell Conviction is closed and restarted to run without administrator privileges. However, I haven't tested what happens with other Ubisoft Connect games.
- When launching GTAV after a long time with TaskSkipUac, a message appeared while logging into Rockstar stating that the game couldn't be found on the account. I'm not sure if this issue was caused by launching the game with administrator privileges, but running it with elevated rights didn't cause any other problems.
- For some launchers, I've only tested one game (Burnout Paradise for EA App, Splinter Cell Conviction for Ubisoft Connect, Grand Theft Auto V for Epic). I've done several tests with Steam games, although I didn't have any games that require administrator privileges. However, I might need to reinstall Max Payne 3, as I remember it triggered many UAC prompts, similar to GTA V.
