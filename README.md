# Guia para rodar o projeto

# 1. Pré-requisitos

Antes de rodar o projeto, é necessário ter instalado:

* **Flutter SDK**
* **Git**
* **VS Code ou Android Studio** (recomendado)

## Verificando se o Flutter está instalado

No terminal execute:

```bash
flutter --version
```

Para verificar se o ambiente está correto:

```bash
flutter doctor
```

Se aparecer algum erro, siga as instruções mostradas pelo comando.

Documentação oficial:
https://docs.flutter.dev/get-started/install

---

# 2. Clonar o repositório

Clone o projeto usando Git:

```bash
https://github.com/caua-dias/ConectaServ.git
```

Entre na pasta do projeto:

```bash
cd conecta_serv
```

---

# 3. Estrutura do projeto

O projeto está separado em docs, frontend e sketches:

```
conecta_serv/
│
├── docs/        
├── frontend/    
├── sketches/    
```

A aplicação Flutter está localizada dentro da pasta **frontend**.

---

# 4. Executar o frontend (Flutter)

Entre na pasta do frontend:

```bash
cd frontend
```

Baixe as dependências do projeto:

```bash
flutter pub get
```

Execute a aplicação:

```bash
flutter run
```
