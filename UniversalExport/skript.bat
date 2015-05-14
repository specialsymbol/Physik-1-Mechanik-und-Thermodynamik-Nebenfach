@echo off
cls
setlocal
set c=1

if not exist .\UE md .\UE
for /f %%w in ('dir /b .\*.') do if not %%w==UE call :processfolder %%w
goto :eof

:processfolder
if exist .\%~n1\thumb*.png del .\%~n1\thumb*.png
set l=0
for /f %%u in ('dir /b /o:d .\%~n1\*.png') do ren .\%~n1\%%~nu.png %~n1%%~nu.png
for /f %%i in ('dir /b /o:d .\%~n1\*.png') do call :generatelist %1 %%i
if exist .\UE move .\%~n1\*.png .\UE
echo %~n1>> .\"Verarbeitete Verzeichnisse.txt"
rd /s /q %~n1
set /a c+=1
goto :eof

:generatelist
if %l% neq 0 echo.>> .\%~n1import.txt
if %c% lss 10 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_0%c%>> .\%~n1import.txt
if %c% gtr 9 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_%c%>> .\%~n1import.txt
set /a l+=1
goto :eof

:eof
endlocal