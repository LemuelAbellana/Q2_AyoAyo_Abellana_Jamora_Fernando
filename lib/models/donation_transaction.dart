import '../utils/enum_helpers.dart';

enum TransactionStatus { pending, completed, cancelled }

/// Represents a single donation transaction from a donor to a recipient
class DonationTransaction {
  final int id;
  final int donationId; // Reference to the donation request
  final String donorName;
  final String donorEmail;
  final String? donorPhone;
  final double amount;
  final DateTime transactionDate;
  final TransactionStatus status;
  final String? receiptNumber;
  final String? notes;

  // Verification fields
  final bool recipientConfirmed; // Has recipient confirmed receiving?
  final DateTime? recipientConfirmedAt;

  DonationTransaction({
    required this.id,
    required this.donationId,
    required this.donorName,
    required this.donorEmail,
    this.donorPhone,
    required this.amount,
    required this.transactionDate,
    this.status = TransactionStatus.completed,
    this.receiptNumber,
    this.notes,
    this.recipientConfirmed = false,
    this.recipientConfirmedAt,
  });

  // Generate receipt number
  static String generateReceiptNumber(int donationId, int transactionId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'AYO-$donationId-$transactionId-$timestamp';
  }

  // Create from JSON
  factory DonationTransaction.fromJson(Map<String, dynamic> json) {
    return DonationTransaction(
      id: json['id'] ?? 0,
      donationId: json['donation_id'] ?? 0,
      donorName: json['donor_name'] ?? '',
      donorEmail: json['donor_email'] ?? '',
      donorPhone: json['donor_phone'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : DateTime.now(),
      status: parseEnumWithFallback(
        TransactionStatus.values,
        json['status'],
        TransactionStatus.completed,
      ),
      receiptNumber: json['receipt_number'],
      notes: json['notes'],
      recipientConfirmed: json['recipient_confirmed'] == true || json['recipient_confirmed'] == 1,
      recipientConfirmedAt: json['recipient_confirmed_at'] != null
          ? DateTime.parse(json['recipient_confirmed_at'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'donor_name': donorName,
      'donor_email': donorEmail,
      'donor_phone': donorPhone,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      'status': getEnumName(status),
      'receipt_number': receiptNumber,
      'notes': notes,
      'recipient_confirmed': recipientConfirmed,
      'recipient_confirmed_at': recipientConfirmedAt?.toIso8601String(),
    };
  }

  // Copy with method for updates
  DonationTransaction copyWith({
    bool? recipientConfirmed,
    DateTime? recipientConfirmedAt,
  }) {
    return DonationTransaction(
      id: id,
      donationId: donationId,
      donorName: donorName,
      donorEmail: donorEmail,
      donorPhone: donorPhone,
      amount: amount,
      transactionDate: transactionDate,
      status: status,
      receiptNumber: receiptNumber,
      notes: notes,
      recipientConfirmed: recipientConfirmed ?? this.recipientConfirmed,
      recipientConfirmedAt: recipientConfirmedAt ?? this.recipientConfirmedAt,
    );
  }
}
