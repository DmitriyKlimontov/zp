import 'package:flutter/material.dart';
import 'package:zp/pages/home.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zp/services/work_calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  await DatabaseHelper()
      .database; // инициализация и создание таблиц при первом запуске
  await AppPrefsService.instance.init(); // инициализация настроек
  await WorkCalendar.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расчёт зарплаты',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Расчёт зарплаты'),
    );
  }
}
