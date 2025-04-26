class Abbreviation {
  final String abbr;
  final String fullForm;

  Abbreviation({required this.abbr, required this.fullForm});

  factory Abbreviation.fromJson(Map<String, dynamic> json) {
    return Abbreviation(
      abbr: json['abbr'] ?? '',
      fullForm: json['Abbreviate'] ?? '',
    );
  }
}
