package com.homefix.service_backend.repository;

import com.homefix.service_backend.entity.Worker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkerRepository extends JpaRepository<Worker, Long> {
    Optional<Worker> findByEmailOrPhone(String email, String phone);
}
