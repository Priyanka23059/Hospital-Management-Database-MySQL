CREATE DATABASE hospital_management;
USE hospital_management;
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    gender ENUM('Male', 'Female', 'Other'),
    phone VARCHAR(15),
    address VARCHAR(255)
);
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
CREATE TABLE Treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    diagnosis VARCHAR(255),
    medicine VARCHAR(255),
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);
CREATE TABLE Bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    bill_date DATE,
    amount DECIMAL(10,2),
    payment_status ENUM('Paid', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);
INSERT INTO Doctors (first_name, last_name, specialization, phone, email)
VALUES 
('Anita', 'Sharma', 'Cardiology', '9876543210', 'anita@hospital.com'),
('Ravi', 'Kumar', 'Orthopedics', '9988776655', 'ravi@hospital.com'),
('Neha', 'Patel', 'Neurology', '9123456789', 'neha@hospital.com');

INSERT INTO Patients (first_name, last_name, age, gender, phone, address)
VALUES
('John', 'Doe', 35, 'Male', '9000012345', 'New Delhi'),
('Priya', 'Singh', 29, 'Female', '9112233445', 'Mumbai'),
('Rahul', 'Mehta', 42, 'Male', '9223344556', 'Pune');

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, status)
VALUES
(1, 1, '2025-10-20', '10:00:00', 'Completed'),
(2, 2, '2025-10-21', '11:00:00', 'Scheduled'),
(3, 3, '2025-10-22', '12:00:00', 'Completed');

INSERT INTO Treatments (appointment_id, diagnosis, medicine, treatment_cost)
VALUES
(1, 'Heart Checkup', 'Atorvastatin', 2000.00),
(3, 'Migraine', 'Sumatriptan', 1500.00);

INSERT INTO Bills (appointment_id, bill_date, amount, payment_status)
VALUES
(1, '2025-10-20', 2000.00, 'Paid'),
(2, '2025-10-21', 1500.00, 'Pending'),
(3, '2025-10-22', 1500.00, 'Paid');

SELECT a.appointment_id, 
       p.first_name AS patient, 
       d.first_name AS doctor, 
       a.appointment_date, 
       a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

SELECT SUM(amount) AS total_revenue FROM Bills WHERE payment_status = 'Paid';

SELECT b.bill_id, p.first_name, b.amount
FROM Bills b
JOIN Appointments a ON b.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
WHERE payment_status = 'Pending';

SELECT d.first_name AS doctor, COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;

DELIMITER //
CREATE TRIGGER generate_bill AFTER INSERT ON Treatments
FOR EACH ROW
BEGIN
  INSERT INTO Bills (appointment_id, bill_date, amount, payment_status)
  VALUES (NEW.appointment_id, CURDATE(), NEW.treatment_cost, 'Pending');
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE mark_bill_paid(IN billId INT)
BEGIN
  UPDATE Bills SET payment_status = 'Paid' WHERE bill_id = billId;
END;
//
DELIMITER ;

CALL mark_bill_paid(2);

CREATE VIEW BillSummary AS
SELECT p.first_name AS patient, d.first_name AS doctor, 
       a.appointment_date, b.amount, b.payment_status
FROM Bills b
JOIN Appointments a ON b.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;
