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
