package com.homefix.service_backend.service;

import com.homefix.service_backend.dto.LoginRequest;
import com.homefix.service_backend.dto.RegisterRequest;
import com.homefix.service_backend.entity.User;
import com.homefix.service_backend.entity.Worker;
import com.homefix.service_backend.repository.UserRepository;
import com.homefix.service_backend.repository.WorkerRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    private final UserRepository userRepo;
    private final WorkerRepository workerRepo;

    public AuthService(UserRepository userRepo, WorkerRepository workerRepo) {
        this.userRepo = userRepo;
        this.workerRepo = workerRepo;
    }

    // ================= REGISTER =================
    public String register(RegisterRequest req) {

        // Email OR phone must exist
        if ((req.email == null || req.email.isEmpty()) &&
                (req.phone == null || req.phone.isEmpty())) {
            throw new RuntimeException("Email or Phone is required");
        }

        if ("user".equalsIgnoreCase(req.role)) {

            if (userRepo.findByEmailOrPhone(req.email, req.phone).isPresent()) {
                throw new RuntimeException("User already exists");
            }

            User user = new User();
            user.setName(req.name);
            user.setEmail(req.email);
            user.setPhone(req.phone);
            user.setPassword(req.password);
            userRepo.save(user);

            return "User registered successfully";
        }

        else {

            if (workerRepo.findByEmailOrPhone(req.email, req.phone).isPresent()) {
                throw new RuntimeException("Worker already exists");
            }

            Worker worker = new Worker();
            worker.setName(req.name);
            worker.setEmail(req.email);
            worker.setPhone(req.phone);
            worker.setPassword(req.password);
            workerRepo.save(worker);

            return "Worker registered successfully";
        }
    }

    // ================= LOGIN =================
    public void login(LoginRequest req) {

        if ("user".equalsIgnoreCase(req.role)) {

            User user = userRepo
                    .findByEmailOrPhone(req.emailOrPhone, req.emailOrPhone)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (!user.getPassword().equals(req.password)) {
                throw new RuntimeException("Incorrect password");
            }
        }

        else {

            Worker worker = workerRepo
                    .findByEmailOrPhone(req.emailOrPhone, req.emailOrPhone)
                    .orElseThrow(() -> new RuntimeException("Worker not found"));

            if (!worker.getPassword().equals(req.password)) {
                throw new RuntimeException("Incorrect password");
            }
        }
    }
}
