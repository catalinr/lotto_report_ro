# lotto_report_ro

`Flutter`/`Dart` app.

Extract the report for each lotto game and send a notification whenever it is
over a threshold, as a reminder.

## Implementation

Every day with a draw (which are `Th` and `Su` for our lottery), a background `task`
runs in a separate `isolate` (uses `workmanager`), gets the reports for each lotto
game, and sends `flutter_local_notifications` for any of them that are above the
threshold.

## Online resources

https://www.loto.ro
