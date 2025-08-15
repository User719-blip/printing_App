// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing_app/core/theme/apppaleet.dart';
import 'package:printing_app/home/data/repo/print_repo_impl.dart';
import 'package:printing_app/home/presentation/bloc/file_bloc.dart';
import 'package:printing_app/home/presentation/widgets/card_widget.dart';
import 'package:printing_app/home/presentation/widgets/plus_widget.dart';
import 'package:printing_app/home/presentation/widgets/print_dialoge.dart';
import 'dart:ui';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _copiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

 void _showPrintDialog() {
  showDialog(
    context: context,
    barrierColor: Colors.transparent, // Make barrier transparent to see blur
    builder: (BuildContext context) {
      return BlocProvider(
        create: (context) => FileBloc(
          fileRepository: FileRepositoryImpl(),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3), // Overlay color
            child: PrintDialog(
              animation: _animation,
              copiesController: _copiesController,
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Welcome text - centered and bigger
              Center(
                child: const Text(
                  'Welcome',
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 64,
                    color: AppPalette.whiteText,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Instructions card
              InstructionsCard(animation: _animation),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: PlusWidget(
        animation: _animation,
        onPressed: _showPrintDialog,
      ),
    );
  }
}