import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing_app/core/theme/apppaleet.dart';
import 'package:printing_app/queue/data/repo/queue_repo_impl.dart';
import 'package:printing_app/queue/data/usecases/queue_usecase.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';
import 'package:printing_app/queue/presentation/bloc/queue_bloc.dart';
import 'package:printing_app/queue/presentation/bloc/queue_event.dart';
import 'package:printing_app/queue/presentation/bloc/queue_state.dart';

class QueueTrackingPage extends StatefulWidget {
  final String jobId;

  const QueueTrackingPage({Key? key, required this.jobId}) : super(key: key);

  @override
  State<QueueTrackingPage> createState() => _QueueTrackingPageState();
}

class _QueueTrackingPageState extends State<QueueTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late QueueBloc _queueBloc;
  bool _isLocalBloc = false;

  @override
  void initState() {
    super.initState();

    // Try to get existing bloc or create a new one if not found
    try {
      _queueBloc = BlocProvider.of<QueueBloc>(context);
    } catch (e) {
      print('Creating new QueueBloc as none was found');
      _queueBloc = QueueBloc(
        submitPrintJobUseCase: SubmitPrintJobUseCase(QueueRepositoryImpl()),
        getJobUpdatesUseCase: GetJobUpdatesUseCase(QueueRepositoryImpl()),
        cancelPrintJobUseCase: CancelPrintJobUseCase(QueueRepositoryImpl()),
      );
      _isLocalBloc = true;
    }

    // Start tracking the job
    _queueBloc.add(TrackPrintJobEvent(widget.jobId));

    // Set up animation for completion checkmark
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    if (_isLocalBloc) {
      _queueBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _queueBloc,
      child: Scaffold(
        backgroundColor: AppPalette.black,
        appBar: AppBar(
          backgroundColor: AppPalette.transparent,
          elevation: 0,
          title: const Text(
            'Print Status',
            style: TextStyle(color: AppPalette.whiteText),
          ),
          iconTheme: const IconThemeData(color: AppPalette.whiteText),
        ),
        body: BlocConsumer<QueueBloc, QueueState>(
          listener: (context, state) {
            if (state is QueueTracking &&
                state.job.status == PrintJobStatus.completed) {
              _checkController.forward();
            }
          },
          builder: (context, state) {
            if (state is QueueTracking) {
              return _buildTrackingContent(state.job);
            } else if (state is QueueError) {
              return _buildErrorContent(state.message);
            } else {
              return const Center(
                child: CircularProgressIndicator(color: AppPalette.pink),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTrackingContent(PrintJobEntity job) {
    final status = job.status;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildStatusIcon(status),
            ),

            const SizedBox(height: 40),

            // Job name
            Text(
              job.fileName,
              style: const TextStyle(
                color: AppPalette.whiteText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Copies
            Text(
              '${job.copies} ${job.copies == 1 ? 'copy' : 'copies'}',
              style: TextStyle(color: AppPalette.grayText, fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Status message
            _buildStatusMessage(job),

            const SizedBox(height: 40),

            // Action button
            if (status == PrintJobStatus.pending)
              ElevatedButton(
                onPressed: () {
                  context.read<QueueBloc>().add(CancelPrintJobEvent(job.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel Print Job'),
              ),

            if (status == PrintJobStatus.completed ||
                status == PrintJobStatus.failed ||
                status == PrintJobStatus.canceled)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.darkGray,
                  foregroundColor: AppPalette.whiteText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Back to Home'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PrintJobStatus status) {
    switch (status) {
      case PrintJobStatus.pending:
        return Container(
          key: const ValueKey('queue'),
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.pink, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, color: AppPalette.pink, size: 40),
              const SizedBox(height: 8),
              Text(
                'In Queue',
                style: TextStyle(
                  color: AppPalette.whiteText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      case PrintJobStatus.printing:
        return Container(
          key: const ValueKey('printing'),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: const CircularProgressIndicator(
            color: Colors.blue,
            strokeWidth: 2,
          ),
        );

      case PrintJobStatus.completed:
        return ScaleTransition(
          scale: _checkAnimation,
          child: Container(
            key: const ValueKey('completed'),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 80),
          ),
        );

      case PrintJobStatus.failed:
        return Container(
          key: const ValueKey('failed'),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.2),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: const Icon(Icons.close, color: Colors.red, size: 80),
        );

      case PrintJobStatus.canceled:
        return Container(
          key: const ValueKey('canceled'),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.2),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: const Icon(Icons.cancel, color: Colors.orange, size: 80),
        );
    }
  }

  Widget _buildStatusMessage(PrintJobEntity job) {
    switch (job.status) {
      case PrintJobStatus.pending:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: AppPalette.whiteText, fontSize: 18),
            children: [
              const TextSpan(text: 'Your position in queue: '),
              TextSpan(
                text: '${job.queuePosition}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppPalette.pink,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        );

      case PrintJobStatus.printing:
        return const Text(
          'Your document is now printing...',
          style: TextStyle(color: AppPalette.whiteText, fontSize: 18),
          textAlign: TextAlign.center,
        );

      case PrintJobStatus.completed:
        return const Text(
          'Print job completed successfully!',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );

      case PrintJobStatus.failed:
        return const Text(
          'Print job failed. Please try again.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );

      case PrintJobStatus.canceled:
        return const Text(
          'Print job was canceled',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Error Tracking Print Job',
              style: TextStyle(
                color: AppPalette.whiteText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: AppPalette.grayText, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.darkGray,
                foregroundColor: AppPalette.whiteText,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
