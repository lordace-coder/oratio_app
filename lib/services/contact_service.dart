import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hive/hive.dart';
import 'package:oratio_app/networkProvider/contact_requests.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/models/contact_model.dart';

class ContactService {
  Future initialize() async {
    Hive.registerAdapter(ContactModelAdapter()); // Ensure this is called only once
    var exists = await Hive.boxExists("contacts");
    if (exists) {
      Hive.box("contacts");
    }
  }

  Future<List<Map<String, String>>?> getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      final List<Map<String, String>> contactDetails = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) => {
                'name': contact.displayName,
                'phone': contact.phones.first.number,
              })
          .toList();
      return contactDetails;
    } else {
      print("no permission");
    }
    return null;
  }

  Future<void> checkContacts(BuildContext context) async {
    final contacts = await getContacts();
    if (contacts != null) {
      final contactStrings =
          contacts.map((contact) => contact['phone']!).toList();
      final results = await getContactsOnApp(
          getPocketBaseFromContext(context), contactStrings);
      final box = await Hive.openBox('contacts');
      await box.put('contactsOnApp', results);
    }
  }

  Future<List<ContactModel>> getContactsOnAppFromHive() async {
    final box = await Hive.openBox('contacts');
    return box.get('contactsOnApp', defaultValue: <ContactModel>[]);
  }

  static Future<Contact?> openDeviceContactPicker() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.openExternalPick();
    }
    return null;
  }

}
