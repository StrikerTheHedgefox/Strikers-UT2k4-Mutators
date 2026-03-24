@Echo off
del ..\System\cDOM2.u
del ..\System\cDOM2.ucl
echo Starting Compile Job...
..\System\UCC make
echo.
pause
