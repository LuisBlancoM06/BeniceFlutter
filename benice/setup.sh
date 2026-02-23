#!/bin/bash

# =============================================
# BeniceFlutter - Script de Configuración
# =============================================

echo "🚀 Configurando BeniceFlutter..."
echo ""

# 1. Verificar Flutter instalado
echo "📋 Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado. Por favor, instala Flutter SDK primero."
    echo "📖 Guía: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter versión: $(flutter --version | head -1)"
echo ""

# 2. Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get
if [ $? -eq 0 ]; then
    echo "✅ Dependencias instaladas correctamente"
else
    echo "❌ Error instalando dependencias"
    exit 1
fi
echo ""

# 3. Verificar archivo .env
echo "🔧 Verificando configuración..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📝 Creando .env desde .env.example..."
        cp .env.example .env
        echo "⚠️  Por favor, edita .env con tus credenciales reales:"
        echo "   - SUPABASE_URL y SUPABASE_ANON_KEY"
        echo "   - STRIPE_PUBLISHABLE_KEY"
        echo "   - RESEND_API_KEY"
        echo "   - CLOUDINARY_CLOUD_NAME"
        echo ""
    else
        echo "❌ No se encontró .env.example"
        exit 1
    fi
else
    echo "✅ Archivo .env encontrado"
fi
echo ""

# 4. Verificar variables de entorno críticas
echo "🔍 Verificando variables de entorno críticas..."
source .env

REQUIRED_VARS=("SUPABASE_URL" "SUPABASE_ANON_KEY" "STRIPE_PUBLISHABLE_KEY")
ALL_GOOD=true

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" = "xxxx" ] || [ "${!var}" = "placeholder" ]; then
        echo "⚠️  $var no configurado correctamente"
        ALL_GOOD=false
    else
        echo "✅ $var configurado"
    fi
done

if [ "$ALL_GOOD" = false ]; then
    echo ""
    echo "❌ Algunas variables críticas no están configuradas"
    echo "📝 Por favor, edita .env y configura las variables requeridas"
    echo ""
    echo "📖 Revisa README_STOCK.md para más información"
    exit 1
fi
echo ""

# 5. Ejecutar tests (opcional)
echo "🧪 Ejecutando tests de validación de stock..."
flutter test test/stock_validation_test.dart
if [ $? -eq 0 ]; then
    echo "✅ Tests pasados correctamente"
else
    echo "⚠️  Algunos tests fallaron (puede ser normal si no hay conexión a BD)"
fi
echo ""

# 6. Verificar funciones SQL (recordatorio)
echo "🗄️  Configuración de Base de Datos:"
echo "⚠️  No olvides ejecutar las funciones SQL en Supabase:"
echo "   📁 database/stock_functions.sql"
echo ""

# 7. Opciones de ejecución
echo "🎯 BeniceFlutter está listo para ejecutar:"
echo ""
echo "📱 Desarrollo:"
echo "   flutter run"
echo ""
echo "🌐 Web:"
echo "   flutter run -d chrome"
echo ""
echo "🏗️  Build:"
echo "   flutter build apk    # Android"
echo "   flutter build ios    # iOS"
echo "   flutter build web    # Web"
echo ""

echo "🎉 ¡Configuración completada!"
echo "📖 Revisa README_STOCK.md para más detalles"
echo ""

# 8. Verificar conexión a Supabase (opcional)
echo "🔍 Verificando conexión a Supabase..."
if [ ! -z "$SUPABASE_URL" ] && [ ! -z "$SUPABASE_ANON_KEY" ]; then
    echo "✅ Variables de Supabase configuradas"
    echo "💡 La conexión se verificará al ejecutar la app"
else
    echo "❌ Variables de Supabase no configuradas"
fi

echo ""
echo "🚀 ¡BeniceFlutter listo para usar! 🐾"
