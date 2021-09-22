java -jar KickAss.jar test.asm
if %errorlevel% neq 0 (
    pause
 ) else (
    "C:\Users\geon\Downloads\gtk3vice-3.5-win64 (1)\GTK3VICE-3.5-win64\bin\x64sc.exe" test.prg
)
