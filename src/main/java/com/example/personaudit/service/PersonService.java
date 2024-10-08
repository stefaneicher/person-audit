package com.example.personaudit.service;

import com.example.personaudit.model.Person;
import com.example.personaudit.model.PersonAudit;
import com.example.personaudit.repository.PersonAuditRepository;
import com.example.personaudit.repository.PersonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class PersonService {

    private final PersonRepository personRepository;
    private final PersonAuditRepository personAuditRepository;

    public PersonService(PersonRepository personRepository, PersonAuditRepository personAuditRepository) {
        this.personRepository = personRepository;
        this.personAuditRepository = personAuditRepository;
    }

    @Transactional
    public Person updatePerson(Person person) {
        // Store current version in audit
        PersonAudit audit = new PersonAudit();
        audit.setPersonId(person.getPersonId());
        audit.setFirstName(person.getFirstName());
        audit.setLastName(person.getLastName());
        audit.setBirthDate(person.getBirthDate());
        audit.setEmail(person.getEmail());
        audit.setVersion(person.getVersion());
        audit.setValidFrom(person.getCreatedAt());
        audit.setValidTo(LocalDateTime.now());
        audit.setUpdatedAt(person.getUpdatedAt());
        personAuditRepository.save(audit);

        // Increment the version in the main table
        person.setVersion(person.getVersion() + 1);
        person.setUpdatedAt(LocalDateTime.now());

        return personRepository.save(person);
    }

    public Person createPerson(Person person) {
        person.setCreatedAt(LocalDateTime.now());
        person.setUpdatedAt(LocalDateTime.now());
        person.setVersion(1);
        return personRepository.save(person);
    }
}
