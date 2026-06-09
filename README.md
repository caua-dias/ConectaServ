# ConectaServ

> Plataforma mobile que conecta consumidores a prestadores de serviços locais — um "shopping de empresas" centralizado, com catálogo, avaliações e acesso offline.

---

## Sobre o Projeto

O **ConectaServ** resolve a fragmentação na busca por prestadores de serviços. Em vez de navegar por diversas plataformas ou depender de indicações boca a boca, o usuário encontra num só lugar empresas de marketing, contabilidade, jardinagem, manutenção e muito mais — com informações padronizadas, avaliações confiáveis e contato direto.

**Dois tipos de usuário:**
- **Consumidores (CPF/CNPJ):** buscam e contratam serviços com avaliações transparentes.
- **Prestadores (CNPJ):** exibem sua vitrine digital com serviços, portfólio, endereço e horários.

---

## Funcionalidades

- **Catálogo e Busca** — pesquisa por categoria, nome ou tipo de serviço
- **Perfil Detalhado da Empresa** — serviços, endereço, site, telefone e horário de funcionamento
- **Sistema de Avaliações** — notas e comentários sobre serviços contratados
- **Favoritos Offline** — empresas salvas localmente via SQLite para consulta sem internet
- **Cadastro de Serviços** — empresas podem cadastrar e gerenciar seus serviços
- **Autenticação** — login com controle de acesso diferenciado (cliente × empresa)
- **Recuperação de Senha** — fluxo completo via e-mail

---

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter (Dart) `>=3.0.0` |
| Gerenciamento de estado | Provider + GetIt |
| Navegação | go_router |
| Persistência local | SQLite (sqflite) |
| Preferências | shared_preferences |
| HTTP | http |
| Arquitetura | Hexagonal (Domain / Data / Infrastructure) |
| Testes | flutter_test, mockito, integration_test |

---

## Estrutura do Projeto

```
ConectaServ/
├── docs/
│   ├── proposital.md          # Descrição e requisitos do projeto
│   ├── api-contract.md        # Contrato de endpoints da API
│   └── Diagrama ER.png        # Diagrama entidade-relacionamento
├── frontend/                  # Aplicação Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── di/            # Injeção de dependências (GetIt)
│   │   │   ├── database/      # Configuração do SQLite
│   │   │   ├── cache_service.dart
│   │   │   └── http_client.dart
│   │   ├── models/            # Entidades do domínio
│   │   │   ├── avaliacao.dart
│   │   │   ├── cliente.dart
│   │   │   ├── contratacao.dart
│   │   │   ├── empresa_prestadora.dart
│   │   │   ├── servico.dart
│   │   │   └── projeto_portfolio.dart
│   │   ├── domain/
│   │   │   └── repositories/  # Interfaces (contratos)
│   │   ├── data/
│   │   │   ├── models/        # DTOs / modelos de resposta da API
│   │   │   ├── repositories/  # Implementações de repositório HTTP
│   │   │   └── services/      # Serviços de acesso à API
│   │   ├── infrastructure/
│   │   │   └── repositories/  # Implementações SQLite (sqflite)
│   │   ├── features/
│   │   │   ├── auth/presentation/pages/   # Telas da aplicação
│   │   │   └── models/presentation/notifiers/  # Notifiers (Provider)
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── main.dart
│   ├── test/
│   │   └── models/            # Testes unitários das entidades
│   └── pubspec.yaml
└── sketches/                  # Esboços e wireframes
```

---

## Rotas da Aplicação

| Rota | Tela |
|---|---|
| `/` | Home (catálogo) |
| `/busca?q=&categoria=` | Resultados de busca |
| `/empresa/:id` | Perfil da empresa |
| `/avaliacoes` | Avaliações |
| `/configuracoes` | Configurações |
| `/login` | Login |
| `/register` | Seleção de tipo de cadastro |
| `/register_client` | Cadastro de cliente |
| `/register_company` | Cadastro de empresa |
| `/service/:id` | Detalhe do serviço |
| `/novo_servico` | Cadastrar novo serviço |
| `/raiting` | Enviar avaliação |
| `/recover_password` | Recuperar senha |

> Rotas protegidas redirecionam para `/login` quando o usuário não está autenticado.

---

## API — Endpoints

| Funcionalidade | Método | Rota | Respostas |
|---|---|---|---|
| Login | `POST` | `/api/auth/login` | 200, 400, 401, 500 |
| Recuperar senha | `POST` | `/api/auth/recover-password` | 200, 400, 404 |
| Cadastro de cliente | `POST` | `/api/clients` | 201, 400, 409 |
| Cadastro de empresa | `POST` | `/api/companies` | 201, 400, 409 |
| Listagem de serviços | `GET` | `/api/services` | 200, 500 |
| Enviar avaliação | `POST` | `/api/raiting` | 201, 400, 404 |

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.0.0 <4.0.0`)
- Git
- Editor: VS Code ou Android Studio (recomendado)
- Para Android: Android SDK / emulador configurado
- Para iOS: Xcode (apenas macOS)

Verifique o ambiente:

```bash
flutter --version
flutter doctor
```

---

## Como Rodar

**1. Clone o repositório**

```bash
git clone https://github.com/caua-dias/ConectaServ.git
cd ConectaServ
```

**2. Entre na pasta do frontend**

```bash
cd frontend
```

**3. Instale as dependências**

```bash
flutter pub get
```

**4. Execute a aplicação**

```bash
flutter run
```

Para escolher um dispositivo específico:

```bash
flutter devices          # lista dispositivos disponíveis
flutter run -d <device>  # ex: flutter run -d chrome
```

---

## Testes

Execute os testes unitários:

```bash
cd frontend
flutter test
```

Os testes cobrem as entidades principais: `Avaliacao`, `Cliente`, `Contratacao`, `EmpresaPrestadora`, `ProjetoPortfolio` e `Servico`.

---

## Dependências Principais

```yaml
provider: ^6.1.5+1        # Gerenciamento de estado
get_it: ^9.2.1             # Injeção de dependências
go_router: ^14.0.0         # Navegação declarativa
sqflite: ^2.4.2+1          # Persistência local SQLite
http: ^1.6.0               # Requisições HTTP
shared_preferences: ^2.3.2 # Preferências do usuário
```
