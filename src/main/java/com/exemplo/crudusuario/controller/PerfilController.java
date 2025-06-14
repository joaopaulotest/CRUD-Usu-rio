package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Perfil;
import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.PerfilService;
import com.exemplo.crudusuario.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.Optional;

@Controller
public class PerfilController {

    @Autowired
    private PerfilService perfilService;

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping("/meu-perfil")
    public String mostrarPerfil(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        Optional<Usuario> usuarioOpt = usuarioService.buscarOptionalPorEmail(email);
        if (usuarioOpt.isEmpty()) {
            SecurityContextHolder.clearContext();
            return "redirect:/login?erroSessao";
        }
        Usuario usuario = usuarioOpt.get();
        if (usuario.getPerfil() == null) {
            model.addAttribute("perfil", new Perfil());
        } else {
            model.addAttribute("perfil", usuario.getPerfil());
        }
        return "meu-perfil";
    }

    @PostMapping("/meu-perfil")
    public String salvarPerfil(
            @Valid @ModelAttribute("perfil") Perfil perfil,
            BindingResult bindingResult,
            Model model) {
        if (bindingResult.hasErrors()) {
            return "meu-perfil";
        }
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        Optional<Usuario> usuarioOpt = usuarioService.buscarOptionalPorEmail(email);
        if (usuarioOpt.isEmpty()) {
            SecurityContextHolder.clearContext();
            return "redirect:/login?erroSessao";
        }
        Usuario usuario = usuarioOpt.get();
        perfil.setUsuario(usuario);
        if (usuario.getPerfil() != null) {
            perfil.setId(usuario.getPerfil().getId());
        }
        perfilService.salvarPerfil(perfil);
        model.addAttribute("sucesso", "Perfil atualizado com sucesso!");
        return "meu-perfil";
    }
}