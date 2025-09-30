import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:pocketbase/pocketbase.dart';

// Add Priest model
class Priest {
  final String id;
  final String name;

  Priest({required this.id, required this.name});
}

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({
    super.key,
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Priest? selectedPriest;
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  List<Priest> priests = [];
  bool isLoading = true;
  bool loadError = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = getUser(context).getStringValue("phone_number");
    _loadPriests();
  }

  Future<void> _loadPriests() async {
    final user = getUser(context);
    try {
      final pb = getPocketBaseFromContext(context);
      final records = await pb.collection('parish').getFullList(
            filter: "members ~ '${user.id}'",
            expand: "priest",
          );
      setState(() {
        print(['name', getFullName(records.first)]);

        priests = records
            .map((record) => Priest(
                  id: record.expand['priest']!.first.id,
                  name: getFullName(record.expand['priest']!.first),
                ))
            .toList();
        isLoading = false;
        loadError = false;
      });
    } catch (e) {
      print("Error loading priests: $e");
      NotificationService.showError(
          "Failed to load priests. Please try again.");
      setState(() {
        isLoading = false;
        loadError = true;
      });
    }
  }

  DateTime? getCombinedDateTime() {
    if (selectedDate != null && selectedTime != null) {
      return DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }
    return null;
  }

  void _showConfirmationDialog() {
    final combinedDateTime = getCombinedDateTime();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Request Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for requesting an appointment with our priest.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Priest: ${selectedPriest?.name}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'Your preferred date and time: ${combinedDateTime!.day}/${combinedDateTime.month}/${combinedDateTime.year} ${combinedDateTime.hour}:${combinedDateTime.minute}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Next Steps:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Our team will review your request\n2. We will contact you within 24-48 hours\n3. Once approved, you\'ll receive a confirmation message',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.blue[700], fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAppointment() async {
    final pb = getPocketBaseFromContext(context);
    final combinedDateTime = getCombinedDateTime();
    final data = {
      "user": getUser(context).id,
      "priest": selectedPriest?.id,
      'selectedDate': combinedDateTime.toString(),
      'contact': phoneController.text,
      'purpose': purposeController.text,
    };

    try {
      await pb.collection('appointment').create(body: data);
      _showConfirmationDialog();
      context.pushNamed(RouteNames.homePage);
    } catch (e) {
      NotificationService.showError("Failed to submit appointment");
      debugPrint("error occurred $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: createAppBar(
        context,
        label: 'Book Appointment',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule a Meeting',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Meet with our priest for spiritual guidance, counseling, or general discussion. Once you submit your request, we will review it and contact you within 24-48 hours to confirm the appointment.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Priest Selection Section
                const Text(
                  'Select Priest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (loadError)
                  Column(
                    children: [
                      const Text(
                        'Failed to load priests. Please try again.',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadPriests,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else if (priests.isEmpty)
                  const Text(
                    'Please join a parish first.',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Priest>(
                        isExpanded: true,
                        value: selectedPriest,
                        hint: const Text('Select a priest'),
                        items: priests.map((Priest priest) {
                          return DropdownMenuItem<Priest>(
                            value: priest,
                            child: Text(priest.name),
                          );
                        }).toList(),
                        onChanged: (Priest? newValue) {
                          setState(() {
                            selectedPriest = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Date and Time Section
                const Text(
                  'Preferred Date & Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate != null
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                    : 'Select Date',
                                style: TextStyle(
                                  color: selectedDate != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : 'Select Time',
                                style: TextStyle(
                                  color: selectedTime != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Purpose Section
                const Text(
                  'Purpose of Meeting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: purposeController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Briefly describe the purpose of your meeting...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDate != null &&
                          selectedTime != null &&
                          selectedPriest != null &&
                          phoneController.text.isNotEmpty &&
                          purposeController.text.isNotEmpty) {
                        _submitAppointment();
                      } else {
                        NotificationService.showError(
                            "Please fill all the fields");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Request Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
