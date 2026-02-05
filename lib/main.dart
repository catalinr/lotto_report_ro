import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:lotto_report_ro/lotto_reports_home_page.dart';
import 'package:lotto_report_ro/lotto_scraper.dart';
import 'package:lotto_report_ro/notification_helper.dart';

const double minJackpotValue = 5000000;
const taskName = "lotto-report-scraper";
const taskTag = "lottoReportScraper";

@pragma('vm:entry-point')
void backgroundTaskEntryPoint() {
  Workmanager().executeTask((task, inputData) async {
    // This is the real entry point for the background task
    WidgetsFlutterBinding.ensureInitialized();

    Duration delay = const Duration(minutes: 15);
    final scraper = LottoScraper();
    try {
      await scraper.scrapeReports(minJackpotValue);
      await NotificationHelper.sendNotificationsFromBackground(
        scraper.bigReports,
      );
      delay = _calculateNextDelay();
    } on ScrapingException catch (_) {
      // Do nothing, thus re-schedule 15 minutes from now.
    }

    // Reschedule the next task
    scheduleNextTask(delay);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    // Init notification infrastructure so that necessary permission can be requested
    NotificationHelper.ensureInitialized();
    // Init background task infrastructure
    await Workmanager().initialize(backgroundTaskEntryPoint);
    //scheduleNextTask(const Duration(minutes: 15));
    scheduleNextTask(_calculateNextDelay());
  }

  runApp(const MyApp());
}

void scheduleNextTask(Duration delay) {
  Workmanager().registerOneOffTask(
    taskName,
    taskTag,
    initialDelay: delay,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    inputData: <String, dynamic>{},
  );
}

Duration _calculateNextDelay() {
  final now = DateTime.now();
  // Target time is 09:00 on Thursday and Sunday
  var nextRun = DateTime(now.year, now.month, now.day, 9, 0);

  while (nextRun.isBefore(now) ||
      (nextRun.weekday != DateTime.thursday &&
          nextRun.weekday != DateTime.sunday)) {
    nextRun = nextRun.add(const Duration(days: 1));
  }
  return nextRun.difference(now);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotto Reports',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LottoReportsHomePage(
        title: 'Lotto Reports',
        minJackpotValue: minJackpotValue,
      ),
    );
  }
}
