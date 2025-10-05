USE hotel_management;

DELIMITER //

-- Trigger to update room availability after booking cancellation
DROP TRIGGER IF EXISTS AfterBookingCancellation;
CREATE TRIGGER AfterBookingCancellation
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'Cancelled' THEN
        UPDATE rooms SET is_available = TRUE WHERE room_id = NEW.room_id;
    END IF;
END //

-- Trigger to validate check-in and check-out dates
DROP TRIGGER IF EXISTS BeforeBookingInsert;
CREATE TRIGGER BeforeBookingInsert
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    IF NEW.check_in_date >= NEW.check_out_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check-out date must be after check-in date';
    END IF;
    IF NEW.check_in_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check-in date cannot be in the past';
    END IF;
END //

-- Trigger to validate email format
DROP TRIGGER IF EXISTS BeforeGuestInsert;
CREATE TRIGGER BeforeGuestInsert
BEFORE INSERT ON guests
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
END //

DELIMITER ;