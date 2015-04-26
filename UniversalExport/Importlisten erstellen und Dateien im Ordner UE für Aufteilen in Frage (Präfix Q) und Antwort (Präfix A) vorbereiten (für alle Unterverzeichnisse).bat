@echo off
cls
setlocal

for /f %%w in ('dir /b .\*.') do if not %%w==UE call :generatelist %%w
goto :eof

:generatelist
if exist .\%~n1\thumb*.png del .\%~n1\thumb*.png
for /f %%u in ('dir /b /o:d .\%~n1\*.png') do ren .\%~n1\%%~nu.png %~n1%%~nu.png
for /f %%i in ('dir /b /o:d .\%~n1\*.png') do echo ^<img^ src^=^"Q%%i^"^>;^<img^ src^=^"A%%i^"^> >> .\%~n1import.txt
if not exist .\UE md .\UE
if exist .\UE move .\%~n1\*.png .\UE
echo %~n1 >> .\"Verarbeitete Verzeichnisse.txt"
rd /s /q %~n1
goto :eof

:eof
endlocal