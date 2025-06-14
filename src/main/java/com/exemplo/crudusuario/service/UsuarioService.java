package com.exemplo.crudusuario.service;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.repository.UsuarioRepository;
import com.exemplo.crudusuario.service.exception.EmailJaCadastradoException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {

    private static final Logger log = LoggerFactory.getLogger(UsuarioService.class);
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    public void registrarUsuario(Usuario usuario) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent()) {
            throw new EmailJaCadastradoException("Este e-mail já está em uso.");
        }
        String encodedPassword = passwordEncoder.encode(usuario.getSenha());
        log.info("Registrando usuário: {}. Senha codificada: {}", usuario.getEmail(), encodedPassword);
        usuario.setSenha(encodedPassword);
        usuarioRepository.save(usuario);
    }
}
