import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/donation_provider.dart';
import '../models/donation_transaction.dart';
import '../utils/app_theme.dart';

/// Screen for recipients to view and confirm donations they've received
class MyDonationsScreen extends StatefulWidget {
  final String recipientEmail;

  const MyDonationsScreen({super.key, required this.recipientEmail});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPendingConfirmations();
  }

  Future<void> _loadPendingConfirmations() async {
    final provider = Provider.of<DonationProvider>(context, listen: false);
    await provider.getPendingConfirmations(widget.recipientEmail);
  }

  Future<void> _confirmReceipt(DonationTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Receipt'),
        content: Text(
          'Have you received the donation of ₱${transaction.amount.toStringAsFixed(0)} from ${transaction.donorName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<DonationProvider>(context, listen: false);
      final success = await provider.confirmReceipt(
        transaction.id,
        widget.recipientEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Donation confirmed successfully!'
                  : provider.errorMessage ?? 'Failed to confirm',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadPendingConfirmations();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              Colors.green.shade50.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: FutureBuilder<List<DonationTransaction>>(
          future: Provider.of<DonationProvider>(context, listen: false)
              .getPendingConfirmations(widget.recipientEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final pendingTransactions = snapshot.data ?? [];

            if (pendingTransactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.circleCheck,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending confirmations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All donations have been confirmed',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingTransactions.length,
              itemBuilder: (context, index) {
                final transaction = pendingTransactions[index];
                return _PendingDonationCard(
                  transaction: transaction,
                  onConfirm: () => _confirmReceipt(transaction),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PendingDonationCard extends StatelessWidget {
  final DonationTransaction transaction;
  final VoidCallback onConfirm;

  const _PendingDonationCard({
    required this.transaction,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.circleAlert,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Confirmation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Receipt: ${transaction.receiptNumber ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(LucideIcons.user, 'Donor', transaction.donorName),
            const SizedBox(height: 8),
            _buildInfoRow(LucideIcons.mail, 'Email', transaction.donorEmail),
            if (transaction.donorPhone != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                  LucideIcons.phone, 'Phone', transaction.donorPhone!),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              LucideIcons.dollarSign,
              'Amount',
              '₱${transaction.amount.toStringAsFixed(0)}',
              valueColor: Colors.green.shade700,
              valueBold: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              LucideIcons.calendar,
              'Date',
              _formatDate(transaction.transactionDate),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.messageSquare,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Message from donor',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(LucideIcons.circleCheck),
                label: const Text('Confirm Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.grey.shade800,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
