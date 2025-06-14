package com.exemplo.crudusuario.controller;

import com.exemplo.crudusuario.model.Usuario;
import com.exemplo.crudusuario.service.UsuarioService;
import com.exemplo.crudusuario.service.exception.EmailJaCadastradoException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class CadastroController {
    
    @Autowired
    private UsuarioService usuarioService;
    
    @GetMapping("/cadastro")
    public String mostrarFormularioCadastro(Model model) {
        model.addAttribute("usuario", new Usuario());
        return "cadastro";
    }
    
    @PostMapping("/cadastro")
    public String registrarUsuario(
            @Valid @ModelAttribute("usuario") Usuario usuario,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {

        if (bindingResult.hasErrors()) {
            return "cadastro";
        }

        try {
            usuarioService.registrarUsuario(usuario);
            redirectAttributes.addFlashAttribute("sucesso", "Cadastro realizado com sucesso! Faça o login.");
            return "redirect:/login";
        } catch (EmailJaCadastradoException e) {
            model.addAttribute("erro", e.getMessage());
            return "cadastro";
        } catch (Exception e) {
            model.addAttribute("erro", "Ocorreu um erro inesperado ao tentar realizar o cadastro.");
            return "cadastro";
        }
    }
}
