@echo off
REM =============================================
REM BeniceFlutter - Script de Configuración (Windows)
REM =============================================

echo 🚀 Configurando BeniceFlutter...
echo.

REM 1. Verificar Flutter instalado
echo 📋 Verificando Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado. Por favor, instala Flutter SDK primero.
    echo 📖 Guía: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version ^| findstr "Flutter"') do set FLUTTER_VERSION=%%i
echo ✅ %FLUTTER_VERSION%
echo.

REM 2. Instalar dependencias
echo 📦 Instalando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error instalando dependencias
    pause
    exit /b 1
)
echo ✅ Dependencias instaladas correctamente
echo.

REM 3. Verificar archivo .env
echo 🔧 Verificando configuración...
if not exist ".env" (
    if exist ".env.example" (
        echo 📝 Creando .env desde .env.example...
        copy ".env.example" ".env" >nul
        echo ⚠️  Por favor, edita .env con tus credenciales reales:
        echo    - SUPABASE_URL y SUPABASE_ANON_KEY
        echo    - STRIPE_PUBLISHABLE_KEY
        echo    - RESEND_API_KEY
        echo    - CLOUDINARY_CLOUD_NAME
        echo.
    ) else (
        echo ❌ No se encontró .env.example
        pause
        exit /b 1
    )
) else (
    echo ✅ Archivo .env encontrado
)
echo.

REM 4. Verificar variables de entorno críticas
echo 🔍 Verificando variables de entorno críticas...
REM Leer variables del .env (simplificado)
set SUPABASE_URL=
set SUPABASE_ANON_KEY=
set STRIPE_PUBLISHABLE_KEY=

for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="SUPABASE_URL" set SUPABASE_URL=%%b
    if "%%a"=="SUPABASE_ANON_KEY" set SUPABASE_ANON_KEY=%%b
    if "%%a"=="STRIPE_PUBLISHABLE_KEY" set STRIPE_PUBLISHABLE_KEY=%%b
)

set ALL_GOOD=true

if "%SUPABASE_URL%"=="" set ALL_GOOD=false
if "%SUPABASE_URL%"=="https://xxxx.supabase.co" set ALL_GOOD=false
if "%SUPABASE_ANON_KEY%"=="" set ALL_GOOD=false
if "%SUPABASE_ANON_KEY%"=="eyJhbGciOi..." set ALL_GOOD=false
if "%STRIPE_PUBLISHABLE_KEY%"=="" set ALL_GOOD=false
if "%STRIPE_PUBLISHABLE_KEY%"=="pk_test_xxx" set ALL_GOOD=false

if "%SUPABASE_URL%"=="" (
    echo ⚠️  SUPABASE_URL no configurado correctamente
) else (
    echo ✅ SUPABASE_URL configurado
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo ⚠️  SUPABASE_ANON_KEY no configurado correctamente
) else (
    echo ✅ SUPABASE_ANON_KEY configurado
)

if "%STRIPE_PUBLISHABLE_KEY%"=="" (
    echo ⚠️  STRIPE_PUBLISHABLE_KEY no configurado correctamente
) else (
    echo ✅ STRIPE_PUBLISHABLE_KEY configurado
)

if "%ALL_GOOD%"=="false" (
    echo.
    echo ❌ Algunas variables críticas no están configuradas
    echo 📝 Por favor, edita .env y configura las variables requeridas
    echo.
    echo 📖 Revisa README_STOCK.md para más información
    pause
    exit /b 1
)
echo.

REM 5. Ejecutar tests (opcional)
echo 🧪 Ejecutando tests de validación de stock...
flutter test test\stock_validation_test.dart
if %errorlevel% neq 0 (
    echo ⚠️  Algunos tests fallaron (puede ser normal si no hay conexión a BD)
) else (
    echo ✅ Tests pasados correctamente
)
echo.

REM 6. Verificar funciones SQL (recordatorio)
echo 🗄️  Configuración de Base de Datos:
echo ⚠️  No olvides ejecutar las funciones SQL en Supabase:
echo    📁 database\stock_functions.sql
echo.

REM 7. Opciones de ejecución
echo 🎯 BeniceFlutter está listo para ejecutar:
echo.
echo 📱 Desarrollo:
echo    flutter run
echo.
echo 🌐 Web:
echo    flutter run -d chrome
echo.
echo 🏗️  Build:
echo    flutter build apk    # Android
echo    flutter build ios    # iOS
echo    flutter build web    # Web
echo.

echo 🎉 ¡Configuración completada!
echo 📖 Revisa README_STOCK.md para más detalles
echo.

REM 8. Verificación final
if "%ALL_GOOD%"=="true" (
    echo ✅ Variables de Supabase configuradas
    echo 💡 La conexión se verificará al ejecutar la app
) else (
    echo ❌ Variables de Supabase no configuradas
)

echo.
echo 🚀 ¡BeniceFlutter listo para usar! 🐾
pause
