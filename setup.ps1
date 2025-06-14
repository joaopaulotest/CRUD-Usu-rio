# Criar estrutura de diretórios
New-Item -ItemType Directory -Path "src\main\java\com\exemplo\crudusuario\model" -Force
New-Item -ItemType Directory -Path "src\main\java\com\exemplo\crudusuario\repository" -Force
New-Item -ItemType Directory -Path "src\main\java\com\exemplo\crudusuario\service" -Force
New-Item -ItemType Directory -Path "src\main\java\com\exemplo\crudusuario\config" -Force
New-Item -ItemType Directory -Path "src\main\resources\static\css" -Force

# Arquivo: model/Usuario.java
@"
package com.exemplo.crudusuario.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Entity
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Nome é obrigatório")
    private String nome;
    
    @Email(message = "Email inválido")
    @NotBlank(message = "Email é obrigatório")
    @Column(unique = true)
    private String email;
    
    @NotBlank(message = "Senha é obrigatória")
    private String senha;
    
    private boolean ativo = true;
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\model\Usuario.java" -Encoding utf8

# Arquivo: repository/UsuarioRepository.java
@"
package com.exemplo.crudusuario.repository;

import com.exemplo.crudusuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByEmail(String email);
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\repository\UsuarioRepository.java" -Encoding utf8

# Arquivo: service/UsuarioService.java
@"
package com.exemplo.crudusuario.service;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    public Usuario registrarUsuario(Usuario usuario) {
        usuario.setSenha(passwordEncoder.encode(usuario.getSenha()));
        return usuarioRepository.save(usuario);
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\service\UsuarioService.java" -Encoding utf8

# Arquivo: config/SecurityConfig.java
@"
package com.exemplo.crudusuario.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/", "/cadastro", "/esqueci-senha", "/h2-console/**").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .defaultSuccessUrl("/dashboard", true)
                .permitAll()
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/login?logout")
                .permitAll()
            )
            .csrf(csrf -> csrf
                .ignoringRequestMatchers("/h2-console/**")
            )
            .headers(headers -> headers
                .frameOptions().disable()
            );
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\config\SecurityConfig.java" -Encoding utf8

# Arquivo: controller/LoginController.java
@"
package com.exemplo.crudusuario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {
    
    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {
        
        if (error != null) {
            model.addAttribute("error", "Email ou senha inválidos!");
        }
        
        if (logout != null) {
            model.addAttribute("logout", "Você saiu do sistema com sucesso!");
        }
        
        return "login";
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\LoginController.java" -Encoding utf8

# Arquivo: controller/CadastroController.java
@"
package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class CadastroController {
    
    @Autowired
    private UsuarioService usuarioService;
    
    @GetMapping("/cadastro")
    public String mostrarFormularioCadastro(Model model) {
        model.addAttribute("usuario", new Usuario());
        return "cadastro";
    }
    
    @PostMapping("/cadastro")
    public String registrarUsuario(
            @Valid @ModelAttribute("usuario") Usuario usuario,
            BindingResult bindingResult,
            Model model) {
        
        if (bindingResult.hasErrors()) {
            return "cadastro";
        }
        
        try {
            usuarioService.registrarUsuario(usuario);
            model.addAttribute("sucesso", "Cadastro realizado com sucesso! Faça login.");
            return "login";
        } catch (Exception e) {
            model.addAttribute("erro", "Erro ao cadastrar: " + e.getMessage());
            return "cadastro";
        }
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\CadastroController.java" -Encoding utf8

# Arquivo: controller/RecuperarSenhaController.java
@"
package com.exemplo.crudusuario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class RecuperarSenhaController {
    
    @GetMapping("/esqueci-senha")
    public String mostrarFormularioRecuperacao() {
        return "recuperar-senha";
    }
    
    @PostMapping("/esqueci-senha")
    public String enviarLinkRecuperacao(
            @RequestParam("email") String email,
            Model model) {
        
        // Simulação de envio de email
        model.addAttribute("sucesso", "Um link de recuperação foi enviado para: " + email);
        return "recuperar-senha";
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\RecuperarSenhaController.java" -Encoding utf8

# Arquivo: resources/application.properties
@"
# Configurações do banco de dados H2
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Ativar console do H2
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# Configurações do Thymeleaf
spring.thymeleaf.cache=false

# Configurações de segurança
spring.security.user.name=admin
spring.security.user.password=admin
"@ | Out-File -FilePath "src\main\resources\application.properties" -Encoding utf8

# Arquivo: templates/login.html
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        
        <div th:if="${error}" class="alert alert-danger" th:text="${error}"></div>
        <div th:if="${logout}" class="alert alert-success" th:text="${logout}"></div>
        <div th:if="${sucesso}" class="alert alert-success" th:text="${sucesso}"></div>
        
        <form th:action="@{/login}" method="post">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="username" required class="form-control">
            </div>
            
            <div class="form-group">
                <label for="senha">Senha</label>
                <input type="password" id="senha" name="password" required class="form-control">
            </div>
            
            <button type="submit" class="btn btn-primary">Entrar</button>
        </form>
        
        <div class="links">
            <a th:href="@{/esqueci-senha}">Esqueci minha senha</a>
            <a th:href="@{/cadastro}">Não possui cadastro? Cadastre-se</a>
        </div>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\login.html" -Encoding utf8

# Arquivo: templates/cadastro.html
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Cadastro</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="cadastro-container">
        <h2>Cadastro de Usuário</h2>
        
        <div th:if="${erro}" class="alert alert-danger" th:text="${erro}"></div>
        
        <form th:action="@{/cadastro}" th:object="${usuario}" method="post">
            <div class="form-group">
                <label for="nome">Nome Completo</label>
                <input type="text" id="nome" th:field="*{nome}" class="form-control">
                <small th:if="${#fields.hasErrors('nome')}" class="text-danger" th:errors="*{nome}"></small>
            </div>
            
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" th:field="*{email}" class="form-control">
                <small th:if="${#fields.hasErrors('email')}" class="text-danger" th:errors="*{email}"></small>
            </div>
            
            <div class="form-group">
                <label for="senha">Senha</label>
                <input type="password" id="senha" th:field="*{senha}" class="form-control">
                <small th:if="${#fields.hasErrors('senha')}" class="text-danger" th:errors="*{senha}"></small>
            </div>
            
            <button type="submit" class="btn btn-primary">Cadastrar</button>
        </form>
        
        <div class="links">
            <a th:href="@{/login}">Já possui cadastro? Faça login</a>
        </div>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\cadastro.html" -Encoding utf8

# Arquivo: templates/recuperar-senha.html
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Recuperar Senha</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="recuperar-container">
        <h2>Recuperar Senha</h2>
        
        <div th:if="${sucesso}" class="alert alert-success" th:text="${sucesso}"></div>
        
        <form th:action="@{/esqueci-senha}" method="post">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required class="form-control">
            </div>
            
            <button type="submit" class="btn btn-primary">Enviar Link de Recuperação</button>
        </form>
        
        <div class="links">
            <a th:href="@{/login}">Voltar para login</a>
        </div>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\recuperar-senha.html" -Encoding utf8

# Arquivo: static/css/styles.css
@"
/* Estilos gerais */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f5f5f5;
    margin: 0;
    padding: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    text-align: center;
}

/* Containers de formulário */
.login-container, 
.cadastro-container, 
.recuperar-container {
    background: white;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    width: 100%;
    max-width: 400px;
}

h1, h2 {
    color: #2c3e50;
    margin-bottom: 20px;
}

/* Formulários */
.form-group {
    margin-bottom: 15px;
    text-align: left;
}

label {
    display: block;
    margin-bottom: 5px;
    font-weight: 500;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    box-sizing: border-box;
}

.form-control:focus {
    border-color: #3498db;
    outline: none;
    box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
}

/* Botões */
.btn {
    padding: 10px 15px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1em;
    width: 100%;
    margin-top: 10px;
    transition: background-color 0.3s;
}

.btn-primary {
    background: #3498db;
    color: white;
}

.btn-primary:hover {
    background: #2980b9;
}

.btn-secondary {
    background: #95a5a6;
    color: white;
    margin-top: 10px;
}

.btn-secondary:hover {
    background: #7f8c8d;
}

/* Alertas */
.alert {
    padding: 10px;
    margin-bottom: 15px;
    border-radius: 4px;
}

.alert-success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.alert-danger {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

/* Links */
.links {
    margin-top: 20px;
    text-align: center;
}

.links a {
    display: block;
    margin: 10px 0;
    color: #3498db;
    text-decoration: none;
}

.links a:hover {
    text-decoration: underline;
}

.text-danger {
    color: #e74c3c;
    font-size: 0.9em;
    display: block;
    margin-top: 5px;
}

.actions {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 20px;
}
"@ | Out-File -FilePath "src\main\resources\static\css\styles.css" -Encoding utf8

Write-Host "Estrutura de arquivos criada com sucesso!"
Write-Host "Execute o projeto com: mvn spring-boot:run"