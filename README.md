# BulletTracer
You probably already know what bullet tracing is? It is when a bullet trace is left in the air after your shot. With this plugin you will be able to use this feature, change the color of the bullet beam and its size.<br><br>Also, you will be able to adjust the color when hitting an enemy or just when shooting. Here's an example of what it looks like.<br><br>
My POV:<br>![GIF1](https://github.com/kekekekkek/BulletTracer/blob/main/Images/2.gif)<br><br>
POV of another player:<br>![GIF2](https://github.com/kekekekkek/BulletTracer/blob/main/Images/1.gif)<br><br>
Also, you can watch this short [video](https://youtu.be/_9UiKlCPguY) to see how this plugin works.

# Installation
Installing the plugin consists of several steps:
1. [Download](https://github.com/kekekekkek/BulletTracer/archive/refs/heads/main.zip) this plugin;
2. Open the `..\Sven Co-op\svencoop_addon\scripts\plugins` directory and place the `BulletTracer` folder there;
3. Next, go to the `..\Sven Co-op\svencoop` folder and find there the text file `default_plugins.txt`;
4. Open this file and paste the following text into it:
```
	"plugin"
	{
		"name" "BulletTracer"
		"script" "BulletTracer/BulletTracer"
	}
```
5. After completing the previous steps, you can run the game and check the result.

# Commands
When you start the game and connect to your server, you will have the following plugin commands at your disposal, which you will have to write in the game chat to activate them.
| Command | MinValue | MaxValue | DefValue | Description | Usage | 
| -------| -------- | -------- | -------- | ----------- | ----------- |
| `.btc`, `/btc` or `!btc` | `0 0 0` | `255 255 255` | `125 125 125` | Allows you to set the color of the beam when fired. | Usage: `.btc//btc/!btc <red> <green> <blue>.` Example: `!btc 125 125 125` |
| `.bthc`, `/bthc` or `!bthc` | `0 0 0` | `255 255 255` | `125 0 0` | Allows you to set the color of the beam when hitting an enemy. | Usage: `.bthc//bthc/!bthc <red> <green> <blue>.` Example: `!bthc 125 0 0` 
| `.bte`, `/bte` or `!bte` | `0` | `1` | `1` | Allows you to enable or disable this feature. | Usage: `.bte//bte/!bte <state>.` Example: `!bte 1` |
| `.bts`, `/bts` or `!bts` | `1` | `5` | `3` | Allows you to set the beam size. | Usage: `.bts//bts/!bts <size>.` Example: `!bts 3` |
| `.btt`, `/btt` or `!btt` | `0.1` | `1` | `0.5` | Allows you to set the beam disappearance time. | Usage: `.btt//btt/!btt <time>.` Example: `!btt 0.5` |
| `.btao`, `/btao` or `!btao` | `0` | `1` | `1` | Allows you to enable this feature only for admins or for all players.<br>`0 - For everyone;`<br>`1 - Admins only.` | Usage: `.btao//btao/!btao <adminsonly>.` Example: `!btao 0` |
| `.btr`, `/btr` or `!btr` | `-` | `-` | `-` | Allows you to reset the settings to the default settings. | `No arguments.` |

**REMEMBER**: This plugin only works for admins. If you want the plugin to work for everyone, you need to enter the command `!btao 0` in chat.<br>
**REMEMBER**: This plugin doesn't use the `WeaponSecondaryAttack` and `WeaponTertiaryAttack` hooks, as there will be some peculiarities to consider. You can finalize this yourself if you want.<br>
**REMEMBER**: You can remove the restriction for commands such as beam length by simply editing some lines of code.<br>
**REMEMBER**: Also, you can change the name of your sprite in the plugin code or put a different file in the directory.<br>
**REMEMBER**: The plugin has some bugs, such as the beam coming from the player's face during a shot instead of from their weapon. You will need to adjust the vector.
