# Order Management System

A comprehensive pickup and delivery system for laundry management with real-time tracking, camera integration, and digital signatures.

## Features

### 🚚 Pickup & Delivery System
- **Daily Pickup Scheduling**: Schedule pickups for hotels with specific dates and times
- **Real-time Status Tracking**: Track orders through 11 different statuses from pending to delivered
- **Route Optimization**: Organized pickup and delivery management for laundry staff

### 📸 Camera Integration
- **Photo Documentation**: Take photos during pickup and delivery for quality assurance
- **Damage Recording**: Document item conditions with before/after photos
- **Real-time Capture**: Live camera feed with instant photo capture and preview

### ✍️ Digital Signatures
- **Pickup Signatures**: Hotel staff signs for item pickup confirmation
- **Delivery Signatures**: Hotel staff signs for delivery confirmation
- **Signature Storage**: Secure storage of digital signatures with signer details

### 💰 Smart Pricing System
- **Automatic Calculations**: Prices calculated based on client pricing models
- **Multiple Pricing Types**: Support for per-kg, per-piece, and flat-rate pricing
- **Real-time Totals**: Automatic calculation of subtotals, taxes, and total amounts

### 🏨 Dual Interface
- **Laundry Section**: For laundry staff to process orders and manage workflow
- **Hotel Section**: For hotel staff to create orders and track status

## Database Schema

### Core Tables

#### `orders`
- **order_id**: Unique identifier (UUID)
- **order_number**: Auto-generated order number (ORD-YYYYMMDD-XXXX)
- **client_id**: Reference to client
- **hotel_staff_id**: Hotel staff who created the order
- **laundry_staff_id**: Laundry staff assigned to process
- **order_type**: 'pickup' or 'delivery'
- **status**: Current order status (11 possible states)
- **scheduling fields**: Pickup/delivery dates and times
- **totals**: Items, weight, pricing information
- **notes**: Pickup, delivery, and special instructions

#### `order_items`
- **id**: Unique identifier (UUID)
- **order_id**: Reference to order
- **item_type_id**: Reference to laundry item type
- **quantity**: Number of items
- **weight**: Weight in kg
- **pricing**: Unit price, price type, line total
- **condition**: Pickup and delivery condition tracking
- **processing_notes**: Special processing instructions

#### `order_photos`
- **id**: Unique identifier (UUID)
- **order_id**: Reference to order
- **photo_type**: 'pickup', 'delivery', 'damage', 'before', 'after'
- **photo_url**: Image URL
- **photo_data**: Base64 encoded image data
- **taken_by**: User who took the photo
- **taken_at**: Timestamp

#### `order_signatures`
- **id**: Unique identifier (UUID)
- **order_id**: Reference to order
- **signature_type**: 'pickup' or 'delivery'
- **signature_data**: Base64 encoded signature
- **signer_name**: Name of person who signed
- **signer_role**: Role/position of signer
- **signed_at**: Timestamp

#### `laundry_item_types`
- **id**: Unique identifier (UUID)
- **name**: Item name (e.g., "Shirt", "Bed Sheet")
- **category**: 'clothing', 'bedding', 'towels', 'curtains', 'other'
- **default_price_per_kg**: Default kg pricing
- **default_price_per_piece**: Default piece pricing
- **is_active**: Active status

## Order Status Flow

1. **pending** → Order created, awaiting scheduling
2. **scheduled** → Pickup scheduled
3. **in_pickup** → Staff en route for pickup
4. **picked_up** → Items collected from hotel
5. **in_process** → Items being processed
6. **washing** → Items in washing stage
7. **drying** → Items in drying stage
8. **folding** → Items being folded/finished
9. **ready_for_delivery** → Items ready for return
10. **out_for_delivery** → Items en route to hotel
11. **delivered** → Items delivered to hotel

## Setup Instructions

### 1. Database Setup
```bash
# Navigate to the setup page
http://localhost:5173/orders/setup

# Click "Setup Database" to create all necessary tables
```

### 2. Required Dependencies
```bash
npm install signature_pad
```

### 3. Camera Permissions
- Grant camera access when prompted
- Ensure HTTPS for production deployment (required for camera API)

## Usage Guide

### Creating Orders

1. **Access Order Management**
   - Navigate to `/orders`
   - Choose "Laundry Section" or "Hotel Section"

2. **Create New Order**
   - Click "Create Order"
   - Select client and order type
   - Set pickup/delivery schedules
   - Add order items with quantities and weights
   - Prices auto-calculate based on client pricing

3. **Add Order Items**
   - Select item type from predefined categories
   - Enter quantity and weight
   - System automatically calculates pricing based on client settings

### Processing Pickups

1. **Access Pickup Tab**
   - Switch to "Pickup" tab
   - View scheduled pickups for the day

2. **Process Pickup**
   - Click "Process Pickup" on scheduled order
   - Take photos of items being collected
   - Count and verify items
   - Get hotel staff signature
   - Add pickup notes
   - Complete pickup

3. **Photo Documentation**
   - Start camera feed
   - Take multiple photos of items
   - Photos automatically timestamped
   - Remove photos if needed

4. **Digital Signature**
   - Hotel staff signs on signature pad
   - Enter signer name and role
   - Signature stored securely

### Processing Deliveries

1. **Access Delivery Tab**
   - Switch to "Delivery" tab
   - View orders ready for delivery

2. **Process Delivery**
   - Click "Process Delivery" on ready order
   - Take photos of cleaned items
   - Get hotel staff signature for receipt
   - Add delivery notes
   - Complete delivery

### Filtering and Search

- **Status Filter**: Filter by order status
- **Client Filter**: Filter by specific client
- **Date Filter**: Filter by today, this week, or all dates
- **Clear Filters**: Reset all filters

## Technical Implementation

### Camera Integration
```javascript
// Start camera with optimal settings
const stream = await navigator.mediaDevices.getUserMedia({
  video: { 
    width: { ideal: 1280 },
    height: { ideal: 720 }
  }
});

// Capture photo
const canvas = document.createElement('canvas');
const context = canvas.getContext('2d');
context.drawImage(video, 0, 0);
const imageData = canvas.toDataURL('image/jpeg', 0.8);
```

### Signature Capture
```javascript
// Initialize signature pad
const signaturePad = new SignaturePad(canvas, {
  backgroundColor: 'rgba(255, 255, 255, 0)',
  penColor: 'rgb(0, 0, 0)',
  velocityFilterWeight: 0.7,
  minWidth: 0.5,
  maxWidth: 2.5
});

// Get signature data
const signatureData = signaturePad.toDataURL();
```

### Pricing Calculation
```javascript
// Calculate line total based on pricing type
function updateLineTotal(item) {
  if (item.price_type === 'per_kg') {
    item.line_total = item.weight * item.unit_price;
  } else if (item.price_type === 'per_piece') {
    item.line_total = item.quantity * item.unit_price;
  } else if (item.price_type === 'flat_rate') {
    item.line_total = item.unit_price;
  }
}
```

## Security Features

- **User Authentication**: All actions require authenticated users
- **Role-based Access**: Different permissions for hotel vs laundry staff
- **Data Integrity**: Foreign key constraints and data validation
- **Audit Trail**: All actions timestamped with user information

## Performance Optimizations

- **Lazy Loading**: Photos loaded on demand
- **Efficient Queries**: Optimized database queries with proper indexing
- **Real-time Updates**: Reactive UI updates without page refreshes
- **Caching**: Client-side caching for frequently accessed data

## Mobile Responsiveness

- **Touch-friendly**: Signature pad optimized for touch devices
- **Responsive Design**: Works on tablets and mobile devices
- **Camera Integration**: Mobile camera support
- **Offline Capability**: Basic offline functionality for critical operations

## Troubleshooting

### Camera Issues
- **Permission Denied**: Check browser camera permissions
- **Not Working**: Ensure HTTPS in production
- **Poor Quality**: Adjust camera settings in code

### Signature Issues
- **Not Capturing**: Check canvas element initialization
- **Distorted**: Verify canvas dimensions
- **Not Saving**: Check signature pad isEmpty() method

### Database Issues
- **Tables Missing**: Run setup at `/orders/setup`
- **Foreign Key Errors**: Ensure clients table exists
- **Permission Errors**: Check Supabase RLS policies

## Future Enhancements

- **Barcode Scanning**: QR codes for item tracking
- **GPS Tracking**: Real-time location tracking for deliveries
- **Push Notifications**: Real-time status updates
- **Reporting Dashboard**: Analytics and performance metrics
- **Integration APIs**: Connect with external systems
- **Automated Scheduling**: AI-powered pickup optimization

## API Endpoints

### Order Management
- `POST /api/orders` - Create new order
- `GET /api/orders` - Get orders with filters
- `PUT /api/orders/:id` - Update order status
- `DELETE /api/orders/:id` - Cancel order

### Photo Management
- `POST /api/orders/:id/photos` - Upload photos
- `GET /api/orders/:id/photos` - Get order photos
- `DELETE /api/photos/:id` - Delete photo

### Signature Management
- `POST /api/orders/:id/signatures` - Save signature
- `GET /api/orders/:id/signatures` - Get signatures

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for efficient laundry management** 