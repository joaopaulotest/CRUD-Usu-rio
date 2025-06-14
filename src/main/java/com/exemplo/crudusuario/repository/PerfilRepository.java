package com.exemplo.crudusuario.repository;

import com.exemplo.crudusuario.model.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PerfilRepository extends JpaRepository<Perfil, Long> {
}