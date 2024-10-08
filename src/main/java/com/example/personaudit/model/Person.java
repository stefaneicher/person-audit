package com.example.personaudit.model;

import lombok.Data;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Data
public class Person {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long personId;
    private String firstName;
    private String lastName;
    private String birthDate;
    private String email;
    private Integer version;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
