@Echo off
del ..\System\OneButtonDodge.u
del ..\System\OneButtonDodge.ucl
del ..\System\OneButtonDodge.int
copy *.int ..\System\
echo Starting Compile Job...
..\System\UCC make
echo.
pause
