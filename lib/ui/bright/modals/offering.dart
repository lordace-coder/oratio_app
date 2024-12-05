import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OfferingGivingModal extends StatefulWidget {
  const OfferingGivingModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => const OfferingGivingModal(),
    );
  }

  @override
  _OfferingGivingModalState createState() => _OfferingGivingModalState();
}

class _OfferingGivingModalState extends State<OfferingGivingModal> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // New loading state variable
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Method to collect offering data
  Map<String, dynamic> _collectOfferingData() {
    // Remove any currency symbols and commas
    String cleanAmount = _amountController.text.replaceAll(r'[^\d.]', '');
    double amount = double.parse(cleanAmount);

    return {
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void _submitOffering() async {
    if (_formKey.currentState!.validate()) {
      // Set loading state
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate network request
        await Future.delayed(const Duration(seconds: 2), () {
          // Collect offering data
          final data = _collectOfferingData();
          print('Offering Data: $data');

          // Close the modal
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thank you for your offering of ${data['amount']}'),
              backgroundColor: Colors.green,
            ),
          );
        });
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit offering: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Ensure loading state is reset
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Handle
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Give an Offering',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('₦',
                        style: TextStyle(
                            fontSize: 18, color: Colors.deepPurple[700])),
                  ],
                ),
                hintText: 'Enter Offering Amount',
                labelText: 'Offering Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      BorderSide(color: Colors.deepPurple[700]!, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an offering amount';
                }
                // Remove currency formatting to validate
                String cleanAmount = value.replaceAll(r'[^\d.]\', '');
                double? amount = double.tryParse(cleanAmount);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Submit Button with Loading State
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOffering,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Submit Offering',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// CurrencyInputFormatter remains the same as in the original code
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digit characters
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Convert to double
    double value = double.parse(cleanedText) / 100;

    // Format as currency
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
