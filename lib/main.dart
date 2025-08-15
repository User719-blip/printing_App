import 'package:flutter/material.dart';
import 'package:printing_app/core/theme/theme.dart';
import 'package:printing_app/home/presentation/pages/home_page.dart';
import 'package:printing_app/queue/data/datasource/remote_datasource.dart';


void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Print Service',
      theme: AppTheme.lightTheme,
      home: const Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}