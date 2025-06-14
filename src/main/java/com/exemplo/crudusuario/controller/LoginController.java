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
            @RequestParam(value = "erroSessao", required = false) String erroSessao,
            @RequestParam(value = "excluido", required = false) String excluido,
            Model model) {

        if (error != null) {
            model.addAttribute("error", "Email ou senha inválidos!");
        }

        if (logout != null) {
            model.addAttribute("logout", "Você saiu do sistema com sucesso!");
        }

        if (erroSessao != null) {
            model.addAttribute("error", "Sessão expirada ou usuário não encontrado. Faça login novamente.");
        }

        if (excluido != null) {
            model.addAttribute("logout", "Conta excluída com sucesso!");
        }

        return "login";
    }
}
