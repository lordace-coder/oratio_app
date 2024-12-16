class BibleVerse {
  String? reference;
  List<Verses>? verses;
  String? text;
  String? translationId;
  String? translationName;
  String? translationNote;

  BibleVerse({
    this.reference,
    this.verses,
    this.text,
    this.translationId,
    this.translationName,
    this.translationNote,
  });

  BibleVerse.fromJson(Map<dynamic, dynamic> json) {
    reference = json["reference"]?.toString();
    if (json["verses"] is List) {
      verses = (json["verses"] as List)
          .map((e) => Verses.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    text = json["text"]?.toString();
    translationId = json["translation_id"]?.toString();
    translationName = json["translation_name"]?.toString();
    translationNote = json["translation_note"]?.toString();
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

  Verses({
    this.bookId,
    this.bookName,
    this.chapter,
    this.verse,
    this.text,
  });

  Verses.fromJson(Map<String, dynamic> json) {
    bookId = json["book_id"]?.toString();
    bookName = json["book_name"]?.toString();
    chapter = json["chapter"] is int
        ? json["chapter"]
        : int.tryParse(json["chapter"].toString());
    verse = json["verse"] is int
        ? json["verse"]
        : int.tryParse(json["verse"].toString());
    text = json["text"]?.toString();
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
