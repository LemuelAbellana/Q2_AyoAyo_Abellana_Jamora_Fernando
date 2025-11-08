# Test Accounts for Donation System

## Overview
This document provides test accounts for both donors and recipients to test the complete donation flow with verification.

## Test Accounts

### 📝 Recipient Accounts (Students requesting donations)

**Account 1: John Doe (Already exists)**
- Name: John Doe
- Email: `john.doe@example.edu`
- School: University of Example
- Status: ✅ Verified
- Has received: 2 donations (₱8,500 total)
- Last donation: 5 days ago

**Account 2: Jane Smith (Already exists)**
- Name: Jane Smith
- Email: `jane.smith@example.hs.edu.ph`
- School: Example High School
- Status: ✅ Verified
- Has received: 3 donations (₱12,000 total)
- Last donation: 2 days ago

**Account 3: Peter Jones (Already exists)**
- Name: Peter Jones
- Email: `peter.jones@research.uni.edu.ph`
- School: Another University
- Status: ⏳ Pending verification
- Has received: 1 donation (₱5,200 total)
- Last donation: 15 days ago

### 💰 Donor Account (For testing donations)

**Test Donor**
- Name: Test Donor
- Email: `testdonor@example.com`
- Phone: +63 917 999 8888

## Testing Flow

### 🎓 Test as a Student (Recipient)

#### 1. Submit a Donation Request
1. Open the Donation screen
2. Click the **"Request Donation"** pink button (bottom right)
3. Fill in the form:
   - Your Name: `Maria Santos`
   - Your Email: `maria.santos@test.edu.ph`
   - Phone: `+63 918 111 2222` (optional)
   - School: `Test University`
   - Category: Select `Education`
   - Your Story: `I need a laptop for my online classes. My current device is broken and I can't afford a new one.`
   - Target Amount: `20000`
   - Location: `Manila` (optional)
   - Mark as Urgent: ✅ (check if urgent)
4. Click **"Submit Request"**
5. Your request will appear in the donation list (unverified status)

#### 2. View Pending Confirmations
1. Navigate to **My Donations** screen (you'll need to add navigation)
2. Pass your email: `maria.santos@test.edu.ph`
3. View all pending donations waiting for confirmation
4. Click **"Confirm Receipt"** when you actually receive the money
5. Confirm that you received the donation

### 💝 Test as a Donor

#### 1. Browse Donations
1. Open the Donation screen
2. See all active donation requests
3. Notice:
   - **Blue "VERIFIED" badge** on verified students
   - **Red "URGENT" badge** on urgent requests
   - **Donation History** section showing past donations

#### 2. Make a Donation
1. Click **"Donate Now"** on any donation card
2. Fill in the donation form:
   - Your Name: `Test Donor`
   - Your Email: `testdonor@example.com`
   - Your Phone: `+63 917 999 8888` (optional)
   - Donation Amount: `1000` (or any amount)
   - Message: `Good luck with your studies!` (optional)
3. Click **"Donate"**
4. Wait for processing
5. View the **receipt** that appears
6. Note the receipt number (format: `AYO-{donationId}-{transactionId}-{timestamp}`)

#### 3. Verify Receipt
- Both donor and recipient receive the same receipt number
- Donor gets: Donor Receipt
- Recipient gets: Recipient Receipt (shown when they confirm)

### 🔄 Complete Flow Test

**Step 1: Student Submits Request**
```
Student Email: studenttest@example.com
Creates donation request for ₱15,000
Status: Unverified (no blue badge)
Priority Score: ~20 points (low - unverified)
```

**Step 2: Donor Makes Donation**
```
Donor Email: donor@example.com
Donates: ₱2,000
Transaction Status: Completed
Recipient Confirmed: ❌ Not yet
```

**Step 3: Student Checks Pending**
```
Opens My Donations screen
Email: studenttest@example.com
Sees 1 pending confirmation
Views donor details and amount
```

**Step 4: Student Confirms Receipt**
```
Student clicks "Confirm Receipt"
Confirms they received ₱2,000
Transaction Status: ✅ Confirmed
```

**Step 5: Verify Updates**
```
Donation card now shows:
- Total donations received: 1
- Last donation: today
- Total amount received: ₱2,000
- Amount raised updated: ₱2,000 / ₱15,000
- Progress bar updated: 13.3%
```

## How to Access My Donations Screen

Since the screen is created but not yet integrated into navigation, you can access it by:

**Option 1: Add to main navigation**
Add this to your navigation routes:
```dart
'/my-donations': (context) => MyDonationsScreen(
  recipientEmail: 'john.doe@example.edu', // Use actual user email
),
```

**Option 2: Add button to donation screen**
Add a button in the app bar to navigate to pending confirmations.

**Option 3: Test directly**
Navigate directly in code:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyDonationsScreen(
      recipientEmail: 'john.doe@example.edu',
    ),
  ),
);
```

## Verification Statuses

| Status | Badge | Priority Impact |
|--------|-------|-----------------|
| ✅ Verified | Blue "VERIFIED" | +40 points |
| ⏳ Pending | None | +20 points |
| ❌ Unverified | None | 0 points |
| 🚫 Rejected | None | 0 points |

## Priority Score Calculation

**Example Scores:**
- New verified urgent student: ~80 points (HIGH PRIORITY)
- Verified, last donation 3 months ago: ~75 points
- Unverified student: ~20 points (LOW PRIORITY)
- Recently received (1 week ago): ~45 points

**Formula:**
- Verification: 0-40 points
- Urgency: 0-20 points
- Time since last donation: 0-20 points
- Funding gap: 0-20 points
- **Total: 0-100 points**

## Testing Scenarios

### Scenario 1: First-time Student
```
Email: newstudent@test.edu
Never received donations
Unverified status
Priority: ~20 points (low due to no verification)
```

### Scenario 2: Verified Urgent Need
```
Email: urgent@test.edu
Verified by admin
Marked as urgent
Never received before
Priority: ~80 points (HIGH - top of list)
```

### Scenario 3: Recent Recipient
```
Email: recent@test.edu
Verified
Received donation 3 days ago
Priority: ~40 points (lower due to recent donation)
```

## Receipt Format

**Donor Receipt:**
```
╔════════════════════════════════════════════════════════╗
║           AYOAYO DONATION RECEIPT (DONOR)              ║
╚════════════════════════════════════════════════════════╝

Receipt No: AYO-1234567890-9876543210-1704067200000
Issue Date: 2025-01-01 10:30

DONOR INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       Test Donor
Email:      testdonor@example.com

RECIPIENT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       Maria Santos
School:     Test University
Email:      maria.santos@test.edu.ph

DONATION DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Amount:     ₱1,000.00
Purpose:    I need a laptop for my online classes...

Thank you for your generous donation!
Your contribution helps students in need.
```

**Recipient Receipt:**
```
╔════════════════════════════════════════════════════════╗
║         AYOAYO DONATION RECEIPT (RECIPIENT)            ║
╚════════════════════════════════════════════════════════╝

Receipt No: AYO-1234567890-9876543210-1704067200000
Issue Date: 2025-01-01 10:30

RECIPIENT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       Maria Santos
School:     Test University
Email:      maria.santos@test.edu.ph

DONOR INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       Test Donor
Email:      testdonor@example.com

DONATION RECEIVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Amount:     ₱1,000.00
Purpose:    I need a laptop for my online classes...

Please acknowledge this donation and use it wisely.
Reach out to your donor to express gratitude.
```

## Quick Test Commands

To quickly test the system, use these example inputs:

**Submit Donation Request:**
```
Name: Quick Test
Email: quicktest@example.com
School: Test School
Category: Education
Story: Testing the donation system
Target: 5000
```

**Make Donation:**
```
Donor Name: Quick Donor
Donor Email: quickdonor@example.com
Amount: 500
```

**Confirm Receipt:**
```
Email: quicktest@example.com
(Navigate to My Donations)
Click: Confirm Receipt
```

## Notes

- All data is stored locally in SharedPreferences (web) or local storage
- No real money is transferred - this is for testing flow only
- Receipt numbers are unique based on timestamp
- Verification status can only be changed manually in the database (admin feature not implemented)
- Priority scores are calculated automatically
- Donations update recipient history immediately
- Confirmations are required for full verification

## Support

If you encounter issues:
1. Check that recipient email matches exactly
2. Ensure donations are for active requests
3. Verify that transactions are saved in SharedPreferences
4. Check console for error messages
