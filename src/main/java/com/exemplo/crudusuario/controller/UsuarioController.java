package com.exemplo.crudusuario.controller;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
@Controller
public class UsuarioController {
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("titulo", "CRUD de Usuários");
        return "index";
    }
}
