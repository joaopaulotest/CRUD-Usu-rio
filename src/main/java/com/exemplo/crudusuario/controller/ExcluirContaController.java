package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Optional;

@Controller
public class ExcluirContaController {
    @Autowired
    private UsuarioService usuarioService;

    @GetMapping("/excluir-conta")
    public String excluirConta() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        Optional<Usuario> usuarioOpt = usuarioService.buscarOptionalPorEmail(email);
        if (usuarioOpt.isEmpty()) {
            SecurityContextHolder.clearContext();
            return "redirect:/login?erroSessao";
        }
        Usuario usuario = usuarioOpt.get();
        usuarioService.excluirUsuario(usuario.getId());
        SecurityContextHolder.clearContext();
        return "redirect:/login?excluido";
    }
}