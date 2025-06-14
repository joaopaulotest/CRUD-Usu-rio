package com.exemplo.crudusuario.service;

import com.exemplo.crudusuario.model.Perfil;
import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.repository.PerfilRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PerfilService {
    @Autowired
    private PerfilRepository perfilRepository;

    public Perfil salvarPerfil(Perfil perfil) {
        return perfilRepository.save(perfil);
    }

    public Perfil criarPerfilVazio(Usuario usuario) {
        Perfil perfil = new Perfil();
        perfil.setUsuario(usuario);
        return perfilRepository.save(perfil);
    }
}