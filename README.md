# MobLevel
Displays the level of the currently selected mob. This is fetched via widescan. The level will be color-coded based on the challenge level of the target, and bold if the target is high enough level to aggro.

![Incredibly Tough](http://DiscipleOfEris.github.io/MobLevel_IncrediblyTough.png)
![Too Weak](http://DiscipleOfEris.github.io/MobLevel_TooWeak.png)
![Easy Prey Aggro](http://DiscipleOfEris.github.io/MobLevel_AggroEasyPrey.png)
![Easy Prey No Aggro](http://DiscipleOfEris.github.io/MobLevel_NoAggroEasyPrey.png)

The color-coding can be be changed in `addons/MobLevel/data/settings.xml`.

## Installation
After downloading, extract to your Windower addons folder. Make sure the folder is called MobLevel, rather than MobLevel-master or MobLevel-v1.whatever. Your file structure should look like this:

    addons/MobLevel/MobLevel.lua

Once the addon is in your Windower addons folder, it won't show up in the Windower launcher. You need to add a line to your scripts/init.txt:

    lua load MobLevel

## Commands
You can use `//moblevel` or `//level`.

    //level scan -- do a scan.  
    //level auto -- toggles auto scanning, both when targetting an unscanned mob and rescanning on an interval  
    //level interval <seconds> -- set the autoscan interval.
    //level aggro [player_level] -- Reports the level range that will aggro the player, or player_level if provided.
    //level tw|ep|dc|em|t|vt|it [player_level] -- Reports the level range that will check as the given challenge rating.
