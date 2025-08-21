import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/services/contact_service.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/models/contact_model.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shimmer/shimmer.dart';

class ContactsPage extends StatelessWidget {
  ContactsPage({super.key});
  final TextEditingController _searchController = TextEditingController();



  final ContactService _contactService = ContactService();

  Future<void> _retryFetchContacts(BuildContext context) async {
    await _contactService.checkContacts(context);
  }

  @override
  Widget build(BuildContext context) {
    _contactService.checkContacts(context);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // SEARCH BAR
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.arrow_back)),
                const Text(
                  "Contacts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            _buildCustomInput(
                controller: _searchController,
                hint: "search name or number",
                icon: Icons.search),
            const SizedBox(
              height: 20,
            ),
            // Combine both sections into a single ListView
            Expanded(
              child: ListView(
                children: [
                  FutureBuilder<List<ContactModel>>(
                    future: _contactService.getContactsOnAppFromHive(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmer();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Error fetching contacts"),
                              ElevatedButton(
                                onPressed: () => _retryFetchContacts(context),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox();
                      } else {
                        final contactsOnApp = snapshot.data!;
                        return Column(
                          children: contactsOnApp.map((contact) {
                            return ListTile(
                              trailing: ElevatedButton(
                                  onPressed: () {
                                    context.pushNamed(RouteNames.chatDetailPage,
                                        pathParameters: {
                                          "profile": Profile(
                                                  userId: contact.id,
                                                  community: [],
                                                  parish: [],
                                                  user: RecordModel.fromJson(
                                                      contact.toJson()),
                                                  contact: contact.phoneNumber)
                                              .toJsonString()
                                        });
                                  },
                                  child: const Text("Message")),
                              title: Text(
                                  '${contact.firstName} ${contact.lastName}'),
                              subtitle: Text(contact.phoneNumber),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<Map<String, String>>?>(
                    future: _contactService.getContacts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmer();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Error fetching contacts"),
                              ElevatedButton(
                                onPressed: () => _retryFetchContacts(context),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No contacts found"));
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(6, (index) {
          return ListTile(
            title: Container(
              width: double.infinity,
              height: 10.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 10.0,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black38)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textDarkDim),
          prefixIcon: Icon(icon, color: AppColors.gray),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
