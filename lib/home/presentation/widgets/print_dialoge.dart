import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing_app/core/theme/apppaleet.dart';
import 'package:printing_app/home/presentation/widgets/file_preview_widget.dart';
import 'package:printing_app/queue/data/repo/queue_repo_impl.dart';
import 'package:printing_app/queue/data/usercases/queue_usecase.dart';
import 'package:printing_app/queue/presentation/bloc/queue_bloc.dart';
import 'package:printing_app/queue/presentation/bloc/queue_event.dart';
import 'package:printing_app/queue/presentation/bloc/queue_state.dart';
import 'package:printing_app/queue/presentation/pages/queue_page.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_event.dart';
import '../bloc/file_state.dart';

class PrintDialog extends StatefulWidget {
  final Animation<double> animation;
  final TextEditingController copiesController;

  const PrintDialog({
    super.key,
    required this.animation,
    required this.copiesController,
  });

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPalette.transparent,
      child: Container(
        width: 300,
        height: 500, // Increased height for file previews
        decoration: BoxDecoration(
          color: AppPalette.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Print Documents',
                style: TextStyle(
                  color: AppPalette.whiteText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              // File upload area
              InkWell(
                onTap: () {
                  context.read<FileBloc>().add(FilePickRequested());
                },
                child: Container(
                  width: double.infinity,
                  height: 100, // Reduced height
                  decoration: BoxDecoration(
                    color: AppPalette.darkGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppPalette.borderColor,
                      width: 1,
                     ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 32,
                        color: AppPalette.lightGrayText,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your files\n(PDF, DOCX, TXT)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppPalette.grayText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              Text(
                'Selected Files',
                style: TextStyle(
                  color: AppPalette.whiteText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              
              // File previews
              Expanded(
                child: BlocBuilder<FileBloc, FileState>(
                  builder: (context, state) {
                    if (state is FileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppPalette.pink,
                        ),
                      );
                    } else if (state is FileError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is FileLoaded && state.files.isNotEmpty) {
                      return ListView.builder(
                        itemCount: state.files.length,
                        itemBuilder: (context, index) {
                          return FilePreview(
                            file: state.files[index],
                            onRemove: () => context.read<FileBloc>().add(FileRemoved(index)),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No files selected',
                          style: TextStyle(color: AppPalette.grayText),
                        ),
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 10),

              // Number of copies text field
              TextField(
                controller: widget.copiesController,
                style: const TextStyle(color: AppPalette.whiteText),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    int? copies = int.tryParse(value);
                    if (copies != null && copies > 10) {
                      widget.copiesController.text = "10";
                      widget.copiesController.selection = TextSelection.fromPosition(
                        TextPosition(offset: 2),
                      );
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter number of copies (1-10)',
                  hintStyle: TextStyle(
                    color: AppPalette.grayText,
                  ),
                  filled: true,
                  fillColor: AppPalette.darkGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppPalette.borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppPalette.borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppPalette.pink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Animated Print button
              AnimatedBuilder(
                animation: widget.animation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: SweepGradient(
                        center: Alignment.center,
                        startAngle: widget.animation.value * 2 * 3.14159,
                        colors: AppPalette.sweepGradient,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppPalette.black,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final state = context.read<FileBloc>().state;
                          if (state is! FileLoaded || state.files.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select at least one file'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // Get copies (with validation)
                          int copies = 1;
                          if (widget.copiesController.text.isNotEmpty) {
                            copies = int.tryParse(widget.copiesController.text) ?? 1;
                            copies = copies.clamp(1, 10); // Ensure between 1-10
                          }
                          
                          // Close dialog
                          Navigator.of(context).pop();
                          
                          // Submit the first file to the print queue
                          if (state.files.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => QueueBloc(
                                    submitPrintJobUseCase: SubmitPrintJobUseCase(
                                      QueueRepositoryImpl(),
                                    ),
                                    getJobUpdatesUseCase: GetJobUpdatesUseCase(
                                      QueueRepositoryImpl(),
                                    ),
                                    cancelPrintJobUseCase: CancelPrintJobUseCase(
                                      QueueRepositoryImpl(),
                                    ),
                                  )..add(SubmitPrintJobEvent(
                                    file: state.files.first,
                                    copies: copies,
                                  )),
                                  child: BlocConsumer<QueueBloc, QueueState>(
                                    listenWhen: (previous, current) {
                                      // Only react when transitioning to QueueSubmitted state
                                      return current is QueueSubmitted && previous is! QueueSubmitted;
                                    },
                                    listener: (context, state) {
                                      if (state is QueueSubmitted) {
                                        print('Navigating to queue tracking page with job ID: ${state.job.id}');
                                        // Navigate to tracking page without rebuilding the entire screen
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => QueueTrackingPage(jobId: state.job.id),
                                          ),
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      // This will build the initial loading screen but won't rebuild
                                      // once we navigate to the QueueTrackingPage
                                      if (state is QueueError) {
                                        return Scaffold(
                                          backgroundColor: AppPalette.black,
                                          appBar: AppBar(
                                            backgroundColor: AppPalette.transparent,
                                            elevation: 0,
                                            iconTheme: const IconThemeData(color: AppPalette.whiteText),
                                            title: const Text(
                                              'Error',
                                              style: TextStyle(color: AppPalette.whiteText),
                                            ),
                                          ),
                                          body: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 64,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Text(
                                                    state.message,
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 32),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Go Back'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Scaffold(
                                          backgroundColor: AppPalette.black,
                                          body: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const CircularProgressIndicator(
                                                  color: AppPalette.pink,
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  'Submitting print job...',
                                                  style: TextStyle(
                                                    color: AppPalette.whiteText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          // Clear files
                          context.read<FileBloc>().add(AllFilesCleared());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.transparent,
                          shadowColor: AppPalette.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        child: const Text(
                          'PRINT',
                          style: TextStyle(
                            color: AppPalette.whiteText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}