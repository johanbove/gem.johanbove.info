@ECHO OFF

:: script global variables
SET me=%~n0
SET parent=%~dp0

ECHO %me%: started...

git add .
git commit -a -m "Update content"
git push origin master
git push raspberrypi master

:: force execution to quit at the end of the "main" logic
EXIT /B %ERRORLEVEL%
