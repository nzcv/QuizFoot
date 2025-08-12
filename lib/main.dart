import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/quiz_test.dart';
import 'pages/result_page.dart';
import 'pages/history_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Football',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/quiz_test': (context) => const QuizTest(),
        '/result_page': (context) => const ResultPage(score: 0),
        '/history_page': (context) => const HistoryPage(),
      },
    );
  }
}