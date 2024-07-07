@echo off
setlocal enabledelayedexpansion

REM Check if running as administrator
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] You are not local admin, elevate to Local Admin before using this script
    exit /b 1
) else (
    echo [*] You are Local Admin
)

REM Function to create a user and add to Administrators group
:CreateUser
set "username=%~1"
set "description=%~2"
set "password=%~3"

REM Check if user already exists
net user %username% >nul 2>&1
if %errorlevel% neq 0 (
    REM Create user
    net user %username% %password% /add /fullname:"%description%" /passwordchg:no
    net localgroup Administrators %username% /add
    net user %username% /active:yes
    echo [*] User %username% created and added to Administrators group
) else (
    echo [*] User %username% already exists
)
goto :eof

REM Arctic Monkeys group
if /i "%~1"=="Arctic Monkeys" (
    call :CreateUser "Alex Turner" "Lead singer of the Arctic Monkeys" "%~2"
    call :CreateUser "Matt Helders" "Drummer of the Arctic Monkeys" "%~2"
    call :CreateUser "Jamie Cook" "Lead Guitarist of the Arctic Monkeys" "%~2"
    call :CreateUser "Nick O'Malley" "Bass Guitarist of the Arctic Monkeys" "%~2"
) else (
    echo [*] Unknown group specified
)

:end
endlocal
