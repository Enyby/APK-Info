# APK-Info
APK-Info is a Windows tool to get detailed info about an apk file.

The app was originally created by ZoSTeR and posted on [Total Commander Forum](http://www.ghisler.ch/board/viewtopic.php?t=32908)

Then was updated by jazzruby and this is the [original jazzruby thread on XDA](https://forum.xda-developers.com/showthread.php?t=2359373)

Then was updated by bovirus and this is the [reworked thread on XDA](https://forum.xda-developers.com/showthread.php?t=3614970)

![APK-Info](https://github.com/Enyby/APK-Info/blob/master/screenshot.png?raw=true "APK-Info")

Allows you to view:
- application icon,
- package name,
- name (in all languages),
- version,
- build number,
- the minimum, maximum and target version of the SDK (Android),
- supported density (DPI) and screen size,
- architecture (ABI),
- supported textures,
- permissions,
- features,
- signature,
- version of OpenGL ES,
- support Android TV, Wear OS and Android Auto,
- locales,
- a variety of hashes (MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512)
- and a lot of other information.

The application is translated into 86 languages. The language is selected automatically based on the language of the operating system, but you can specify the language in the settings file.

The app allows you to go to Google Play, a custom store and VirusTotal.

You can rename an APK file using a pre-defined pattern with substitutions.

You can also install or remove this APK file on a device or emulator connected via ADB.

There is integration in the Windows shell.

# APK-Info features
- Support up to latest API Levels available
- To add future SDK don't require program changes because is defined in external ini file.
- Multilingual GUI. It's possible add new language without program change, but just editing external INI file.
- Automatic recognition of OS language and set the right GUI language (86 languages)
- Option in configuration file to force a specific GUI language
- Option in configuration file to define pattern for rename filename
- Windows shell integration (optional)
- Support Drag'n'Drop APK to the program window.

# Using
You can open the APK file in APK-Info using one of the following methods:
- Start APK-Info, and then select the APK file in the dialog.
- Open the APK file by click on the open button in the dialog.
- Drag the APK file to APK-Info.exe or its shortcut.
- Drag the APK file into the running APK-Info window.
- Open the APK file by double-clicking, after installing APK-Info, as a program for opening APK files (via explorer or attached .cmd file).

# Download
[Latest releases](https://github.com/Enyby/APK-Info/releases)

[Library of old APK-Info versions](https://mega.nz/#F!DNZxjaAb!2Xx8Y_CO6PYwGDnLRgS5_g)

# How to build the latest version

1. Download [the latest release](https://github.com/Enyby/APK-Info/releases/latest).
2. Download [the source from github](https://github.com/Enyby/APK-Info/archive/master.zip).
3. Unpack the source on top of the release.
4. Open the `Application-source\APK-Info.au3` file in the [SciTE4AutoIt3 editor](https://www.autoitscript.com/site/autoit-script-editor/downloads/).
5. Press F7. The `Apk-Info.exe` file will be updated.

# API Level supported
```
Level  1 = Base
Level  2 = Base 1.1
Level  3 = Cupcake
Level  4 = Donut
Level  5 = Eclair
Level  6 = Eclair 0.1
Level  7 = Eclair MR1
Level  8 = Froyo
Level  9 = Gingerbread
Level 10 = Gingerbread MR1
Level 11 = Honeycomb
Level 12 = Honeycomb MR1
Level 13 = Honeycomb MR2
Level 14 = Ice Cream Sandwich
Level 15 = Ice Cream Sandwich MR1
Level 16 = Jelly Bean
Level 17 = Jelly Bean MR1
Level 18 = Jelly Bean MR2
Level 19 = KitKat
Level 20 = KitKat Watch
Level 21 = Lollipop
Level 22 = Lollipop MR1
Level 23 = Marshmallow
Level 24 = Nougat
Level 25 = Nougat MR1
Level 26 = Oreo
Level 27 = Oreo MR1
Level 28 = Pie
```

# Additional info
[Android API version](https://developer.android.com/studio/releases/platforms)

# APK-Info Changelog
[Changelog](Documents/Changelog.txt)
