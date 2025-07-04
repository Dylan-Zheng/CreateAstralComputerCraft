@echo off
REM Batch script to run bundler.lua with workspace set to current directory

REM Set current directory as workspace
cd /d "%~dp0"

REM Check if lua.exe exists in PATH
where lua.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: lua.exe not found in PATH. Please install Lua and add it to your environment variables.
    echo.
    echo You can install Lua from: https://www.lua.org/download.html
    echo Or use a package manager like Chocolatey: choco install lua
    pause
    exit /b 1
)

REM Display current directory and Lua version
echo Current directory: %CD%
lua.exe -v 2>nul
echo.

REM Run the Lua script
echo Running bundler.lua...
lua.exe tools/bundler.lua

REM Pause to see results
if %errorlevel% neq 0 (
    echo.
    echo =====================================
    echo Build failed with error code %errorlevel%
    echo =====================================
    pause
    exit /b %errorlevel%
) else (
    echo.
    echo =====================================
    echo Build completed successfully!
    echo =====================================
    pause
)
