@Echo off
del ..\System\OneButtonDodge.*
copy *.int ..\System\
echo Starting Compile Job...
..\System\UCC make
echo.
pause
