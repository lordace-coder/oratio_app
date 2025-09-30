import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:pocketbase/pocketbase.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;

  // Modern event type with more contemporary icons and subtle design
  final List<Map<String, dynamic>> _eventTypes = [
    {'icon': Icons.design_services_outlined, 'name': 'Workshop'},
    {'icon': Icons.group_outlined, 'name': 'Networking'},
    {'icon': Icons.local_cafe_outlined, 'name': 'Meetup'},
    {'icon': Icons.workspace_premium_outlined, 'name': 'Seminar'},
    {'icon': Icons.screen_share_outlined, 'name': 'Virtual'},
    {'icon': Icons.star_outline, 'name': 'Special'}
  ];
  String _selectedEventType = 'Workshop';
  bool _isLoading = false;
  RecordModel? parish;

  Map<String, dynamic> data = {};

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              primary: Colors.deepPurple,
              secondary: Colors.deepPurple,
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createEvent() async {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;

    if (_validateInputs()) {
      // Prepare data map
      data = {
        'title': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'date': _selectedDate.toString(),
        'type': _selectedEventType,
        'parish': parish?.id,
      };

      // Simulate loading state with network request
      setState(() {
        _isLoading = true;
      });
      try {
        await pb.collection('schedule').create(body: data);
        // Show success snackbar
        PopupNotification.show(
            message: 'Event "${data['title']}" created successfully!',
            title: 'Created Succesfully');

        // Reset form
        _resetForm();
        context.pop();
      } catch (e) {
        _showErrorSnackbar('Error occured during upload \n $e');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateInputs() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter an event title');
      return false;
    }
    if (_locationController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a Location');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackbar('Please provide an event description');
      return false;
    }

    if (_selectedDate == null) {
      _showErrorSnackbar('Please select an event date');
      return false;
    }

    return true;
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectedEventType = 'Workshop';
      data.clear();
    });
  }

  void _showErrorSnackbar(String message) {
    NotificationService.showError(message);
  }

  @override
  void initState() {
    super.initState();
    if (context.read<ProfileDataCubit>().state is ProfileDataLoaded) {
      parish = (context.read<ProfileDataCubit>().state as ProfileDataLoaded)
          .profile
          .parishLeading;
    }
    // set location to parish location if location is empty
    if (_locationController.text.trim().isEmpty) {
      _locationController.text = parish?.getStringValue('location') ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Modern Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: FadeIn(
                child: const Text(
                  'Create Event',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.1),
                      Colors.deepPurple.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(
                      Icons.event_available,
                      color: Colors.deepPurple,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content with Modern, Minimalist Design
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Event Type Selector with Modern Design
                FadeInUp(
                  child: const Text(
                    'Event Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _eventTypes.map((type) {
                      bool isSelected = _selectedEventType == type['name'];
                      return FadeInRight(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEventType = type['name'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  type['icon'],
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 25),

                // Date Picker with Modern Touch
                FadeInUp(
                  child: const Text(
                    'Event Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                FadeInRight(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('EEEE, MMM d, yyyy')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Title Input with Modern Styling
                FadeInUp(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Event Title',
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      prefixIcon: const Icon(Icons.title_outlined,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                FadeInUp(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      prefixIcon: const Icon(Icons.location_pin,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Description Input with Modern Touch
                FadeInUp(
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Event Description',
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      prefixIcon: const Icon(Icons.description_outlined,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Create Event Button with Modern Styling
                FadeInUp(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _createEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.deepPurple.withOpacity(0.4),
                          ),
                          child: const Text(
                            'Create Event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
