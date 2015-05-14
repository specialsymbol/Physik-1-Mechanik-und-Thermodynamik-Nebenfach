@echo off
:: unterdrückt die ausgabe der eingabebefehle. zu testzwecken kann 'echo on' gesetzt werden, wenn man das skript aus der kommandozeile startet. '@' unterdrückt bereits die eingabe 'echo on', 'echo off' entspricht also einem vorangestellten '@' in jeder zeile. wird das skript mit 'echo on' per doppelklick gestartet werden die eingabebefehle zwar ebenfalls angezeigt, jedoch wird das fenster nach ausführung geschlossen und die eingaben sind so nur für einen sehr kurzen moment sichtbar
cls
:: löscht den bildschirm, erhöht die übersichtlichkeit wenn man zu testzwecken echo on lässt
setlocal
:: setzt die variablen nur lokal für dieses skript. so wird die kontamination der variablen anderer skripte durch dieses skript vermieden, außerdem erleichtert es das testen

set c=1
:: setzt eine variable als zähler für die tags

if not exist .\UE md .\UE
:: erstellt den ordner "UE" sofern er nocht nicht existiert

:: Schleife 1:
for /f %%w in ('dir /b .\*.') do if not %%~nw==UE call :processfolder %%w
:: schleife durch eine liste von verzeichnisnamen (*.), außer wenn die variable %%w den wert "UE" hat - dieses verzeichnis wird ignoriert
:: die schleife ruft einen neuen prozess auf namens "processfolder" und übergibt diesem als parameter die variable %%w
:: %%~nw wird anstelle von %w verwendet weil in batch-prozessen variablen, anders als beim direkten aufruf eines befehls aus der kommandozeile, ein zweites % benötigen
:: das ~n in %%~nw gibt nur den pfadnamen aus statt der kompletten pfadbezeichnung. möglicherweise ist dieser schritt überflüssig und man kann %%w verwenden, ich weiß jedoch nicht warum. später in schleife 3 bei den dateinamen ist dieser schritt auf jeden fall notwendig
goto :eof
:: dieser schritt verhindert, dass nach dem planmäßigen durchlaufen des prozesses "processfolder" dieser erneut betreten wird (sogenanntes durchfallen)

:processfolder
:: diese schleife wird für jeden gültigen ordnernamen aufgerufen
:: in dieser schleife wird der jeweilige ordner bearbeitet - die dateien werden umbenannt, eine liste erstellt (über einen weiteren prozess), die umbenannten dateien werden verschoben und der ordner abschließend gelöscht. zusätzlich wird die zahl der bearbeiteten ordner erfasst um tags für lernkartensätze in Anki zu generieren und eine liste bearbeiteter ordner erstellt
if exist .\%~n1\thumb*.png del .\%~n1\thumb*.png
:: löscht möglicherweise vorhandene vorschaubilder, welche erstellt wurden falls während dem exportvorgang aus Impress "Create title page" aktiviert war
set l=0
:: setzt die variable für die linienzahl zurück auf null. diese wird benötigt um den manuellen zeilensprung vor jeder zeile (außer der ersten) einzufügen

:: schleife 2:
for /f %%u in ('dir /b .\%~n1\*.png') do ren .\%~n1\%%~nu.png %~n1%%~nu.png
:: schleife durch eine liste von dateinamen. erfasst werden nur .png-dateien im ordner %~n1 (parameter 1 aus variable %%w aus schleife 1)
:: in der schleife werden die dateinamen durch den vorangestellten ordnernamen ergänzt
:: der ordnername in variable %%w wurde als parameter an den prozess übergeben (%%w aus schleife 1 ist hier parameter %1. %~n1 gibt nur den ordnernamen aus, da in %1 der komplette pfad enthalten ist. gleiches gilt für %%~nu, welches nur den dateinamen der dateibezeichnung in der variablen %%u ausgibt)

::schleife 3:
for /f %%i in ('dir /b /o:d .\%~n1\*.png') do call :generatelist %1 %%i
:: schleife durch eine liste von dateibezeichnungen. für jeden eintrag wird der prozess "generatelist" aufgerufen, an welchen zwei parameter übergeben werden: der erste parameter %1 der schleife 2 (ursprünglich die variable %%w, welche die ordnerbezeichnung enthält) und die variable %%i, welche die dateibezeichnung enthält

if exist .\UE move .\%~n1\*.png .\UE
:: falls der ordner UE existiert werden die in schleife 2 umbenannten dateien aus dem bearbeiteten ordner in diesen verschoben
echo %~n1>> .\"Verarbeitete Verzeichnisse.txt"
:: erweitern einer liste um den namen des verarbeiteten ordners. hier wird echo verwendet damit bei einer weiteren erweiterung in einer neuen zeile begonnen wird.
rd /s /q %~n1
:: entfernen des bearbeiteten ordners. die benötigten dateien wurden umbenannt und aus diesem in den ordner UE verschoben
set /a c+=1
:: erhöht die variable für die tags pro bearbeitetem ordner um 1
goto :eof

:generatelist
:: dieser prozess erstellt eine liste für den import in Anki. da der befehl 'echo' immer einen zeilensprung nach der zeile anfügt wird hier hack benutzt um dies zu umgehen. daher muß der zeilensprung vor allen folgenden einträgen jedoch manuell eingefügt werden.
if %l% neq 0 echo.>> .\%~n1import.txt
:: fügt einen zeilensprung vor jeder zeile ein, außer der ersten. der zähler wird im übergeordneten prozess auf null zurückgesetzt und nach jeder zeile um eins erhöht (am ende dieses unterprozesses)
:: 'echo.' erzeugt den zeilensprung. >> muss direkt darauffolgen, da sonst nach dem zeilensprung ein leerzeichen mit ausgegeben wird.
if %c% lss 10 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_0%c%>> .\%~n1import.txt
:: benennt die tags sinnvoll mit einer vorgestellten 0 bei einstelliger kapitelnummer
:: %c% lss 10 bedeutet: die bedingung ist erfüllt, wenn die nummer %c% des bearbeiteten ordners kleiner als 10 ist (also 1..9). der zähler %c% wird im übergeordneten "ordnerprozess" :processfolder gesetzt
:: 'set /p' ist ein hack, welcher anders als 'echo' eine ausgabe ohne zeilensprung am ende erzeugt. er gibt die angegebene zeile aus und wartet anschließend auf eine benutzereingabe (in der gleichen zeile, daher kein LF)
:: < nul übergibt eine leere eingabe an 'set /p', so dass im endeffekt nur die ausgabezeile ausgegeben wird
:: >> muß ohne leerzeichen direkt an die ausgabezeile angefügt werden, da sonst das leerzeichen ebenfalls mit ausgegeben wird
if %c% gtr 9 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_%c%>> .\%~n1import.txt
:: wie eine zeile darüber, nur für zweistellige ordnerziffern ohne vorangestellte null.
:: %c% gtr 9 bedeutet: die bedingung ist erfüllt, wenn die nummer %c% des bearbeiteten ordners größer als 9 ist (also 10...).
set /a l+=1
:: erhöht den linienzähler um eins
goto :eof

:eof
endlocal