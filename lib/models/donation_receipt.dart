/// Represents a receipt for both donor and recipient
class DonationReceipt {
  final String receiptNumber;
  final int donationId;
  final int transactionId;
  final DateTime issueDate;

  // Donor information
  final String donorName;
  final String donorEmail;

  // Recipient information
  final String recipientName;
  final String recipientSchool;
  final String recipientEmail;

  // Transaction details
  final double amount;
  final String purpose;

  DonationReceipt({
    required this.receiptNumber,
    required this.donationId,
    required this.transactionId,
    required this.issueDate,
    required this.donorName,
    required this.donorEmail,
    required this.recipientName,
    required this.recipientSchool,
    required this.recipientEmail,
    required this.amount,
    required this.purpose,
  });

  // Create from JSON
  factory DonationReceipt.fromJson(Map<String, dynamic> json) {
    return DonationReceipt(
      receiptNumber: json['receipt_number'] ?? '',
      donationId: json['donation_id'] ?? 0,
      transactionId: json['transaction_id'] ?? 0,
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'])
          : DateTime.now(),
      donorName: json['donor_name'] ?? '',
      donorEmail: json['donor_email'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientSchool: json['recipient_school'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      purpose: json['purpose'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'receipt_number': receiptNumber,
      'donation_id': donationId,
      'transaction_id': transactionId,
      'issue_date': issueDate.toIso8601String(),
      'donor_name': donorName,
      'donor_email': donorEmail,
      'recipient_name': recipientName,
      'recipient_school': recipientSchool,
      'recipient_email': recipientEmail,
      'amount': amount,
      'purpose': purpose,
    };
  }

  // Generate formatted receipt text for donor
  String generateDonorReceipt() {
    return '''
╔════════════════════════════════════════════════════════╗
║           AYOAYO DONATION RECEIPT (DONOR)              ║
╚════════════════════════════════════════════════════════╝

Receipt No: $receiptNumber
Issue Date: ${_formatDate(issueDate)}

DONOR INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       $donorName
Email:      $donorEmail

RECIPIENT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       $recipientName
School:     $recipientSchool
Email:      $recipientEmail

DONATION DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Amount:     ₱${amount.toStringAsFixed(2)}
Purpose:    $purpose

Thank you for your generous donation!
Your contribution helps students in need.

For inquiries, please contact us with your receipt number.
''';
  }

  // Generate formatted receipt text for recipient
  String generateRecipientReceipt() {
    return '''
╔════════════════════════════════════════════════════════╗
║         AYOAYO DONATION RECEIPT (RECIPIENT)            ║
╚════════════════════════════════════════════════════════╝

Receipt No: $receiptNumber
Issue Date: ${_formatDate(issueDate)}

RECIPIENT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       $recipientName
School:     $recipientSchool
Email:      $recipientEmail

DONOR INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       $donorName
Email:      $donorEmail

DONATION RECEIVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Amount:     ₱${amount.toStringAsFixed(2)}
Purpose:    $purpose

Please acknowledge this donation and use it wisely.
Reach out to your donor to express gratitude.

Keep this receipt for your records.
''';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
