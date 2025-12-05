@echo off
title Colorboxd Local Server Setup

echo ===================================
echo    COLORBOXD LOCAL SETUP
echo ===================================
echo.

echo [1/6] Configurando Go...
set GOROOT=C:\Users\artes4\Documents\go
set GOPATH=C:\Users\artes4\Documents\go-workspace
set GOCACHE=C:\Users\artes4\Documents\go-cache
set GOTMPDIR=C:\Users\artes4\Documents\go-temp
set PATH=%GOROOT%\bin;%PATH%

echo Criando diretórios necessários...
if not exist "%GOCACHE%" mkdir "%GOCACHE%"
if not exist "%GOTMPDIR%" mkdir "%GOTMPDIR%"
if not exist "%GOPATH%" mkdir "%GOPATH%"

echo [2/6] Verificando instalação do Go...
go version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Go não encontrado em %GOROOT%\bin
    echo Certifique-se de ter extraído o Go para C:\Users\artes4\Documents\go
    pause
    exit /b 1
)
echo Go encontrado!

echo [3/6] Preparando backend...
cd /d %~dp0backend
echo Limpando cache do Go...
go clean -cache -modcache
echo Baixando dependências...
go mod tidy
go mod download

echo [4/6] Iniciando backend (SortList - porta 8080)...
start "Backend SortList" cmd /k "title Backend SortList (8080) && cd /d %~dp0backend && set GOROOT=%GOROOT% && set GOPATH=%GOPATH% && set GOCACHE=%GOCACHE% && set GOTMPDIR=%GOTMPDIR% && set PATH=%GOROOT%\bin;%%PATH%% && go run cmd\main.go"

echo [5/6] Aguardando e iniciando WriteList (porta 8090)...
timeout /t 5 /nobreak >nul
start "Backend WriteList" cmd /k "title Backend WriteList (8090) && cd /d %~dp0backend && set GOROOT=%GOROOT% && set GOPATH=%GOPATH% && set GOCACHE=%GOCACHE% && set GOTMPDIR=%GOTMPDIR% && set PATH=%GOROOT%\bin;%%PATH%% && go run cmd2\main.go"

echo [6/6] Iniciando frontend...
timeout /t 3 /nobreak >nul
if exist "%~dp0frontend\build" (
    echo Servindo frontend buildado...
    start "Frontend" cmd /k "title Frontend (3000) && cd /d %~dp0frontend\build && python -m http.server 3000"
) else (
    echo Frontend build não encontrado. Servindo arquivos estáticos do public...
    if exist "%~dp0frontend\public" (
        start "Frontend" cmd /k "title Frontend (3000) && cd /d %~dp0frontend\public && python -m http.server 3000"
    ) else (
        echo Nenhum frontend encontrado, continuando apenas com backend...
        echo Você pode testar as APIs diretamente:
        echo - SortList: http://localhost:8080
        echo - WriteList: http://localhost:8090
    )
)

echo.
echo ===================================
echo    SERVIÇOS INICIADOS!
echo ===================================
echo - SortList:  http://localhost:8080
echo - WriteList: http://localhost:8090
if exist "%~dp0frontend\build" (
    echo - Frontend:  http://localhost:3000
) else if exist "%~dp0frontend\public" (
    echo - Frontend:  http://localhost:3000 (modo básico)
)
echo.
echo Para parar os serviços, feche as janelas abertas.
echo.
echo Aguarde alguns segundos para todos os serviços subirem...
timeout /t 5 /nobreak >nul

if exist "%~dp0frontend\build" (
    echo Abrindo frontend no navegador...
    start http://localhost:3000
) else if exist "%~dp0frontend\public" (
    echo Abrindo frontend básico no navegador...
    start http://localhost:3000
)

echo.
echo Pressione qualquer tecla para fechar este terminal...
pause >nul