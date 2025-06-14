# 1. Criar DashboardController
@"
package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("usuarios", usuarioService.listarTodosUsuarios());
        return "dashboard";
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\DashboardController.java" -Encoding utf8

# 2. Adicionar métodos ao UsuarioService
$usuarioServicePath = "src\main\java\com\exemplo\crudusuario\service\UsuarioService.java"
$newServiceContent = @"
package com.exemplo.crudusuario.service;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

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
    
    public List<Usuario> listarTodosUsuarios() {
        return usuarioRepository.findAll();
    }
    
    public Usuario buscarPorId(Long id) {
        return usuarioRepository.findById(id).orElseThrow();
    }
    
    public void atualizarUsuario(Long id, Usuario usuarioAtualizado) {
        Usuario usuario = buscarPorId(id);
        usuario.setNome(usuarioAtualizado.getNome());
        usuario.setEmail(usuarioAtualizado.getEmail());
        usuarioRepository.save(usuario);
    }
    
    public void excluirUsuario(Long id) {
        usuarioRepository.deleteById(id);
    }
}
"@
$newServiceContent | Out-File -FilePath $usuarioServicePath -Encoding utf8 -Force

# 3. Criar UsuarioController para operações CRUD
@"
package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping("/editar/{id}")
    public String mostrarFormEdicao(@PathVariable Long id, Model model) {
        Usuario usuario = usuarioService.buscarPorId(id);
        model.addAttribute("usuario", usuario);
        return "editar-usuario";
    }

    @PostMapping("/editar/{id}")
    public String atualizarUsuario(@PathVariable Long id, Usuario usuario) {
        usuarioService.atualizarUsuario(id, usuario);
        return "redirect:/dashboard";
    }

    @GetMapping("/excluir/{id}")
    public String excluirUsuario(@PathVariable Long id) {
        usuarioService.excluirUsuario(id);
        return "redirect:/dashboard";
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\UsuarioController.java" -Encoding utf8

# 4. Criar template dashboard.html
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="dashboard-container">
        <h1>Usuários Cadastrados</h1>
        <div class="actions">
            <a href="/logout" class="btn btn-secondary">Sair</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>Email</th>
                    <th>Status</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                <tr th:each="usuario : ${usuarios}">
                    <td th:text="${usuario.id}"></td>
                    <td th:text="${usuario.nome}"></td>
                    <td th:text="${usuario.email}"></td>
                    <td>
                        <span th:if="${usuario.ativo}" style="color: green">Ativo</span>
                        <span th:unless="${usuario.ativo}" style="color: red">Inativo</span>
                    </td>
                    <td>
                        <a th:href="@{/editar/{id}(id=${usuario.id})}" class="btn btn-primary">Editar</a>
                        <a th:href="@{/excluir/{id}(id=${usuario.id})}" class="btn btn-danger">Excluir</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\dashboard.html" -Encoding utf8

# 5. Criar template editar-usuario.html
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Editar Usuário</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="editar-container">
        <h2>Editar Usuário</h2>
        <form th:action="@{/editar/{id}(id=${usuario.id})}" th:object="${usuario}" method="post">
            <div class="form-group">
                <label for="nome">Nome Completo</label>
                <input type="text" id="nome" th:field="*{nome}" class="form-control">
            </div>
            
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" th:field="*{email}" class="form-control">
            </div>
            
            <div class="form-group">
                <label for="ativo">Status</label>
                <select id="ativo" th:field="*{ativo}" class="form-control">
                    <option value="true">Ativo</option>
                    <option value="false">Inativo</option>
                </select>
            </div>
            
            <button type="submit" class="btn btn-primary">Atualizar</button>
        </form>
        <div class="links">
            <a th:href="@{/dashboard}">Voltar para o dashboard</a>
        </div>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\editar-usuario.html" -Encoding utf8

# 6. Atualizar SecurityConfig para proteger rotas CRUD
$securityConfigPath = "src\main\java\com\exemplo\crudusuario\config\SecurityConfig.java"
$newSecurityConfig = @"
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
                .requestMatchers(
                    "/", 
                    "/index", 
                    "/login", 
                    "/cadastro", 
                    "/esqueci-senha", 
                    "/h2-console/**", 
                    "/css/**"
                ).permitAll()
                .requestMatchers("/dashboard", "/editar/**", "/excluir/**").authenticated()
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
"@
$newSecurityConfig | Out-File -FilePath $securityConfigPath -Encoding utf8 -Force

# 7. Atualizar CSS com estilos para dashboard
$cssPath = "src\main\resources\static\css\styles.css"
$cssContent = Get-Content $cssPath -Raw
$newCssContent = $cssContent + @"

/* Estilos para dashboard */
.dashboard-container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 20px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}

th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

th {
    background-color: #f2f2f2;
}

tr:hover {
    background-color: #f5f5f5;
}

.btn-danger {
    background-color: #e74c3c;
    color: white;
}

.btn-danger:hover {
    background-color: #c0392b;
}

.actions {
    margin-bottom: 20px;
    text-align: right;
}
"@
$newCssContent | Out-File -FilePath $cssPath -Encoding utf8 -Force

Write-Host "CRUD completo implementado com sucesso!"
Write-Host "Execute o projeto com: mvn spring-boot:run"