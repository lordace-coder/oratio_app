import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oratio_app/ui/themes.dart';

class PrayerCommunityCreationPage extends StatefulWidget {
  const PrayerCommunityCreationPage({super.key});

  @override
  _PrayerCommunityCreationPageState createState() =>
      _PrayerCommunityCreationPageState();
}

class _PrayerCommunityCreationPageState
    extends State<PrayerCommunityCreationPage> {
  final FocusNode _leaderSearchFocusNode = FocusNode();
  final FocusNode _communityNameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _leaderSearchController = TextEditingController();

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<Map<String, String>> _potentialLeaders = [
    {
      'name': 'Father Michael Rodriguez',
      'church': "St. Mary's Cathedral",
      'image': 'https://example.com/priest1.jpg'
    },
    {
      'name': 'Sister Elizabeth Grace',
      'church': 'Holy Spirit Parish',
      'image': 'https://example.com/sister1.jpg'
    },
    {
      'name': 'Deacon Thomas Wright',
      'church': 'Our Lady of Mercy',
      'image': 'https://example.com/deacon1.jpg'
    },
  ];

  List<Map<String, String>> _filteredLeaders = [];
  Map<String, String>? _selectedLeader;
  bool _showLeaderSearch = true;

  @override
  void initState() {
    super.initState();
    _filteredLeaders = _potentialLeaders;
    _leaderSearchController.addListener(_onLeaderSearchChange);
  }

  void _onLeaderSearchChange() {
    _filterLeaders(_leaderSearchController.text);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterLeaders(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLeaders = _potentialLeaders;
      });
      return;
    }

    setState(() {
      _filteredLeaders = _potentialLeaders
          .where((leader) =>
              leader['name']!.toLowerCase().contains(query.toLowerCase()) ||
              leader['church']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  bool _validateInputs() {
    if (_communityNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a community name');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackbar('Please provide a community description');
      return false;
    }

    if (_selectedImage == null) {
      _showErrorSnackbar('Please select a community image');
      return false;
    }

    if (_selectedLeader == null) {
      _showErrorSnackbar('Please select a community leader');
      return false;
    }

    return true;
  }

  void _createCommunity() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2));
        final data = _collectFormData();
        print('Community Data: $data');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Community created successfully!'),
            backgroundColor: AppColors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create community: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Map<String, dynamic> _collectFormData() {
    return {
      'communityName': _communityNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'leaderName': _selectedLeader?['name'],
      'leaderChurch': _selectedLeader?['church'],
      'communityImage': _selectedImage?.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Create Your Community',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Icon(
                    Icons.people_outline,
                    color: AppColors.textDim,
                    size: 100,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: _selectedImage != null
                          ? null
                          : AppColors.inputBoxGray,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.primary,
                                size: 60,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to add community photo',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_showLeaderSearch) ...[
                  _buildCustomInput(
                    controller: _leaderSearchController,
                    focusNode: _leaderSearchFocusNode,
                    hint: 'Find a Community Leader',
                    icon: Icons.search,
                    onChanged: _filterLeaders,
                  ),
                  if (_leaderSearchController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredLeaders.length,
                        itemBuilder: (context, index) {
                          final leader = _filteredLeaders[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(leader['image']!),
                            ),
                            title: Text(leader['name']!),
                            subtitle: Text(leader['church']!),
                            onTap: () {
                              setState(() {
                                _selectedLeader = leader;
                                _showLeaderSearch = false;
                                _leaderSearchController.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
                ] else if (_selectedLeader != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(_selectedLeader!['image']!),
                          radius: 25,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLeader!['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _selectedLeader!['church']!,
                                style: TextStyle(
                                  color: AppColors.textDarkDim,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedLeader = null;
                              _showLeaderSearch = true;
                            });
                          },
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),

                // Community Name Input
                _buildCustomInput(
                  controller: _communityNameController,
                  focusNode: _communityNameFocusNode,
                  hint: 'Community Name',
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 20),

                // Description Input
                _buildCustomInput(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  hint: 'Describe your community',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Leader Selection

                // Create Community Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createCommunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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
                          'Start Your Community',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildCustomInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBoxGray,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textDarkDim),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _leaderSearchFocusNode.dispose();
    _communityNameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _communityNameController.dispose();
    _descriptionController.dispose();
    _leaderSearchController.dispose();
    super.dispose();
  }
}
