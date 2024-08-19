@echo off
setlocal enabledelayedexpansion

REM Set the color scheme: black background and green text
color 0A

REM Ask the user if they want to proceed
echo Are you sure you want to proceed with the operations? (Y/N)
set /p proceed=
if /I not "%proceed%"=="Y" (
    echo Operation cancelled.
    exit /b
)

REM Step 0: Set the root folder (current location)
set "rootDir=%~dp0"
set "latestDir=%rootDir%latest"
set "backupDir=%rootDir%backup"

echo Root directory set to: %rootDir%
echo Latest directory set to: %latestDir%
echo Backup directory set to: %backupDir%
echo.

REM Step 1: Make an array of all files in the 'latest' dir (nFiles)
echo Gathering list of files in the 'latest' directory...
set "nFiles="
for %%f in ("%latestDir%\*.*") do (
    set "nFiles=!nFiles! %%~nxf"
    echo Found file: %%~nxf
)
echo.

REM Step 2: Check for files from nFiles if already exist in root and make array of them (eFiles)
echo Checking for existing files in the root directory...
set "eFiles="
for %%f in (%nFiles%) do (
    if exist "%rootDir%%%f" (
        set "eFiles=!eFiles! %%f"
        echo File exists in root: %%f
    )
)

REM Check if eFiles is empty
if not defined eFiles (
    echo No DLSS files found in the root directory.
    echo Operation completed.
    pause >nul
    endlocal
    exit /b
)
echo.

REM Step 3: Check if there are files in the 'backup' directory and ask if the user wants to overwrite
set "backupFiles="
for %%f in (%eFiles%) do (
    if exist "%backupDir%\%%f" (
        set "backupFiles=!backupFiles! %%f"
    )
)

if defined backupFiles (
    echo The following files already exist in the 'backup' directory:
    for %%f in (%backupFiles%) do (
        echo %%f
    )
    echo.
    echo Do you want to overwrite these files? (Y/N)
    set /p overwrite=
    if /I not "%overwrite%"=="Y" (
        echo Operation cancelled.
        exit /b
    )
)

REM Step 4: Make a copy of eFiles to folder 'backup', force overwrite
echo Copying existing files to the 'backup' directory...
for %%f in (%eFiles%) do (
    echo Copying %%f to backup directory...
    copy /Y "%rootDir%%%f" "%backupDir%\" >nul
)
echo.

REM Step 5: Copy files from 'latest' to root if they exist in eFiles
echo Updating files in the root directory...
for %%f in (%eFiles%) do (
    echo Copying %%f from 'latest' to root directory...
    copy /Y "%latestDir%\%%f" "%rootDir%\" >nul
)
echo.

echo Operation completed.
pause >nul
endlocal
