@Echo off
del ..\System\SMHitMarkers.*
echo Starting Compile Job...
..\System\UCC make
echo.
pause
