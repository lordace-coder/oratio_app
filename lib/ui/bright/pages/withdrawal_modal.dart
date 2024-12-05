import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class WithdrawalModal extends StatefulWidget {
  const WithdrawalModal({super.key});

  @override
  _WithdrawalModalState createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  // Bank selection dropdown values
  final List<String> _bankNames = [
    'St. Mary\'s Credit Union',
    'Mercy Bank',
    'Providence Financial',
    'Holy Cross Bank',
    'Guardian Savings',
  ];
  String? _selectedBank;

  // Text controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  // State for loading
  bool _isLoading = false;

  // Data map to hold withdrawal details
  Map<String, dynamic> data = {};

  void _submitWithdrawal() {
    // Validation logic
    if (_amountController.text.isEmpty) {
      _showValidationError('Please enter a withdrawal amount');
      return;
    }

    if (_accountController.text.isEmpty) {
      _showValidationError('Please enter an account number');
      return;
    }

    if (_selectedBank == null) {
      _showValidationError('Please select a bank');
      return;
    }

    // Prepare data map
    data = {
      'amount': _amountController.text,
      'account': _accountController.text,
      'bank': _selectedBank,
    };

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Withdrawal request for \$${data['amount']} submitted successfully!'),
          backgroundColor: Colors.deepPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Close the modal
      Navigator.of(context).pop();

      // Clear data
      _resetForm();
    });
  }

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _accountController.clear();
      _selectedBank = null;
      data.clear();
    });
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with Catholic-inspired design
                FadeIn(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.church_outlined,
                        color: Colors.deepPurple[700],
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Withdrawal Request',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                FadeInRight(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Withdrawal Amount',
                      prefixIcon: Icon(Icons.monetization_on,
                          color: Colors.deepPurple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Enter amount',
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Account Number Input
                FadeInRight(
                  child: TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      prefixIcon: Icon(Icons.account_balance,
                          color: Colors.deepPurple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Enter account number',
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Bank Dropdown
                FadeInRight(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBank,
                    hint: Text(
                      'Select Bank',
                      style: TextStyle(color: Colors.deepPurple[700]),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_balance_sharp,
                          color: Colors.deepPurple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _bankNames.map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBank = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button with Loading State
                FadeInUp(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple[700]!,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitWithdrawal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }
}
