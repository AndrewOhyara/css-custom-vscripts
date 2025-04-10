# MultiJump Vscript
This addon offers the ability to make jumps in air. The jumps can be between normal jumps that depend on your current speed and TF2 jumps which recreates the Scout air jumping behaviour.

This script also generates a config file which you can customize. And chat commands for the host and clients.

# Index
- [Installation](#installation)
- [Configuration file](#configuration-file)
- [In-Game chat commands](#in-game-chat-commands)

## Installation
1. [Download the file "multijump.nut".](https://github.com/AndrewOhyara/css-custom-vscripts/blob/main/multijump_vscript/multijump.nut)
2. Move the file to the game folder at: <game_folder>/cstrike/scripts/vscripts 
  - For steam: Steam > Library > Counter-Strike: Source > Manage > Browse local files
3. Open the "mapspawn.nut" file and add this line:
```squirrel
IncludeScript("multijump", this);
```
- NOTE: In case the folder or file doesn't exist, create it instead.

## Configuration file
The configuration file is automatically generated after loading a map. 

The dir of the file is: <game_folder>/cstrike/scriptdata/multijump/multijump_configs.cfg

The config file should look like this (The comment lines aren't included):
```squirrel
{
  // Enable/Disable the script
  EnableScript = true
  
  // Enable/Disable the auto addition of new human players to the temporal client table.
  // The host player is automatically added regardless this setting.
  AutoAddClients = true

  // If AutoAddClients is true: Set the jump limit for new clients.
  JumpLimit = 1

  // If AutoAddClients is true: Set the jump force for new clients.
  JumpForce = 300

  // If AutoAddClients is true: Enable/Disable the TF2 mode state for new clients.
  TF2mode = false

  // If AutoAddClients and TF2mode is true:
  // Set the fixed side force when jumping and pressing any WASD buttons on air for new clients.
  TF2sideForce = 260

  // If AutoAddClients is true: 
  // Enable/Disable the stopping of the player air speed if they're not pressing any WASD buttons for new clients.
  // This is basically a mechanic with the Scout in TF2
  DoAirStop = false

  // If AutoAddClients is true: Enable/Disable the falldamge of the player for new clients.
  FallDamage = false

  // Enable/Disable the ability of the clients to change their own configs by in-game chat commands.
  // Changes are saved in this file if the steamid of the player is stored in the Users table
  CanClientsChangeConfigs = true

  // Enable/Disable the ability of Enable/Disable the ability of clients to jump while surfing.
  // They can still jumping in air if they won't land in a surf ramp.
  AllowJumpOnSurfing = false

  // This tables stores specific players by their steamid. The format is the STEAMID3.
  // You may want to use any steamidfinder website to add new clients anytime.
  // If you want to add a connected player in the server, use the command !mj_save_client <the user id of the player>
  // Or copy the table and replace the steam id of whoever you want.
  // The safe limit of how many users you can add is 75. This is due the limitation of vscript at reading files.
  Users =
  {
    "[U:1:216118329]" :  // The steam id of the player.
    {
      DisabledByAdmin = false  // True if the host used the command !mj_client_toggle
      JumpForce = 300
      JumpEnabled = true
      DoAirStop = false
      JumpLimit = 1
      TF2mode = false
      FallDamage = false
      TF2sideForce = 265
    }
  }

  // The interval of the announcement message in the server.
  // Use 0 to disable
  AnnouncementInterval = 180

  // Enable/Disable the debug mode for the server.
  // The debug mode should look like this: https://youtu.be/LxKWcJm65j0
  DebugJumps = false

  // The interval if the function that tracks the buttons and state of the players added in the client table.
  // -1 is the lowest interval based on the tickrate of the server.
  // You may not want to touch this setting.
  ThinkInterval = -1
} 
```
### NOTE: You can copy the code and paste it on your own config file but make sure to remove the commented lines to avoid reaching the read size limit (16384 bytes)

## In-game chat commands
You can customize the addon without opening the config file (unless it's a replicated config such as "JumpForce").

There are commands for clients and the host.

Type "!" or "/" and then the name of the command. 

Some commands require parameters. Example: !mj_jumplimit 100 | !mj_remove_saved_client [U:1:216118329]

- ### Client Commands
  - !mj_multijump - Enable/Disable the multijump for yourself.
  - !mj_tf2mode - Enable/Disable TF2 Scout jump mode.
  - !mj_falldamage - Enable/Disable the falldamage for yourself.
  - !mj_airstop - Enable/Disable the stopping of the air speed if you are not pressing any WASD buttons.
  - !mj_jumplimit |number| - How many jumps can you do in air.
  - !mj_jumpforce |number| - The force of the jump in the air.
  - !mj_tf2_sideforce |number| - The force of the side jump in air for TF2 Scout jump mode.
  - !mj_configs - Print your current configs in console.

- ### Host commands
  - !mj_print_clients - Print the configs of all clients in the console.
  - !mj_print_configs - Print the config file of the server.
  - !mj_script_toggle - Enable/Disable the script in the server.
  - !mj_autoadd_clients - Enable/Disable the auto add of new connected clients to the temporal client table.
  - !mj_allow_jump_on_surf - Enable/Disable the ability of clients to jump while surfing.
  - !mj_client_can_config - Enable/Disable the ability of the clients to modify their own configs.
  - !mj_client_toggle |userid| <save_changes: true | false> - Enable/Disable the jump ability of a connected client.
  - !mj_add_temporal_client |userid| - Adds a client in the temporal client table. It's not stored in the Users table.
  - !mj_save_client |userid| - Saves a connected client in the config file.
  - !mj_remove_saved_client |steamid3| - Removes a client by the steamid3 from the Users table.
  - !mj_debug - Enable/Disable the debug mode in the server.
  - !mj_reload_configs - Reloads the config file.
  

