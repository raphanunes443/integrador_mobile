#!/usr/bin/env bash
set -e

echo "1. Habilitando suporte desktop Linux no Flutter..."
flutter config --enable-linux-desktop

echo "2. Gerando arquivos nativos para Linux..."
flutter create --platforms=linux,web,android .

echo "3. Baixando dependências (flutter pub get)..."
flutter pub get

echo "4. Verificando ambiente (flutter doctor)..."
flutter doctor

echo "Tudo pronto! Abra a pasta no VS Code ('code .') e pressione F5."
