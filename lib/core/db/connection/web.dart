// ignore_for_file: experimental_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  return WebDatabase('diary');
}
