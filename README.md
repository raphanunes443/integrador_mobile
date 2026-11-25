# Projeto Flutter / Dart para Linux (VS Code)

## Pré-requisitos no Linux (Ubuntu/Debian)
Para compilar apps desktop nativos no Linux, o Flutter exige as dependências de build GTK/Clang. Caso ainda não tenha instalado:
```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

## Como preparar e executar no VS Code:
1. Extraia o `.zip` e abra o terminal na pasta extraída.
2. Dê permissão e rode o script de preparação:
   ```bash
   chmod +x setup_linux.sh
   ./setup_linux.sh
   ```
   *(Ou rode manualmente: `flutter config --enable-linux-desktop && flutter create --platforms=linux,web,android . && flutter pub get`)*
3. Abra o projeto no VS Code:
   ```bash
   code .
   ```
4. Pressione **F5** (a configuração padrão já aponta para `"deviceId": "linux"`) ou execute `flutter run -d linux` no terminal.
