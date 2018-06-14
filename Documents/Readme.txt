***************************************************** Show OS GUI language
Setting ShowOSLanguage=1 (default ShowOSLanguage=0) in the program title
you can show the OSLang code.


***************************************************** Show command line option

Setting ShowCmdLine=1 (default ShowCmdLine=0) in the program title
you can show the parametrs passed to batch/command line to APK-Info.exe.


***************************************************** APK-Info shell integration

It's included a registry setting to enable sAPK.Info shell integration.
BEFORE to run it to activate shell integration, please edit the .reg.
You can do it with ex. Notepad++ and set the right path for APK-Info.exe (path without space)


********************************************** Multilanguage Info

The strings used by APK-Info GUI are located in APK-Info.ini file.
If you want add new translation - use section [Strings-en] as source.
Copy it and translate.

To create french translation add [String-fr] section

To create dutch translation add [String-nl] section

To create norwegian translation add [String-no] section

To create polish translation add [String-pl] section

To create portoguese translation add [String-pt] section

To create swedish translation add [String-sw] section


One time create new section copy and paste in the new section the messages 
of [Strings-en] section and translate it.

For more info about OSLang code please see on

https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm

The language codes already enabled as automatic detection are

ID = 0403 - Language_code="ca"
ID = 0409 - Language_code="zh-TW"
ID = 0409 - Language_code="en"
ID = 040c - Language_code="fr"
ID = 040e - Language_code="hu"
ID = 0410 - Language_code="it"
ID = 0413 - Language_code="nl"
ID = 0415 - Language_code="pl"
ID = 0416 - Language_code="pt-br"
ID = 0419 - Language_code="ru"
ID = 041b - Language_code="sk"
ID = 0421 - Language_code="id"
ID = 0429 - Language_code="fa"
ID = 0804 - Language_code="zh-CN"
ID = 0807 - Language_code="de" 
ID = 080a - Language_code="sp" 

Language strings already included in the program are for language 
ca,de,en,fa,fr,hu,id,it,nl,pl,pt-br,ru,sk,sp,zh-CN,zh-TW


*****************************************************Forced GUI language

ForceGUILanguage in APK-Info.ini

Setting a value for ForcedGUILanguage (default ForcedGUILanguage=0 means auto detect)
you can force a specifc language for test. Ex

ForcedGUILanguage=fr force GUI language to French.

If the language strings for the language forced are nota availabel it will show in English.


*****************************************************APK-Info GUI translatorForced

Catalan                  - 
Chinese Traditional      - Li Guiquan
Dutch                    - 
English                  - bovirus
Farsi                    - HesamEdin
French                   - Yoanf_26
German                   - mosu
Hungarian                - gidano
Indonesian               - exodius48
Italian                  - bovirus
Polish                   - Eselter
Portuguese (Brasilan)    - 41ui7i0
Russian                  - Kevin31
Spanish                  - Ksawery
Slovak                   - Ja_som
Taiwanese                - Li Bibo

