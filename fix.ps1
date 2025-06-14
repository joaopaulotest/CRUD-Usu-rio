# 1. Criar página inicial (index.html)
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>CRUD Usuário</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div class="container">
        <h1>CRUD de Usuários</h1>
        <p>Sistema de gerenciamento de usuários</p>
        
        <div class="actions">
            <a th:href="@{/login}" class="btn btn-primary">Fazer Login</a>
            <a th:href="@{/cadastro}" class="btn btn-secondary">Cadastrar-se</a>
        </div>
    </div>
</body>
</html>
"@ | Out-File -FilePath "src\main\resources\templates\index.html" -Encoding utf8

# 2. Atualizar SecurityConfig.java
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
                .requestMatchers(
                    "/", 
                    "/index", 
                    "/login", 
                    "/cadastro", 
                    "/esqueci-senha", 
                    "/h2-console/**", 
                    "/css/**"
                ).permitAll()
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
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\config\SecurityConfig.java" -Encoding utf8 -Force

# 3. Criar HomeController.java
@"
package com.exemplo.crudusuario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    
    @GetMapping({"/", "/index"})
    public String home() {
        return "index";
    }
}
"@ | Out-File -FilePath "src\main\java\com\exemplo\crudusuario\controller\HomeController.java" -Encoding utf8

# 4. Criar arquivo de internacionalização do H2 (h2_pt_br.properties)
@"
# Mensagens em Português para Console H2
webAdmin=Administrador H2
generic=Genérico
settings=Configurações
savedSettings=Configurações Salvas
settingName=Nome da Configuração
driverClass=Classe do Driver
jdbcUrl=URL JDBC
userName=Nome do Usuário
password=Senha
connect=Conectar
testConnection=Testar Conexão
save=Salvar
remove=Remover
"@ | Out-File -FilePath "src\main\resources\h2_pt_br.properties" -Encoding utf8

# 5. Atualizar application.properties
$appProps = Get-Content "src\main\resources\application.properties" -Raw
$appProps += "`n# Configuração de internacionalização do H2`n"
$appProps += "spring.h2.console.settings.web-admin-languages=pt_br`n"
$appProps | Out-File -FilePath "src\main\resources\application.properties" -Encoding utf8

Write-Host "Correções aplicadas com sucesso!"
Write-Host "Execute o projeto com: mvn spring-boot:run"