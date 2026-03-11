**1. Descrição do Aplicativo**

O **ConectaServ** é uma plataforma unificada que atua como um "shopping de empresas", centralizando a oferta de serviços dos mais variados nichos (marketing, contabilidade, jardinagem, manutenção, etc.) em um único lugar. A aplicação conecta quem precisa de um serviço (Pessoa Física ou Jurídica) a prestadores qualificados, oferecendo informações centralizadas, avaliações, horários de atendimento e canais diretos de contato.

**2. O Problema que Resolve**

Atualmente, buscar por prestadores de serviços locais exige navegar por diversas plataformas fragmentadas, redes sociais ou depender de indicações boca a boca. Muitas vezes, as informações estão desatualizadas, não há avaliações confiáveis ou faltam dados essenciais como endereço, site e horário de funcionamento. O ConectaServ resolve isso centralizando o catálogo de serviços em uma interface padronizada, confiável e de fácil acesso.

**3. Público-Alvo**

- **Consumidores (CPF e CNPJ):** Pessoas e empresas que buscam contratar serviços confiáveis, precisando de informações rápidas, avaliações transparentes e contato direto com o prestador.
- **Prestadores de Serviços/Empresas (CNPJ):** Negócios locais que desejam uma vitrine digital para exibir seus serviços, portfólio, endereço e horários de atendimento, aumentando sua captação de clientes.

**4. Funcionalidades Principais Iniciais**

- **Catálogo e Busca:** Pesquisa de empresas por categorias, nome ou tipo de serviço.
- **Perfil Detalhado da Empresa:** Tela contendo os serviços oferecidos, endereço, site, telefone e horário de funcionamento.
- **Sistema de Avaliações:** Usuários podem dar notas e escrever comentários sobre os serviços contratados.
- **Favoritos (Modo Offline):** O usuário pode salvar o perfil de empresas para consultar seus contatos rapidamente mesmo quando estiver sem internet.
- **Mapa de Serviços:** Visualização das empresas que estão geograficamente mais próximas ao usuário.

**5. Recursos Técnicos Utilizados (Cobertura dos 15 Módulos)**

Para garantir a aplicação completa dos conceitos da disciplina, o ConectaServ utilizará:

- **Gerenciamento de Estado e Arquitetura (Módulos 04 a 07):** Uso do `Provider` e `GetIt` separados em camadas seguindo a Arquitetura Hexagonal.
- **Persistência Local (Módulo 08):** Uso do `SQLite` para armazenar o histórico de buscas e as empresas "Favoritas" do usuário, garantindo consulta offline.
- **Backend Serverless na AWS (Módulos 09 e 10):** Criação de APIs com AWS API Gateway, funções Lambda e banco de dados RDS PostgreSQL para cadastrar e listar as empresas e avaliações.
- **Autenticação (Módulo 11):** Login via OAuth 2.0 garantindo diferentes níveis de acesso (usuário comum x dono de empresa).
- **Notificações Push (Módulo 12):** Alertas via Firebase (FCM) para avisar o usuário quando uma empresa responder à sua avaliação ou tiver promoções de serviços favoritados.
- **Recursos Nativos (Módulo 13):**
    - **GPS (Localização):** Para sugerir e calcular a distância das empresas no catálogo ao redor do usuário.
    - **Câmera:** Para permitir que os usuários tirem e anexem fotos do serviço concluído junto à sua avaliação.
- **Internacionalização (Módulo 14):** Suporte nativo para os idiomas Português e Inglês, usando a biblioteca `i18n_extension`.
- **Testes (Módulo 15):** Testes unitários das regras de validação (ex: validador de CPF/CNPJ) e testes de integração do fluxo principal de busca.