class BibleVerse {
  String? reference;
  List<Verses>? verses;
  String? text;
  String? translationId;
  String? translationName;
  String? translationNote;

  BibleVerse(
      {this.reference,
      this.verses,
      this.text,
      this.translationId,
      this.translationName,
      this.translationNote});

  BibleVerse.fromJson(Map<String, dynamic> json) {
    if (json["reference"] is String) {
      reference = json["reference"];
    }
    if (json["verses"] is List) {
      verses = json["verses"] == null
          ? null
          : (json["verses"] as List).map((e) => Verses.fromJson(e)).toList();
    }
    if (json["text"] is String) {
      text = json["text"];
    }
    if (json["translation_id"] is String) {
      translationId = json["translation_id"];
    }
    if (json["translation_name"] is String) {
      translationName = json["translation_name"];
    }
    if (json["translation_note"] is String) {
      translationNote = json["translation_note"];
    }
  }

  static List<BibleVerse> fromList(List<Map<String, dynamic>> list) {
    return list.map(BibleVerse.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["reference"] = reference;
    if (verses != null) {
      data["verses"] = verses?.map((e) => e.toJson()).toList();
    }
    data["text"] = text;
    data["translation_id"] = translationId;
    data["translation_name"] = translationName;
    data["translation_note"] = translationNote;
    return data;
  }
}

class Verses {
  String? bookId;
  String? bookName;
  int? chapter;
  int? verse;
  String? text;

  Verses({this.bookId, this.bookName, this.chapter, this.verse, this.text});

  Verses.fromJson(Map<String, dynamic> json) {
    if (json["book_id"] is String) {
      bookId = json["book_id"];
    }
    if (json["book_name"] is String) {
      bookName = json["book_name"];
    }
    if (json["chapter"] is int) {
      chapter = json["chapter"];
    }
    if (json["verse"] is int) {
      verse = json["verse"];
    }
    if (json["text"] is String) {
      text = json["text"];
    }
  }

  static List<Verses> fromList(List<Map<String, dynamic>> list) {
    return list.map(Verses.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["book_id"] = bookId;
    data["book_name"] = bookName;
    data["chapter"] = chapter;
    data["verse"] = verse;
    data["text"] = text;
    return data;
  }
}
