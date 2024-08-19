@echo off
setlocal enabledelayedexpansion
title DLSS Patcher - www.mbnq.pl
color 0A
cls

call :intro
echo This script will update DLSS and related files in the current directory.
echo Are you sure you want to proceed? (Y/N)
set /p proceed=
if /I not "%proceed%"=="Y" (
    echo Operation cancelled.
    exit /b
)

set "rootDir=%~dp0"
set "latestDir=%rootDir%latest"
set "backupDir=%rootDir%backup"

cls
call :intro

echo Building file list from 'latest' directory...
set "nFiles="
for %%f in ("%latestDir%\*.*") do (
    set "nFiles=!nFiles! %%~nxf"
)
echo File list from 'latest': !nFiles!

echo Checking for existing files in the root directory...
set "eFiles="
set "filesFound=false"
for %%f in (!nFiles!) do (
    if exist "%rootDir%%%f" (
        set "eFiles=!eFiles! %%~nxf"
        set "filesFound=true"
    )
)
echo Existing files in root: !eFiles!

if "!filesFound!"=="false" (
    echo No DLSS and/or related files found in the current directory.
    echo Operation cancelled.
    pause
    endlocal
    exit /b
)

REM Check if the backup directory already contains files
set "backupContainsFiles=false"
for %%f in ("%backupDir%\*") do (
    set "backupContainsFiles=true"
    REM No need to use goto, just set the variable
)

if "!backupContainsFiles!"=="true" (
    echo Backup directory already contains files.
    echo Do you want to continue and overwrite existing backups? (Y/N)
    set /p continueBackup=
    if /I not "%continueBackup%"=="Y" (
        echo Operation cancelled.
        exit /b
    )
)

echo Backing up existing files...
if not exist "%backupDir%" mkdir "%backupDir%"

REM Loop through eFiles to copy to backup
echo Backing up the following files:
for %%f in (!eFiles!) do (
    echo Copying "%%f" to backup directory...
    copy /Y "%rootDir%%%f" "%backupDir%\" >nul
    if errorlevel 1 echo Failed to copy "%%f"
)

echo Creating file list of files to copy from 'latest' directory...
set "cFiles="
for %%f in (!eFiles!) do (
    if exist "%latestDir%\%%f" (
        set "cFiles=!cFiles! %%f"
    )
)
echo Files to copy: !cFiles!

echo Updating files in the current directory...
echo Copying the following files from 'latest' to root directory:
for %%f in (!cFiles!) do (
    echo Copying "%%f" from 'latest' to root directory...
    copy /Y "%latestDir%\%%f" "%rootDir%\" >nul
    if errorlevel 1 echo Failed to copy "%%f"
)

echo Done.
goto end

:intro
    cls
    echo *********************************************************
    echo *                                                       *
    echo *                   DLSS Patcher                        *
    echo *                                                       *
    echo *                                        mbnq.pl 2024   *
    echo *                                                       *
    echo *********************************************************
    echo.
    exit /b

:end
pause
endlocal
