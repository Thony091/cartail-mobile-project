#!/bin/bash

# Script para verificar que la implementación de Better Auth esté completa
# Uso: bash verify_better_auth.sh

echo "🔍 Verificando implementación de Better Auth..."
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de archivos
total=0
found=0
missing=0

# Función para verificar archivo
check_file() {
    local file=$1
    local description=$2
    total=$((total + 1))

    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $description"
        found=$((found + 1))
    else
        echo -e "${RED}❌${NC} $description - FALTA: $file"
        missing=$((missing + 1))
    fi
}

echo "📁 Verificando estructura de Domain Layer..."
check_file "lib/features/auth/domain/entities/auth_user.dart" "AuthUser entity"
check_file "lib/features/auth/domain/entities/auth_session.dart" "AuthSession entity"
check_file "lib/features/auth/domain/repositories/auth_repository.dart" "AuthRepository interface"
check_file "lib/features/auth/domain/errors/auth_exceptions.dart" "Auth exceptions"
check_file "lib/features/auth/domain/domain.dart" "Domain barrel file"
echo ""

echo "📁 Verificando estructura de Data Layer..."
check_file "lib/features/auth/data/models/better_auth_user_model.dart" "BetterAuthUserModel"
check_file "lib/features/auth/data/models/better_auth_session_model.dart" "BetterAuthSessionModel"
check_file "lib/features/auth/data/datasources/better_auth_datasource.dart" "BetterAuthDatasource interface"
check_file "lib/features/auth/data/datasources/better_auth_datasource_impl.dart" "BetterAuthDatasource implementation"
check_file "lib/features/auth/data/repositories/better_auth_repository_impl.dart" "BetterAuthRepository implementation"
check_file "lib/features/auth/data/services/better_auth_config.dart" "BetterAuth config"
check_file "lib/features/auth/data/services/token_storage_service.dart" "Token storage service"
check_file "lib/features/auth/data/data.dart" "Data barrel file"
echo ""

echo "📁 Verificando estructura de Presentation Layer..."
check_file "lib/features/auth/presentation/providers/better_auth_provider.dart" "BetterAuth providers"
echo ""

echo "📁 Verificando barrel files..."
check_file "lib/features/auth/auth.dart" "Main barrel file"
echo ""

echo "📚 Verificando documentación..."
check_file "BETTER_AUTH_INDEX.md" "Índice de documentación"
check_file "SUMMARY_BETTER_AUTH.md" "Resumen ejecutivo"
check_file "BETTER_AUTH_README.md" "README principal"
check_file "BETTER_AUTH_IMPLEMENTATION.md" "Guía de implementación"
check_file "BETTER_AUTH_INTEGRATION_STEPS.md" "Pasos de integración"
check_file ".env.better-auth.example" "Ejemplo de .env"
echo ""

# Resumen
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 RESUMEN DE VERIFICACIÓN"
echo ""
echo "Total de archivos esperados: $total"
echo -e "${GREEN}Archivos encontrados: $found${NC}"
if [ $missing -gt 0 ]; then
    echo -e "${RED}Archivos faltantes: $missing${NC}"
else
    echo -e "${GREEN}Archivos faltantes: 0${NC}"
fi
echo ""

# Verificar dependencias en pubspec.yaml
echo "🔍 Verificando dependencias en pubspec.yaml..."
echo ""

check_dependency() {
    local dep=$1
    if grep -q "^  $dep:" pubspec.yaml; then
        echo -e "${GREEN}✅${NC} $dep está en pubspec.yaml"
    else
        echo -e "${YELLOW}⚠️${NC}  $dep NO está en pubspec.yaml (puede que necesites agregarlo)"
    fi
}

check_dependency "dio"
check_dependency "flutter_riverpod"
check_dependency "shared_preferences"
echo ""

# Verificar si .env existe
echo "🔍 Verificando configuración..."
echo ""
if [ -f ".env" ]; then
    echo -e "${GREEN}✅${NC} Archivo .env encontrado"

    if grep -q "BETTER_AUTH_BASE_URL" .env; then
        echo -e "${GREEN}✅${NC} Variable BETTER_AUTH_BASE_URL configurada en .env"
    else
        echo -e "${YELLOW}⚠️${NC}  Variable BETTER_AUTH_BASE_URL NO encontrada en .env"
        echo "   Agrega: BETTER_AUTH_BASE_URL=http://localhost:3000"
    fi
else
    echo -e "${YELLOW}⚠️${NC}  Archivo .env no encontrado"
    echo "   Copia .env.better-auth.example a .env y configura las variables"
fi
echo ""

# Resultado final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ $missing -eq 0 ]; then
    echo -e "${GREEN}✨ ¡TODO ESTÁ LISTO!${NC}"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Lee BETTER_AUTH_INDEX.md para navegar la documentación"
    echo "   2. Sigue BETTER_AUTH_INTEGRATION_STEPS.md para integrar"
    echo "   3. Configura tu backend de Better Auth"
    echo "   4. ¡Disfruta de tu sistema de autenticación personalizado!"
else
    echo -e "${RED}❌ Faltan algunos archivos${NC}"
    echo ""
    echo "Por favor verifica los archivos marcados como faltantes arriba."
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
