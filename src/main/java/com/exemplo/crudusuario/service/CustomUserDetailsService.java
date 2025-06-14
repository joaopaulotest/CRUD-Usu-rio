package com.exemplo.crudusuario.service;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private static final Logger log = LoggerFactory.getLogger(CustomUserDetailsService.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        log.info("Tentando carregar usuário pelo email: {}", email);
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("Usuário não encontrado com o email: {}", email);
                    return new UsernameNotFoundException("Usuário não encontrado com o email: " + email);
                });

        log.info("Usuário encontrado: {}. Senha (hash): {}", usuario.getEmail(), usuario.getSenha());
        return new User(usuario.getEmail(), usuario.getSenha(), new ArrayList<>());
    }
}
