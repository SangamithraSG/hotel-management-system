USE hotel_management;

-- Insert sample guests
INSERT INTO guests (name, email, phone, address) VALUES
('gomathi', 'gomathi@gmail.com', '9999999999', 'Chennai'),
('babu', 'babu@gmail.com', '8888888888', 'Salem');

-- Insert sample rooms
INSERT INTO rooms (room_number, room_type, price_per_night, is_available) VALUES
('103', 'Single', 50.00, TRUE),
('104', 'Double', 80.00, TRUE),
('202', 'Suite', 150.00, TRUE);

-- Insert sample bookings
INSERT INTO bookings (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status) VALUES
(1, 1, '2025-04-20', '2025-04-22', 100.00, 'Confirmed'),
(2, 2, '2025-04-21', '2025-04-23', 160.00, 'Confirmed');

-- Insert sample payments
INSERT INTO payments (booking_id, amount, payment_method, payment_status) VALUES
(1, 100.00, 'Credit Card', 'Completed'),
(2, 160.00, 'Online', 'Completed');