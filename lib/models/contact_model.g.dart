// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactModelAdapter extends TypeAdapter<ContactModel> {
  @override
  final int typeId = 1;

  @override
  ContactModel read(BinaryReader reader) {
    return ContactModel(
      id: reader.readString(),
      username: reader.readString(),
      avatar: reader.readString(),
      firstName: reader.readString(),
      lastName: reader.readString(),
      phoneNumber: reader.readString(),
      priest: reader.readBool(),
      staff: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ContactModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.avatar);
    writer.writeString(obj.firstName);
    writer.writeString(obj.lastName);
    writer.writeString(obj.phoneNumber);
    writer.writeBool(obj.priest);
    writer.writeBool(obj.staff);
  }
}
