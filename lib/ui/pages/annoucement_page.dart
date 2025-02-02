import 'package:flutter/material.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';

class AnnoucementPage extends StatefulWidget {
  const AnnoucementPage({super.key, required this.id});
  final String id;

  @override
  // ignore: library_private_types_in_public_api
  _AnnoucementPageState createState() => _AnnoucementPageState();
}

class _AnnoucementPageState extends State<AnnoucementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _announcementController = TextEditingController();
  bool _isLoading = false;

  void submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await sendAnnoucement(context, {
        "title": _titleController.text.trim(),
        "notification": _announcementController.text.trim(),
        "community": widget.id,
      });
      _titleController.clear();
      _announcementController.clear();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _announcementController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Announcement',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an announcement';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    buildGradientButton("Send Annoucement", Icons.send, submit),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _announcementController.dispose();
    super.dispose();
  }
}
