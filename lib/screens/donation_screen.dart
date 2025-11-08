import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/donation_provider.dart';
import '../models/donation.dart';
import '../widgets/donation/glassmorphic_donation_card.dart';
import '../utils/app_theme.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        actions: [
          IconButton(
            onPressed: () => _showRequestDonationDialog(context),
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Request Donation',
            color: Colors.pink,
            iconSize: 28,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              Colors.pink.shade50.withValues(alpha: 0.3),
              Colors.purple.shade50.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Consumer<DonationProvider>(
          builder: (context, donationProvider, child) {
            if (donationProvider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading donation requests...'),
                  ],
                ),
              );
            }

            if (donationProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${donationProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        donationProvider.clearError();
                        donationProvider.fetchDonations();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final donations = donationProvider.donations;

            if (donations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.heart, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No donation requests available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check back later for new donation opportunities',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: donationProvider.fetchDonations,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  return GlassmorphicDonationCard(
                    donation: donation,
                    onDonate: () => _handleDonate(context, donation),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleDonate(BuildContext context, Donation donation) async {
    _showDonationDialog(context, donation);
  }

  void _showDonationDialog(BuildContext context, Donation donation) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DonationDialog(donation: donation),
    );
  }

  void _showRequestDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _RequestDonationDialog(),
    );
  }
}

// Donation Dialog Widget
class _DonationDialog extends StatefulWidget {
  final Donation donation;

  const _DonationDialog({required this.donation});

  @override
  State<_DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<_DonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _donorEmailController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final provider = Provider.of<DonationProvider>(context, listen: false);

    final receipt = await provider.processDonation(
      donationId: widget.donation.id,
      donorName: _donorNameController.text.trim(),
      donorEmail: _donorEmailController.text.trim(),
      donorPhone: _donorPhoneController.text.trim().isEmpty
          ? null
          : _donorPhoneController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (receipt != null) {
      Navigator.of(context).pop();
      _showReceiptDialog(receipt);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to process donation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReceiptDialog(dynamic receipt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.circleCheck, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Donation Successful!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thank you for your generous donation!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'DONOR RECEIPT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Divider(),
              Text(
                receipt.generateDonorReceipt(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.heart, color: Colors.pink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Donate to ${widget.donation.name}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donation history info
              if (widget.donation.totalDonationsReceived > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.info, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Recipient has received ${widget.donation.totalDonationsReceived} donation(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total received: ₱${widget.donation.totalAmountReceived.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _donorNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name *',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _donorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email *',
                  prefixIcon: Icon(LucideIcons.mail),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _donorPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Your Phone (Optional)',
                  prefixIcon: Icon(LucideIcons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Donation Amount *',
                  prefixIcon: Icon(LucideIcons.dollarSign),
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Message (Optional)',
                  prefixIcon: Icon(LucideIcons.messageSquare),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _processDonation,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.heart),
          label: Text(_isProcessing ? 'Processing...' : 'Donate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Request Donation Dialog Widget
class _RequestDonationDialog extends StatefulWidget {
  const _RequestDonationDialog();

  @override
  State<_RequestDonationDialog> createState() => _RequestDonationDialogState();
}

class _RequestDonationDialogState extends State<_RequestDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _storyController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Education';
  bool _isUrgent = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Education',
    'Arts & Design',
    'Science & Research',
    'Technology',
    'Sports',
    'Music',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _storyController.dispose();
    _targetAmountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = Provider.of<DonationProvider>(context, listen: false);

    final success = await provider.submitDonationRequest(
      studentName: _nameController.text.trim(),
      studentEmail: _emailController.text.trim(),
      school: _schoolController.text.trim(),
      story: _storyController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text.trim()),
      category: _selectedCategory,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      isUrgent: _isUrgent,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to submit request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.plus, color: Colors.pink),
          SizedBox(width: 8),
          Text('Request Donation', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name *',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email *',
                  prefixIcon: Icon(LucideIcons.mail),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  prefixIcon: Icon(LucideIcons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'School/University *',
                  prefixIcon: Icon(LucideIcons.graduationCap),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(LucideIcons.tag),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _storyController,
                decoration: const InputDecoration(
                  labelText: 'Your Story *',
                  prefixIcon: Icon(LucideIcons.fileText),
                  hintText: 'Explain why you need this donation',
                ),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount *',
                  prefixIcon: Icon(LucideIcons.dollarSign),
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  prefixIcon: Icon(LucideIcons.mapPin),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Mark as Urgent'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() => _isUrgent = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitRequest,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.send),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/* OLD DonationCard CLASS - Now using glassmorphic component
class DonationCard extends StatefulWidget {
  final Donation donation;

  const DonationCard({super.key, required this.donation});

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  Future<void> _handleDonate() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.heart,
                    color: Colors.pink,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connect with ${widget.donation.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Student Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink[100],
                          child: Icon(
                            LucideIcons.graduationCap,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.donation.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.donation.school,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.donation.category != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.donation.category!,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contact Options
              Text(
                'Contact Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (widget.donation.email != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.mail,
                      color: Colors.blue[800],
                      size: 20,
                    ),
                  ),
                  title: const Text('Email'),
                  subtitle: Text(widget.donation.email!),
                  trailing: const Icon(LucideIcons.externalLink, size: 16),
                  onTap: () {
                    // Open email app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email: ${widget.donation.email}'),
                        action: SnackBarAction(
                          label: 'Copy',
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ),
                    );
                  },
                ),

              if (widget.donation.phone != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.phone,
                      color: Colors.green[800],
                      size: 20,
                    ),
                  ),
                  title: const Text('Phone'),
                  subtitle: Text(widget.donation.phone!),
                  trailing: const Icon(LucideIcons.externalLink, size: 16),
                  onTap: () {
                    // Open phone app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone: ${widget.donation.phone}'),
                        action: SnackBarAction(
                          label: 'Copy',
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ),
                    );
                  },
                ),

              if (widget.donation.location != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      color: Colors.orange[800],
                      size: 20,
                    ),
                  ),
                  title: const Text('Location'),
                  subtitle: Text(widget.donation.location!),
                  trailing: const Icon(LucideIcons.externalLink, size: 16),
                  onTap: () {
                    // Open maps
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Location: ${widget.donation.location}'),
                        action: SnackBarAction(
                          label: 'View Map',
                          onPressed: () {
                            // Open maps app
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Thank you for helping ${widget.donation.name}!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.heart),
                      label: const Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.donation.progress;
    final remainingAmount =
        widget.donation.targetAmount != null &&
            widget.donation.amountRaised != null
        ? widget.donation.targetAmount! - widget.donation.amountRaised!
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and basic info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(
                    LucideIcons.user,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.donation.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (widget.donation.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        widget.donation.school,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      if (widget.donation.category != null)
                        Text(
                          widget.donation.category!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Story
            Text(
              widget.donation.story,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 16),

            // Progress section
            if (widget.donation.targetAmount != null &&
                widget.donation.amountRaised != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${widget.donation.amountRaised!.toStringAsFixed(0)} raised',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₱${widget.donation.targetAmount!.toStringAsFixed(0)} goal',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}% funded',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (remainingAmount != null && remainingAmount > 0)
                    Text(
                      '₱${remainingAmount.toStringAsFixed(0)} still needed',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

            // Deadline
            if (widget.donation.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${_formatDate(widget.donation.deadline!)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Donate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !widget.donation.isActive ? null : _handleDonate,
                icon: const Icon(LucideIcons.heart),
                label: Text(
                  widget.donation.isActive ? 'Donate Now' : 'Donation Closed',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: widget.donation.isActive
                      ? Colors.green
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Expired';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '$difference days left';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
*/
