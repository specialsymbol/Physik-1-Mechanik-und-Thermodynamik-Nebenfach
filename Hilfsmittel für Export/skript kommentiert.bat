@echo off
:: unterdr�ckt die ausgabe der eingabebefehle. zu testzwecken kann 'echo on' gesetzt werden, wenn man das skript aus der kommandozeile startet. '@' unterdr�ckt bereits die eingabe 'echo on', 'echo off' entspricht also einem vorangestellten '@' in jeder zeile. wird das skript mit 'echo on' per doppelklick gestartet werden die eingabebefehle zwar ebenfalls angezeigt, jedoch wird das fenster nach ausf�hrung geschlossen und die eingaben sind so nur f�r einen sehr kurzen moment sichtbar
cls
:: l�scht den bildschirm, erh�ht die �bersichtlichkeit wenn man zu testzwecken echo on l�sst
setlocal
:: setzt die variablen nur lokal f�r dieses skript. so wird die kontamination der variablen anderer skripte durch dieses skript vermieden, au�erdem erleichtert es das testen

set c=1
:: setzt eine variable als z�hler f�r die tags

if not exist .\UE md .\UE
:: erstellt den ordner "UE" sofern er nocht nicht existiert

:: Schleife 1:
for /f %%w in ('dir /b .\*.') do if not %%~nw==UE call :processfolder %%w
:: schleife durch eine liste von verzeichnisnamen (*.), au�er wenn die variable %%w den wert "UE" hat - dieses verzeichnis wird ignoriert
:: die schleife ruft einen neuen prozess auf namens "processfolder" und �bergibt diesem als parameter die variable %%w
:: %%~nw wird anstelle von %w verwendet weil in batch-prozessen variablen, anders als beim direkten aufruf eines befehls aus der kommandozeile, ein zweites % ben�tigen
:: das ~n in %%~nw gibt nur den pfadnamen aus statt der kompletten pfadbezeichnung. m�glicherweise ist dieser schritt �berfl�ssig und man kann %%w verwenden, ich wei� jedoch nicht warum. sp�ter in schleife 3 bei den dateinamen ist dieser schritt auf jeden fall notwendig
goto :eof
:: dieser schritt verhindert, dass nach dem planm��igen durchlaufen des prozesses "processfolder" dieser erneut betreten wird (sogenanntes durchfallen)

:processfolder
:: diese schleife wird f�r jeden g�ltigen ordnernamen aufgerufen
:: in dieser schleife wird der jeweilige ordner bearbeitet - die dateien werden umbenannt, eine liste erstellt (�ber einen weiteren prozess), die umbenannten dateien werden verschoben und der ordner abschlie�end gel�scht. zus�tzlich wird die zahl der bearbeiteten ordner erfasst um tags f�r lernkartens�tze in Anki zu generieren und eine liste bearbeiteter ordner erstellt
if exist .\%~n1\thumb*.png del .\%~n1\thumb*.png
:: l�scht m�glicherweise vorhandene vorschaubilder, welche erstellt wurden falls w�hrend dem exportvorgang aus Impress "Create title page" aktiviert war
set l=0
:: setzt die variable f�r die linienzahl zur�ck auf null. diese wird ben�tigt um den manuellen zeilensprung vor jeder zeile (au�er der ersten) einzuf�gen

:: schleife 2:
for /f %%u in ('dir /b .\%~n1\*.png') do ren .\%~n1\%%~nu.png %~n1%%~nu.png
:: schleife durch eine liste von dateinamen. erfasst werden nur .png-dateien im ordner %~n1 (parameter 1 aus variable %%w aus schleife 1)
:: in der schleife werden die dateinamen durch den vorangestellten ordnernamen erg�nzt
:: der ordnername in variable %%w wurde als parameter an den prozess �bergeben (%%w aus schleife 1 ist hier parameter %1. %~n1 gibt nur den ordnernamen aus, da in %1 der komplette pfad enthalten ist. gleiches gilt f�r %%~nu, welches nur den dateinamen der dateibezeichnung in der variablen %%u ausgibt)

::schleife 3:
for /f %%i in ('dir /b /o:d .\%~n1\*.png') do call :generatelist %1 %%i
:: schleife durch eine liste von dateibezeichnungen. f�r jeden eintrag wird der prozess "generatelist" aufgerufen, an welchen zwei parameter �bergeben werden: der erste parameter %1 der schleife 2 (urspr�nglich die variable %%w, welche die ordnerbezeichnung enth�lt) und die variable %%i, welche die dateibezeichnung enth�lt

if exist .\UE move .\%~n1\*.png .\UE
:: falls der ordner UE existiert werden die in schleife 2 umbenannten dateien aus dem bearbeiteten ordner in diesen verschoben
echo %~n1>> .\"Verarbeitete Verzeichnisse.txt"
:: erweitern einer liste um den namen des verarbeiteten ordners. hier wird echo verwendet damit bei einer weiteren erweiterung in einer neuen zeile begonnen wird.
rd /s /q %~n1
:: entfernen des bearbeiteten ordners. die ben�tigten dateien wurden umbenannt und aus diesem in den ordner UE verschoben
set /a c+=1
:: erh�ht die variable f�r die tags pro bearbeitetem ordner um 1
goto :eof

:generatelist
:: dieser prozess erstellt eine liste f�r den import in Anki. da der befehl 'echo' immer einen zeilensprung nach der zeile anf�gt wird hier hack benutzt um dies zu umgehen. daher mu� der zeilensprung vor allen folgenden eintr�gen jedoch manuell eingef�gt werden.
if %l% neq 0 echo.>> .\%~n1import.txt
:: f�gt einen zeilensprung vor jeder zeile ein, au�er der ersten. der z�hler wird im �bergeordneten prozess auf null zur�ckgesetzt und nach jeder zeile um eins erh�ht (am ende dieses unterprozesses)
:: 'echo.' erzeugt den zeilensprung. >> muss direkt darauffolgen, da sonst nach dem zeilensprung ein leerzeichen mit ausgegeben wird.
if %c% lss 10 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_0%c%>> .\%~n1import.txt
:: benennt die tags sinnvoll mit einer vorgestellten 0 bei einstelliger kapitelnummer
:: %c% lss 10 bedeutet: die bedingung ist erf�llt, wenn die nummer %c% des bearbeiteten ordners kleiner als 10 ist (also 1..9). der z�hler %c% wird im �bergeordneten "ordnerprozess" :processfolder gesetzt
:: 'set /p' ist ein hack, welcher anders als 'echo' eine ausgabe ohne zeilensprung am ende erzeugt. er gibt die angegebene zeile aus und wartet anschlie�end auf eine benutzereingabe (in der gleichen zeile, daher kein LF)
:: < nul �bergibt eine leere eingabe an 'set /p', so dass im endeffekt nur die ausgabezeile ausgegeben wird
:: >> mu� ohne leerzeichen direkt an die ausgabezeile angef�gt werden, da sonst das leerzeichen ebenfalls mit ausgegeben wird
if %c% gtr 9 < nul set /p =^<img^ src^=^"Q%2^"^>;^<img^ src^=^"A%2^"^>;Kapitel_%c%>> .\%~n1import.txt
:: wie eine zeile dar�ber, nur f�r zweistellige ordnerziffern ohne vorangestellte null.
:: %c% gtr 9 bedeutet: die bedingung ist erf�llt, wenn die nummer %c% des bearbeiteten ordners gr��er als 9 ist (also 10...).
set /a l+=1
:: erh�ht den linienz�hler um eins
goto :eof

:eof
endlocal