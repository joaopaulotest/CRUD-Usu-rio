package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Optional;

@Controller
public class AlterarSenhaController {
    @Autowired
    private UsuarioService usuarioService;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/alterar-senha")
    public String mostrarFormAlterarSenha(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        Optional<Usuario> usuarioOpt = usuarioService.buscarOptionalPorEmail(email);
        if (usuarioOpt.isEmpty()) {
            SecurityContextHolder.clearContext();
            return "redirect:/login?erroSessao";
        }
        return "alterar-senha";
    }

    @PostMapping("/alterar-senha")
    public String alterarSenha(@RequestParam String senhaAtual,
            @RequestParam String novaSenha,
            @RequestParam String confirmarSenha,
            Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        Optional<Usuario> usuarioOpt = usuarioService.buscarOptionalPorEmail(email);
        if (usuarioOpt.isEmpty()) {
            SecurityContextHolder.clearContext();
            return "redirect:/login?erroSessao";
        }
        Usuario usuario = usuarioOpt.get();
        if (!passwordEncoder.matches(senhaAtual, usuario.getSenha())) {
            model.addAttribute("erro", "Senha atual incorreta!");
            return "alterar-senha";
        }
        if (!novaSenha.equals(confirmarSenha)) {
            model.addAttribute("erro", "As senhas não coincidem!");
            return "alterar-senha";
        }
        usuario.setSenha(passwordEncoder.encode(novaSenha));
        usuarioService.salvar(usuario);
        model.addAttribute("sucesso", "Senha alterada com sucesso!");
        return "alterar-senha";
    }
}