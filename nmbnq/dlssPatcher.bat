@echo off
setlocal enabledelayedexpansion
title DLSS Patcher - www.mbnq.pl
color 0A
call :intro

echo This script will update DLSS and related files in the current directory.
echo Are you sure you want to proceed? ^(Y/N^)
set /p proceed=
if /I not "%proceed%"=="Y" (
    goto fail
)

set "rootDir=%~dp0"
set "latestDir=%rootDir%latest"
set "backupDir=%rootDir%backup"
set /a mErrorCode=0

call :intro

echo Building file list from 'latest' directory...
set "nFiles="
for %%f in ("%latestDir%\*.*") do (
    set "nFiles=!nFiles! %%~nxf"
)

echo Checking for existing files in the root directory...
set "eFiles="
set "filesFound=false"
for %%f in (!nFiles!) do (
    if exist "%rootDir%%%f" (
        set "eFiles=!eFiles! %%~nxf"
        set "filesFound=true"
    )
)

if "!filesFound!"=="false" (
	echo.
    echo No DLSS and/or related files found in the current directory.
	goto fail
)

set "backupContainsFiles=false"
for %%f in ("%backupDir%\*") do (
    set "backupContainsFiles=true"
)

if "!backupContainsFiles!"=="true" (
	echo.
    echo Backup directory already contains files.
    echo Do you want to continue and overwrite existing backups? ^(Y/N^)
    set /p continueBackup=
    if /I not "!continueBackup!"=="Y" (
		goto fail
    )
)

echo Backing up existing files...
if not exist "%backupDir%" mkdir "%backupDir%"

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

echo Updating files in the current directory...
for %%f in (!cFiles!) do (
    echo Copying "%%f" from 'latest' to root directory...
    copy /Y "%latestDir%\%%f" "%rootDir%\" >nul
    if errorlevel 1 echo Failed to copy "%%f"
)

:success
echo.
echo Done.
goto end

:fail
set /a mErrorCode=1
echo.
echo Aborted.
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
echo Press any key to exit...
pause > nul
exit /b %mErrorCode% && endlocal
