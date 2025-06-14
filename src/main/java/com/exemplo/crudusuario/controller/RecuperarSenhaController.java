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
