import 'dart:io';

import 'package:ace_toast/ace_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';

class PaymentAccount {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String currency;
  final String type;

  PaymentAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.currency,
    required this.type,
  });
}

enum PaymentStep { selectAccount, submitProof }

Future<RecordModel?> getPaymentProof(BuildContext context) async {
  return await showModalBottomSheet<RecordModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PaymentProofModal(),
  );
}

class PaymentProofModal extends StatefulWidget {
  const PaymentProofModal({super.key});

  @override
  State<PaymentProofModal> createState() => _PaymentProofModalState();
}

class _PaymentProofModalState extends State<PaymentProofModal>
    with TickerProviderStateMixin {
  PaymentStep currentStep = PaymentStep.selectAccount;
  PaymentAccount? selectedAccount;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Payment proof form controllers
  final _formKey = GlobalKey<FormState>();
  final _transactionRefController = TextEditingController();
  final _amountController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  // Sample account data
  final List<PaymentAccount> accounts = [
    PaymentAccount(
      bankName: 'UBA',
      accountNumber: '2303637325',
      accountName: 'Building Bridges Initiative Nigeria',
      currency: '₦ NGN',
      type: 'Nigerian',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transactionRefController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    NotificationService.showInfo("$label copied to clipboard");
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      NotificationService.showError('Failed to pick image: $e');
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        _transactionRefController.text = data.text!;
      }
    } catch (e) {
      NotificationService.showError('Failed to paste from clipboard');
    }
  }

  Future<RecordModel?> _submitPaymentProof() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      NotificationService.showError(
          'Please fill all fields and select an image');
      return null;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get PocketBase instance from context
      final pb = getPocketBaseFromContext(context);

      // Create form data
      final formData = <String, dynamic>{
        'transaction_ref': _transactionRefController.text.trim(),
        'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
        'bank_name': selectedAccount?.bankName,
        'account_name': selectedAccount?.accountName,
        'currency': selectedAccount?.currency,
        "user": pb.authStore.model.id
      };

      final List<http.MultipartFile> files = [];
      // Add image file
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();

        files.add(http.MultipartFile.fromBytes(
          "proof",
          bytes,
          filename:
              'payment_proof_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      // Create record in PocketBase
      final record = await pb
          .collection('payment_disputes')
          .create(body: formData, files: files);

      return record;
    } catch (e) {
      NotificationService.showError('Failed to submit payment proof: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goToSubmissionStep() {
    setState(() {
      currentStep = PaymentStep.submitProof;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _goBackToSelection() {
    setState(() {
      currentStep = PaymentStep.selectAccount;
      selectedAccount = null;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentStep == PaymentStep.submitProof)
                  IconButton(
                    onPressed: _goBackToSelection,
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (currentStep == PaymentStep.submitProof)
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentStep == PaymentStep.selectAccount
                        ? 'Select Payment Account'
                        : 'Submit Payment Proof',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child: currentStep == PaymentStep.selectAccount
                        ? _buildAccountSelection()
                        : _buildPaymentSubmission(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an account to make payment to:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Account header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: account.type == 'Nigerian'
                              ? Colors.green[50]
                              : Colors.blue[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: account.type == 'Nigerian'
                                    ? Colors.green[100]
                                    : Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                account.currency,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: account.type == 'Nigerian'
                                      ? Colors.green[800]
                                      : Colors.blue[800],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${account.type} Account',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Account details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildAccountDetail(
                              'Bank Name',
                              account.bankName,
                              Icons.account_balance,
                            ),
                            const SizedBox(height: 12),
                            _buildAccountDetail(
                              'Account Number',
                              account.accountNumber,
                              Icons.credit_card,
                            ),
                            const SizedBox(height: 12),
                            _buildAccountDetail(
                              'Account Name',
                              account.accountName,
                              Icons.person,
                            ),
                            const SizedBox(height: 16),

                            // Select button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  selectedAccount = account;
                                  _goToSubmissionStep();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: account.type == 'Nigerian'
                                      ? Colors.green
                                      : Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Select This Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _copyToClipboard(value, label),
          icon: const Icon(Icons.copy, size: 16),
          visualDensity: VisualDensity.compact,
          tooltip: 'Copy $label',
        ),
      ],
    );
  }

  Widget _buildPaymentSubmission() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected account summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment to: ${selectedAccount?.bankName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedAccount?.accountName} (${selectedAccount?.currency})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Reference
                    Text(
                      'Transaction Reference',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _transactionRefController,
                      decoration: InputDecoration(
                        hintText: 'Enter transaction reference',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.receipt),
                        suffixIcon: IconButton(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.content_paste),
                          tooltip: 'Paste from clipboard',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter transaction reference';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Amount
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: _getCurrencyIcon(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Payment Proof Image
                    Text(
                      'Payment Proof',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 32,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select payment proof',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                final record = await _submitPaymentProof();
                                if (record != null && mounted) {
                                  Navigator.pop(context, record);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Payment Proof',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrencyIcon() {
    if (selectedAccount?.type == 'Nigerian') {
      return const Padding(
        padding: EdgeInsets.all(9.0),
        child: Text(
          '₦',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const Icon(Icons.attach_money);
    }
  }
}
