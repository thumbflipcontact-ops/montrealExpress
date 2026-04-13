# Payment System Documentation

## Overview

The AbdoulExpress payment system supports multiple payment methods popular in Francophone Africa, with a focus on Mobile Money and manual receipt verification for flexibility.

## Payment Methods

### 1. Mobile Money
- **Wave**: USSD code *144#
- **Orange Money**: USSD code #144#
- **Moov Money**: USSD code *555#

### 2. Bank Transfer
- Manual transfer with receipt upload
- Bank details provided in-app

### 3. Cash on Delivery
- Pay in cash upon delivery
- No upfront payment required

### 4. Manual Receipt Upload
- For any payment type
- Upload photo of receipt
- Manual verification by admin

## User Flow

```
Cart → Checkout (Delivery Info)
  ↓
Payment Method Selection
  ↓
Payment Processing
  ├─ Mobile Money → Phone Input → Confirmation
  ├─ Bank Transfer → Instructions → Receipt Upload
  ├─ Cash on Delivery → Confirmation
  └─ Manual Receipt → Camera → Details Form → Submit
  ↓
Payment Confirmation
  ↓
Payment History (Track Status)
```

## Payment States

- **Pending**: Payment initiated, awaiting confirmation
- **Processing**: Receipt uploaded, under review
- **Verified**: Payment confirmed by admin
- **Rejected**: Payment rejected (invalid receipt, etc.)
- **Completed**: Order fulfilled
- **Failed**: Payment failed

## Receipt Upload

### Required Information
1. **Photo**: Clear image of receipt
2. **Transaction Reference**: Unique transaction ID
3. **Description** (optional): Additional details

### Image Requirements
- Format: JPG, PNG
- Max size: Automatically compressed to 1920x1920
- Quality: 85%

### Verification Process
1. User uploads receipt
2. Status changes to "Processing"
3. Admin reviews receipt (backend)
4. Status updated to "Verified" or "Rejected"
5. User receives notification

## Integration Points

### Checkout Page
```dart
// Navigate to payment selection
Navigator.push(
  MaterialPageRoute(
    builder: (_) => PaymentMethodSelectionPage(
      orderId: orderId,
      userId: userId,
      totalAmount: total,
    ),
  ),
);
```

### Payment History
```dart
// Load user's payment history
context.read<PaymentCubit>().loadPaymentHistory(userId);

// Navigate to history page
Navigator.push(
  MaterialPageRoute(
    builder: (_) => PaymentHistoryPage(userId: userId),
  ),
);
```

## State Management

### PaymentCubit Methods

```dart
// Select payment method
selectPaymentMethod(String methodId)

// Create new payment
createPayment({
  required String orderId,
  required String userId,
  required double amount,
  required String methodId,
  String? transactionRef,
})

// Upload receipt
uploadReceipt({
  required String paymentId,
  required String receiptPath,
  required String description,
  String? transactionRef,
})

// Load payment history
loadPaymentHistory(String userId)
```

## Backend Integration (Future)

### API Endpoints

#### POST /api/payments/create
Create a new payment

**Request**:
```json
{
  "orderId": "ORD-123",
  "userId": "USER-001",
  "amount": 25000,
  "methodId": "wave",
  "transactionRef": "90123456"
}
```

**Response**:
```json
{
  "paymentId": "PAY-456",
  "status": "pending",
  "createdAt": "2025-12-01T10:00:00Z"
}
```

#### POST /api/payments/:id/receipt
Upload payment receipt

**Request** (multipart/form-data):
- `receipt`: Image file
- `transactionRef`: String
- `description`: String

**Response**:
```json
{
  "success": true,
  "status": "processing"
}
```

#### GET /api/payments/history/:userId
Get payment history

**Response**:
```json
{
  "payments": [
    {
      "id": "PAY-456",
      "orderId": "ORD-123",
      "amount": 25000,
      "methodId": "wave",
      "status": "verified",
      "createdAt": "2025-12-01T10:00:00Z",
      "verifiedAt": "2025-12-01T12:00:00Z"
    }
  ]
}
```

## Mobile Money Integration

### Wave API (Example)
```dart
// Future implementation
class WavePaymentService {
  Future<PaymentResult> initiatePayment({
    required String phone,
    required double amount,
  }) async {
    // Call Wave API
    // Return payment URL or confirmation
  }
}
```

### Orange Money API (Example)
```dart
class OrangeMoneyService {
  Future<PaymentResult> initiatePayment({
    required String phone,
    required double amount,
  }) async {
    // Call Orange Money API
  }
}
```

## Security Considerations

1. **Receipt Storage**: Store receipts securely (encrypted)
2. **Transaction IDs**: Validate format and uniqueness
3. **Amount Verification**: Cross-check with order total
4. **User Authentication**: Verify user owns the order
5. **Rate Limiting**: Prevent spam uploads

## Testing

### Manual Testing Checklist
- [ ] Select each payment method
- [ ] Complete Mobile Money flow
- [ ] Upload receipt (camera)
- [ ] Upload receipt (gallery)
- [ ] View payment history
- [ ] Check status badges
- [ ] Test with different amounts
- [ ] Verify form validation

### Edge Cases
- No camera permission
- No gallery permission
- Large image files
- Invalid transaction reference
- Network errors during upload
- Empty payment history

## Future Enhancements

1. **Real-time Status Updates**: WebSocket for instant notifications
2. **QR Code Payments**: Scan to pay
3. **Payment Links**: Share payment link via WhatsApp
4. **Recurring Payments**: Subscription support
5. **Payment Analytics**: Dashboard for admins
6. **Multi-currency**: Support for different currencies
7. **Refunds**: Automated refund processing
