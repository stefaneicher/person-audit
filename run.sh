
#spring init --dependencies=web,data-jpa,h2,lombok --groupId=com.example --artifactId=person-audit --build=maven

# Step 2: Create the necessary directories
echo "Setting up project structure..."
mkdir -p src/main/java/com/example/personaudit/controller
mkdir -p src/main/java/com/example/personaudit/model
mkdir -p src/main/java/com/example/personaudit/repository
mkdir -p src/main/java/com/example/personaudit/service

# Step 3: Add H2 Database properties in application.properties
echo "Setting up H2 Database..."
cat <<EOL > src/main/resources/application.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.h2.console.enabled=true
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
EOL

# Step 4: Create SQL scripts for H2 and Oracle (schema.sql)
echo "Creating schema.sql..."
cat <<EOL > src/main/resources/schema.sql
-- Schema for Person table
CREATE TABLE Person (
    person_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    email VARCHAR(100),
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Schema for Person_Audit table
CREATE TABLE Person_Audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    person_id BIGINT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    email VARCHAR(100),
    version INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    updated_at TIMESTAMP
);
EOL

# Step 5: Create Java files for models, repositories, and services

# Model classes
echo "Creating model classes..."
cat <<EOL > src/main/java/com/example/personaudit/model/Person.java
package com.example.personaudit.model;

import lombok.Data;

import javax.persistence.*;
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
EOL

cat <<EOL > src/main/java/com/example/personaudit/model/PersonAudit.java
package com.example.personaudit.model;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Data
public class PersonAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long auditId;
    private Long personId;
    private String firstName;
    private String lastName;
    private String birthDate;
    private String email;
    private Integer version;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private LocalDateTime updatedAt;
}
EOL

# Repository interfaces
echo "Creating repository interfaces..."
cat <<EOL > src/main/java/com/example/personaudit/repository/PersonRepository.java
package com.example.personaudit.repository;

import com.example.personaudit.model.Person;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PersonRepository extends JpaRepository<Person, Long> {
}
EOL

cat <<EOL > src/main/java/com/example/personaudit/repository/PersonAuditRepository.java
package com.example.personaudit.repository;

import com.example.personaudit.model.PersonAudit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PersonAuditRepository extends JpaRepository<PersonAudit, Long> {
}
EOL

# Service class
echo "Creating service classes..."
cat <<EOL > src/main/java/com/example/personaudit/service/PersonService.java
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
EOL

# Controller class
echo "Creating controller class..."
cat <<EOL > src/main/java/com/example/personaudit/controller/PersonController.java
package com.example.personaudit.controller;

import com.example.personaudit.model.Person;
import com.example.personaudit.service.PersonService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/persons")
public class PersonController {

    private final PersonService personService;

    public PersonController(PersonService personService) {
        this.personService = personService;
    }

    @PostMapping
    public ResponseEntity<Person> createPerson(@RequestBody Person person) {
        return ResponseEntity.ok(personService.createPerson(person));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Person> updatePerson(@PathVariable Long id, @RequestBody Person person) {
        person.setPersonId(id);
        return ResponseEntity.ok(personService.updatePerson(person));
    }
}
EOL

# Step 6: Build and run the application
echo "Building and running the Spring Boot application..."
./mvnw spring-boot:run