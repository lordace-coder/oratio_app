import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? getAvatar(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    final user = pb.authStore.model as RecordModel;
    final avatarUrl =
        pb.getFileUrl(user, user.getStringValue('avatar')).toString();
    if (avatarUrl.isEmpty) {
      return null;
    }
    return avatarUrl;
  }

  Future<void> refreshProfileData() async {
    void initialInfo() {
      final user =
          getPocketBaseFromContext(context).authStore.model as RecordModel;
      _firstNameController.text = user.getStringValue('first_name');
      _lastNameController.text = user.getStringValue('last_name');
      _emailController.text = user.getStringValue('email');
      _phoneController.text = user.getStringValue('phone_number');
    }

    final pb = getPocketBaseFromContext(context);
    await pb.collection('users').authRefresh();
    initialInfo();
  }

  void submitData() async {
    try {
      final pb = getPocketBaseFromContext(context);
      final userId = pb.authStore.model.id;
      await pb.collection('users').update(
        userId,
        body: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text
        },
      );
      NotificationService.showSuccess('Profile updated Successfully');
      Navigator.pop(context);
    } catch (e) {
      NotificationService.showError('Error updating profile');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, requestFullMetadata: true);
    if (image != null) {
      final mimeType = lookupMimeType(image.path);
      if (mimeType == 'image/jpeg' || mimeType == 'image/png') {
        setState(() {
          _selectedImage = File(image.path);
        });
        final pb = getPocketBaseFromContext(context);
        final userId = pb.authStore.model.id;
        final bytes = await _selectedImage?.readAsBytes();

        await pb.collection('users').update(userId, files: [
          http.MultipartFile.fromBytes(
            'avatar',
            bytes as List<int>,
            filename: _selectedImage?.path,
          )
        ]);
      } else {
        NotificationService.showError(
            'Invalid image type. Only JPEG and PNG are allowed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    return FutureBuilder(
        future: refreshProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FilledButton(
                    onPressed: () {
                      submitData();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                image: getAvatar(context) != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            getAvatar(context)!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                            child: getAvatar(context) == null
                                ? const Center(
                                    child: Icon(Icons.person_outline,
                                        size: 80, color: Colors.grey),
                                  )
                                : null),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Your Personal Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildInputField(
                          controller: _firstNameController,
                          label: 'First Name',
                          hint: 'Enter your first name',
                        ),
                        _buildInputField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          hint: 'Enter your last name',
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Authentication',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            try {
                              await pb.collection('users').requestPasswordReset(
                                  (pb.authStore.model as RecordModel)
                                      .getStringValue('email'));
                              NotificationService.showSuccess(
                                  'A password reset link was sent to your email',
                                  duration: const Duration(seconds: 6));
                            } catch (error) {
                              NotificationService.showError(
                                  'Password reset failed');
                            }
                          },
                          child: const Text(
                            'Click to change your password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if ((pb.authStore.model as RecordModel)
                                .getBoolValue('verified') ==
                            false)
                          InkWell(
                            onTap: () {
                              try {
                                pb.collection('users').requestVerification(
                                    (pb.authStore.model as RecordModel)
                                        .getStringValue('email'));
                                NotificationService.showSuccess(
                                    'Verification Link Sent. Check your email or spam section',
                                    duration: const Duration(seconds: 6));
                              } catch (error) {
                                NotificationService.showError(
                                    'Verification failed. Ensure you have a correct email');
                              }
                            },
                            child: const Text(
                              'Click to verify your email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: Colors.black,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black.withOpacity(0.7),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 17,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
