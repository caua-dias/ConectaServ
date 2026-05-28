# Mapeamento de Endpoints - ConectaServ

| Funcionalidade | Arquivo(s) Origem | Método HTTP | Rota | Códigos de Resposta Esperados |
| :--- | :--- | :--- | :--- | :--- |
| **Autenticação (Login)** | `login_page.dart` | `POST` | `/api/auth/login` | `200` (OK)<br>`400` (Bad Request)<br>`401` (Unauthorized)<br>`500` (Internal Error) |
| **Cadastro de Cliente** | `register_client_screen.dart` | `POST` | `/api/clients` | `201` (Created)<br>`400` (Bad Request)<br>`409` (Conflict) |
| **Cadastro de Empresa** | `register_company_screen.dart` | `POST` | `/api/companies` | `201` (Created)<br>`400` (Bad Request)<br>`409` (Conflict) |
| **Recuperação de Senha** | `recover_password_page.dart` | `POST` | `/api/auth/recover-password` | `200` (OK)<br>`400` (Bad Request)<br>`404` (Not Found) |
| **Listagem de Serviços** | `home_page.dart`<br>`service_screen.dart` | `GET` | `/api/services` | `200` (OK)<br>`500` (Internal Error) |
| **Envio de Avaliação** | `raiting_screen.dart` | `POST` | `/api/raiting` | `201` (Created)<br>`400` (Bad Request)<br>`404` (Not Found) |
