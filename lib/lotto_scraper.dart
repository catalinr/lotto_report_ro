import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class ScrapingException implements Exception {
  final String message;
  final String? details;

  ScrapingException(this.message, [this.details]);

  @override
  String toString() {
    return details == null ? message : '$message: $details';
  }
}

class LottoScraper {
  final Map<String, String> reports = {};
  final Map<String, String> bigReports = {};

  Future<void> scrapeReports(double minvalue) async {
    reports.clear();
    bigReports.clear();

    try {
      // Ping test
      final response = await http.get(Uri.parse('https://www.loto.ro/'));
      if (response.statusCode != 200) {
        throw ScrapingException(
          'Failed to fetch data.',
          response.reasonPhrase ?? 'HTTP status code ${response.statusCode}.',
        );
      }
      final text = html.parse(response.body).body!.text;

      _extractReport(text, 'LOTO 6/49', 'REPORT LOTO 6/49', minvalue);
      _extractReport(text, 'LOTO 5/40', 'REPORT LOTO 5/40', minvalue);
      _extractReport(text, 'JOKER', 'REPORT JOKER', minvalue);
    } catch (e) {
      throw ScrapingException('Failed to extract reports.', e.toString());
    }
  }

  void _extractReport(
    String text,
    String gameName,
    String title,
    double minValue,
  ) {
    // Extract string value
    int nameStart = text.indexOf(gameName);
    if (nameStart == -1) return;

    int labelStart = text.indexOf('REPORTURI', nameStart);
    if (labelStart == -1) return;
    int valueStart = labelStart + 'REPORTURI'.length;

    int valueEnd = text.indexOf('#', valueStart);
    if (valueEnd == -1) return;

    String textIntValue = text.substring(valueStart, valueEnd);
    double numericValue = 0;
    if (textIntValue == '-') {
      // no report is expressed by "-"
      textIntValue = '0';
    } else {
      textIntValue = textIntValue.split(',').first.replaceAll('.', ' ');
      // Extract numeric value
      final numericString = textIntValue.replaceAll(' ', '');
      numericValue = double.parse(numericString);
    }

    reports[title] = textIntValue;
    if (numericValue >= minValue) {
      bigReports[title] = textIntValue;
    }
  }
}
