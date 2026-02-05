import 'package:flutter/material.dart';
import 'package:lotto_report_ro/lotto_scraper.dart';

class LottoReportsHomePage extends StatefulWidget {
  const LottoReportsHomePage({
    super.key,
    required this.title,
    required this.minJackpotValue,
  });

  final String title;
  final double minJackpotValue;

  @override
  State<LottoReportsHomePage> createState() => _LottoReportsHomePageState();
}

class _LottoReportsHomePageState extends State<LottoReportsHomePage> {
  Map<String, String> _allItems = {};
  Map<String, String> _highlightedItems = {};
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _getReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final scraper = LottoScraper();
    try {
      await scraper.scrapeReports(widget.minJackpotValue);
      setState(() {
        _allItems = scraper.reports;
        _highlightedItems = scraper.bigReports;
      });
    } on ScrapingException catch (e) {
      setState(() {
        _errorMessage =
            '${e.message}\nPlease check your internet connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _getReports,
              child: _allItems.isEmpty
                  ? ListView(
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('<drag to refresh>'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _allItems.length,
                      itemBuilder: (context, index) {
                        final key = _allItems.keys.elementAt(index);
                        final value = _allItems[key];
                        bool highlight = _highlightedItems.containsKey(key);

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              value ?? 'N/A',
                              style: highlight ? _getHighlightStyle() : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  TextStyle _getHighlightStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    );
  }
}
