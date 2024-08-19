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
    echo Aborted!
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

echo Checking for existing files in the root directory...
set "eFiles="
for %%f in (%nFiles%) do (
    if exist "%rootDir%%%f" (
        set "eFiles=!eFiles! %%f"
    )
)

if not defined eFiles (
    echo No DLSS and/or related files found in the current directory.
    goto :fail
)

REM Check if the backup directory already contains files
if exist "%backupDir%\*" (
	echo.
    echo Backup directory already contains files.
    echo Type 1 then ENTER if you want to overwrite existing backups.
    set /p continueBackup=
    if /I not "%continueBackup%"=="1" (
        goto :fail
    )
)
echo.

echo Backing up existing files...
if not exist "%backupDir%" mkdir "%backupDir%"
for %%f in (%eFiles%) do (
    echo Copying %%f to backup directory...
    copy /Y "%rootDir%%%f" "%backupDir%\" >nul
)

echo Creating file list of files to copy from 'latest' directory...
set "cFiles="
for %%f in (%eFiles%) do (
    if exist "%latestDir%\%%f" (
        set "cFiles=!cFiles! %%f"
    )
)

echo Updating files in the current directory...
for %%f in (%cFiles%) do (
    echo Copying %%f from 'latest' to root directory...
    copy /Y "%latestDir%\%%f" "%rootDir%\" >nul
)

:success
echo Done.
goto end

:fail
echo Aborted^^!
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
