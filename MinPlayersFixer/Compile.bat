@Echo off
del ..\System\MinPlayersFixer.*
echo Starting Compile Job...
..\System\UCC make
echo.
pause
