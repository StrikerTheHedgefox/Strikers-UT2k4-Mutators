@Echo off
del ..\System\ClassicDom.u
del ..\System\ClassicDom.ucl
echo Starting Compile Job...
..\System\UCC make
echo.
pause
