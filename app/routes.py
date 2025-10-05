from flask import Blueprint, render_template, request, redirect, url_for, flash
from . import get_db_connection
from datetime import datetime

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    return render_template('index.html')

@bp.route('/add_guest', methods=['GET', 'POST'])
def add_guest():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        address = request.form['address']
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.callproc('AddGuest', [name, email, phone, address])
            for result in cursor.stored_results():
                guest_id = result.fetchone()['guest_id']
            conn.commit()
            flash('Guest added successfully!', 'success')
        except Exception as e:
            flash(f'Error adding guest: {str(e)}', 'error')
        
        cursor.close()
        conn.close()
        return redirect(url_for('main.view_guests'))
    
    return render_template('add_guest.html')

@bp.route('/view_guests')
def view_guests():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.callproc('GetAllGuests')
    guests = []
    for result in cursor.stored_results():
        guests = result.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('view_guests.html', guests=guests)

@bp.route('/check_availability', methods=['GET', 'POST'])
def check_availability():
    if request.method == 'POST':
        check_in = request.form['check_in']
        check_out = request.form['check_out']
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('CheckRoomAvailability', [check_in, check_out])
        
        available_rooms = []
        for result in cursor.stored_results():
            available_rooms = result.fetchall()
        
        cursor.close()
        conn.close()
        
        return render_template('check_availability.html', rooms=available_rooms)
    
    return render_template('check_availability.html')

@bp.route('/book_room/<int:room_id>', methods=['GET', 'POST'])
def book_room(room_id):
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        address = request.form['address']
        check_in = request.form['check_in']
        check_out = request.form['check_out']
        payment_method = request.form['payment_method']
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Add guest
            cursor.callproc('AddGuest', [name, email, phone, address])
            guest_id = None
            for result in cursor.stored_results():
                guest_id = result.fetchone()['guest_id']
            
            # Book room
            cursor.callproc('BookRoom', [guest_id, room_id, check_in, check_out])
            booking_id = None
            for result in cursor.stored_results():
                booking_id = result.fetchone()['booking_id']
            
            # Process payment
            cursor.callproc('ProcessPayment', [booking_id, request.form['amount'], payment_method])
            
            conn.commit()
            flash('Booking successful!', 'success')
            return redirect(url_for('main.view_bookings'))
        except Exception as e:
            flash(f'Error creating booking: {str(e)}', 'error')
        
        cursor.close()
        conn.close()
    
    return render_template('book_room.html', room_id=room_id)

@bp.route('/view_bookings')
def view_bookings():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.callproc('GetAllBookings')
    bookings = []
    for result in cursor.stored_results():
        bookings = result.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('view_bookings.html', bookings=bookings)

@bp.route('/cancel_booking/<int:booking_id>', methods=['POST'])
def cancel_booking(booking_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.callproc('CancelBooking', [booking_id])
        conn.commit()
        flash('Booking cancelled successfully!', 'success')
    except Exception as e:
        flash(f'Error cancelling booking: {str(e)}', 'error')
    
    cursor.close()
    conn.close()
    
    return redirect(url_for('main.view_bookings'))

@bp.route('/view_payments/<int:booking_id>')
def view_payments(booking_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.callproc('GetPayments', [booking_id])
    payments = []
    for result in cursor.stored_results():
        payments = result.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('view_payments.html', payments=payments, booking_id=booking_id)