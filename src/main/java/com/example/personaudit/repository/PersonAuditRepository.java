package com.example.personaudit.repository;

import com.example.personaudit.model.PersonAudit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PersonAuditRepository extends JpaRepository<PersonAudit, Long> {
}
