@Echo off
del ..\System\SMPackageManager.u
del ..\System\SMPackageManager.ucl
echo Starting Compile Job...
..\System\UCC make
echo.
pause
