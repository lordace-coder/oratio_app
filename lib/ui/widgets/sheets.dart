import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/booking_bloc/state.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/pages/pages.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';
import 'package:oratio_app/ui/widgets/payment_proof.dart';
import 'package:pocketbase/pocketbase.dart';

class MassBookBottomSheet extends StatefulWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final ScrollController scrollController;
  final MassBookingData data;

  const MassBookBottomSheet({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scrollController,
    required this.data,
  });

  @override
  State<MassBookBottomSheet> createState() => _MassBookBottomSheetState();
}

class _MassBookBottomSheetState extends State<MassBookBottomSheet> {
  RecordModel? payment_proof;

  ///used to track if the user wants mass booking option or not
  bool anonymous = false;
  final TextEditingController intention = TextEditingController();

  List<RecordModel> selectedUsers = [];
  bool isDonating = false;
  bool isBooking = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),
          const Text(
            'Book Mass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          _buildWarningBox(),
          const Gap(20),
          _buildTextField(
            controller: intention,
            label: 'Intention',
            hint: 'Describe the intention why you are booking the mass',
          ),
          const Gap(16),
          _buildUserSelection(),
          // check for anonymous option
          StatefulBuilder(builder: (context, rebuild) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Tooltip(
                      message:
                          "Turn this on to hide your information during mass booking.",
                      child: Row(
                        children: [
                          const Text("Go Anonymous"),
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(99)),
                            child: const Icon(
                              Icons.question_mark_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                    value: anonymous,
                    onChanged: (val) {
                      rebuild(() {
                        anonymous = val;
                      });
                    })
              ],
            );
          }),

          const Gap(24),
          if (payment_proof != null) _buildSuccessMessage(),
          const Gap(20),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            color: AppColors.warning,
            size: 16,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'Please read carefully before answering',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFieldd(
        inputTextStyle: const TextStyle(color: Colors.black),
        labeltext: label,
        labelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        hintText: hint,
        controller: controller,
        isPassword: false,
      ),
    );
  }

  Widget _buildUserSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Names of attendees',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(8),
                InkWell(
                  onTap: () => _showUserSelectionDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.userPlus,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const Gap(8),
                        Text(
                          'Add Attendees',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedUsers.map((user) {
                  return Chip(
                    label: Text(
                        "${user.data['first_name']} ${user.data['last_name']}"),
                    onDeleted: () {
                      setState(() {
                        selectedUsers.remove(user);
                      });
                    },
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showUserSelectionDialog() async {
    final result = await showDialog<List<RecordModel>>(
      context: context,
      builder: (context) => UserSelectionDialog(
        selectedUsers: selectedUsers,
      ),
    );
    if (result != null) {
      setState(() {
        selectedUsers = result;
      });
    }
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.solidCircleCheck,
            color: AppColors.green,
            size: 16,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'God bless you for that gracious donation',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    return Column(
      children: [
        SubmitButtonV1(
          ontap: isDonating
              ? null
              : () async {
                  setState(() => isDonating = true);
                  try {
                    final RecordModel? payment = await getPaymentProof(context);
                    if (payment == null) {
                      setState(() => isDonating = false);
                    } else {
                      showSuccess(context,
                          message: 'Proof of payment submitted succesfully');
                      payment_proof = payment;
                      setState(() => isDonating = false);
                    }
                    return;
                  } catch (e) {
                    setState(() => isDonating = false);
                    print(
                        [(e as DioException).response, e.requestOptions.data]);
                    return showError(context, message: 'Error occurred $e');
                  }
                },
          radius: 12,
          backgroundcolor: isDonating
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDonating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    FontAwesomeIcons.handHoldingHeart,
                    color: Colors.white,
                    size: 16,
                  ),
                const Gap(8),
                Text(
                  isDonating ? 'Processing...' : 'Stypends',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        SubmitButtonV1(
          ontap: (isBooking || payment_proof == null)
              ? null
              : () async {
                  setState(() => isBooking = true);
                  try {
                    final userId = pb.authStore.model.id;
                    if (payment_proof != null) {
                      // validate form fields
                      if (intention.text.isEmpty) {
                        setState(() {
                          isBooking = false;
                        });
                        return showError(context,
                            message: 'Mass Intention cant be empty');
                      }

                      // Create booking records for each selected date
                      try {
                        for (DateTime date in widget.data.selectedDates) {
                          // Combine date with selected times
                          final startDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            widget.data.fromTime!.hour,
                            widget.data.fromTime!.minute,
                          );

                          final endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            widget.data.finishTime!.hour,
                            widget.data.finishTime!.minute,
                          );

                          final res =
                              await pb.collection("mass_booking").create(body: {
                            "startTime": startDateTime.toIso8601String(),
                            "endTime": endDateTime.toIso8601String(),
                            "parish": widget.data.selectedChurch.id,
                            "intention": intention.text.trim(),
                            "attendees":
                                selectedUsers.map((u) => u.id).toList(),
                            "user": userId,
                            "payment": payment_proof?.id,
                            "anonymous": anonymous,
                          });

                          // Store the first booking ID for success page
                          if (date == widget.data.selectedDates.first) {
                            showSuccess(context,
                                message: 'Mass Booking completed successfully');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentSuccesful(
                                  bookingData: widget.data,
                                  bookingId: res.id,
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        final err = e as ClientException;
                        print(e);
                        showError(context,
                            message:
                                'Error occurred ${err.response['message']}');
                      }
                    }
                    setState(() => isBooking = false);
                  } catch (e) {
                    setState(() => isBooking = false);
                    final err = e as ClientException;
                    print(e);
                    showError(context,
                        message: 'Error occurred ${err.response['message']}');
                  }
                },
          radius: 12,
          backgroundcolor: isBooking || payment_proof == null
              ? AppColors.greenDisabled
              : AppColors.green,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isBooking)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    FontAwesomeIcons.calendar,
                    color: Colors.white,
                    size: 16,
                  ),
                const Gap(8),
                Text(
                  isBooking ? 'Processing...' : 'Book Mass',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserSelectionDialog extends StatefulWidget {
  final List<RecordModel> selectedUsers;

  const UserSelectionDialog({
    super.key,
    required this.selectedUsers,
  });

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<RecordModel> selectedUsers = [];
  List<RecordModel> filteredUsers = [];
  List<RecordModel> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedUsers = List.from(widget.selectedUsers);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final users = await pb.collection('users').getFullList(
            fields: "first_name,last_name,username,id",
            filter: "followers~'${pb.authStore.model.id}'",
          );

      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showError(context, message: 'Failed to load users: ${e.toString()}');
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = allUsers;
      });
      return;
    }

    setState(() {
      filteredUsers = allUsers.where((user) {
        final name = "${user.data['first_name']} ${user.data['last_name']}"
            .toLowerCase();
        final username = (user.data['username'] ?? '').toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || username.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterUsers,
            ),
            const Gap(16),
            SizedBox(
              height: 300,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isSelected = selectedUsers
                                .any((selected) => selected.id == user.id);
                            print([selectedUsers, isSelected]);
                            return CheckboxListTile(
                              title: Text(
                                  "${user.data['first_name']} ${user.data['last_name']}"),
                              subtitle: Text(user.data['username'] ?? ''),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    if (!isSelected) {
                                      selectedUsers.add(user);
                                    }
                                  } else {
                                    selectedUsers.removeWhere(
                                        (selected) => selected.id == user.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedUsers),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
