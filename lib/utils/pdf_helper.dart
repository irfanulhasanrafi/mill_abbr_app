import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/abbreviation.dart';

class PdfHelper {
  static Future<void> saveFavoritesToPdf(List<Abbreviation> favorites) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: favorites.map((abbr) {
              return pw.Text('${abbr.abbr} : ${abbr.fullForm}');
            }).toList(),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/mill_abbr_favorites.pdf');
    await file.writeAsBytes(bytes);
  }
}
