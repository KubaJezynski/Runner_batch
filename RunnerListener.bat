@ECHO OFF
SETLOCAL EnableDelayedExpansion
ECHO nacisnij J by skoczyc

:start_app
>keystroke.txt replace ? . /u /w
FOR /F delims^=^ eol^= %%K in (
'2^>nul findstr /R "^" "keystroke.txt"'
) do set "key=%%K"

IF NOT !key! == j GOTO :start_app
break>"keystroke.txt"
>"keystroke.txt" echo !key!
EXIT

