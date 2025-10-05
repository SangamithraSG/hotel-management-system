USE hotel_management;

DELIMITER //

-- Procedure to add a new guest
CREATE PROCEDURE AddGuest(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255)
)
BEGIN
    INSERT INTO guests (name, email, phone, address)
    VALUES (p_name, p_email, p_phone, p_address);
    SELECT LAST_INSERT_ID() AS guest_id;

END //

-- Procedure to get all guests
CREATE PROCEDURE GetAllGuests()
BEGIN
    SELECT guest_id, name, email, phone, address, created_at
    FROM guests;
    SELECT CONCAT("HELLO"," ","hii") from dual;
END //

-- Procedure to check room availability
CREATE PROCEDURE CheckRoomAvailability(
    IN p_check_in_date DATE,
    IN p_check_out_date DATE
)
BEGIN
    SELECT r.room_id, r.room_number, r.room_type, r.price_per_night
    FROM rooms r
    WHERE r.is_available = TRUE
    AND r.room_id NOT IN (
        SELECT b.room_id
        FROM bookings b
        WHERE b.booking_status = 'Confirmed'
        AND (p_check_in_date <= b.check_out_date AND p_check_out_date >= b.check_in_date)
    );
END //

-- Procedure to book a room
CREATE PROCEDURE BookRoom(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in_date DATE,
    IN p_check_out_date DATE
)
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_days INT;
    
    -- Calculate total amount
    SELECT price_per_night INTO v_price FROM rooms WHERE room_id = p_room_id;
    SET v_days = DATEDIFF(p_check_out_date, p_check_in_date);
    
    -- Insert booking
    INSERT INTO bookings (guest_id, room_id, check_in_date, check_out_date, total_amount)
    VALUES (p_guest_id, p_room_id, p_check_in_date, p_check_out_date, v_price * v_days);
    
    -- Update room availability
    UPDATE rooms SET is_available = FALSE WHERE room_id = p_room_id;
    
    SELECT LAST_INSERT_ID() AS booking_id;
END //

-- Procedure to cancel a booking
CREATE PROCEDURE CancelBooking(
    IN p_booking_id INT
)
BEGIN
    UPDATE bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;
END //

-- Procedure to process payment
CREATE PROCEDURE ProcessPayment(
    IN p_booking_id INT,
    IN p_amount DECIMAL(10, 2),
    IN p_payment_method ENUM('Credit Card', 'Cash', 'Online')
)
BEGIN
    INSERT INTO payments (booking_id, amount, payment_method, payment_status)
    VALUES (p_booking_id, p_amount, p_payment_method, 'Completed');
END //

-- Procedure to get all bookings
CREATE PROCEDURE GetAllBookings()
BEGIN
    SELECT b.booking_id, g.name AS guest_name, r.room_number, b.check_in_date, 
           b.check_out_date, b.total_amount, b.booking_status
    FROM bookings b
    JOIN guests g ON b.guest_id = g.guest_id
    JOIN rooms r ON b.room_id = r.room_id;
END //

-- Procedure to get payments for a booking
CREATE PROCEDURE GetPayments(
    IN p_booking_id INT
)
BEGIN
    SELECT payment_id, amount, payment_method, payment_date, payment_status
    FROM payments
    WHERE booking_id = p_booking_id;
END //

DELIMITER ;