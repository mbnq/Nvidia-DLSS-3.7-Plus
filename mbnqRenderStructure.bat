@echo off
echo Starting recursive directory listing...

rem Function to recursively list directories and files
:list_dir
    setlocal
    set "path=%~1"
    
    echo Listing directory: %path%
    
    rem List all directories in the current path
    for /d %%D in ("%path%\*") do (
        echo Directory: %%~nxD
        call :list_dir "%%D"
    )

    rem List all files in the current path
    for %%F in ("%path%\*") do (
        if exist "%%F" (
            echo File: %%~nxF
        )
    )
    endlocal
    goto :eof

rem Main script starts here
echo =========================
call :list_dir "%cd%"
echo =========================
pause
