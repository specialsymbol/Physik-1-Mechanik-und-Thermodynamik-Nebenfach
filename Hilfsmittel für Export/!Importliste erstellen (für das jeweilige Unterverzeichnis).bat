@ECHO OFF
del *.html *.htm *.txt thumb*.png
setlocal
for %%p in (.) do set pfad=%%~np

for /f %%u in ('dir /b /o:d *.png') do ren %%~nu.png %pfad%%%~nu.png

for /f %%i in ('dir /b /o:d *.png') do echo ^<img^ src^=^"Q%%i^"^>;^<img^ src^=^"A%%i^"^> >> ..\%pfad%import.txt

rem if not exist ..\UE md ..\UE

rem if exist ..\UE move *.png ..\UE

echo %pfad% >> ..\"Verarbeitete Verzeichnisse.txt"

endlocal