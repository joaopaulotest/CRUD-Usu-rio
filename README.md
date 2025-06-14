# CRUD-Usuário

Este projeto é um sistema web para cadastro e gerenciamento de usuários, com área pessoal para edição de dados complementares.

## Funcionalidades
- Cadastro de usuário (nome, e-mail, senha)
- Login seguro
- Dashboard com mensagem de boas-vindas
- Área pessoal "Meu Perfil" para gerenciar dados pessoais:
  - CPF
  - Data de nascimento
  - Profissão
  - O que faz atualmente
- Edição dos dados pessoais a qualquer momento
- Logout

## Tecnologias Utilizadas
- Java 17
- Spring Boot
- Spring Security
- Spring Data JPA
- Thymeleaf
- H2 Database (memória)
- Maven

## Como executar o projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/joaopaulotest/CRUD-Usu-rio.git
   ```
2. **Acesse a pasta do projeto:**
   ```bash
   cd CRUD-Usu-rio
   ```
3. **Execute o projeto:**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```
4. **Acesse no navegador:**
   - [http://localhost:8080](http://localhost:8080)

## Fluxo do sistema
1. **Cadastro:**
   - Usuário informa nome, e-mail e senha.
2. **Login:**
   - Usuário faz login com e-mail e senha.
3. **Dashboard:**
   - Mensagem de boas-vindas e botão "Meu Perfil".
4. **Meu Perfil:**
   - Usuário pode adicionar/editar CPF, data de nascimento, profissão e atividade atual.
   - Dados ficam salvos e podem ser editados a qualquer momento.

## Observações
- O banco de dados H2 é utilizado apenas para testes e desenvolvimento.
- Para acessar o console do banco: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)
  - **Driver Class:** `org.h2.Driver`
  - **JDBC URL:** `jdbc:h2:mem:testdb`
  - **User Name:** `sa`
  - **Password:** `password`
- Sinta-se à vontade para contribuir!

---

Desenvolvido por João Paulo e colaboradores.
