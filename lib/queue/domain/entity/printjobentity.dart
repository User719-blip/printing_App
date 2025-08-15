class PrintJobEntity {
  final String id;
  final String fileName;
  final String fileUrl;
  final int copies;
  final PrintJobStatus status;
  final DateTime createdAt;
  final int queuePosition;
  
  const PrintJobEntity({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.copies,
    required this.status,
    required this.createdAt,
    required this.queuePosition,
  });

  PrintJobEntity copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    int? copies,
    PrintJobStatus? status,
    DateTime? createdAt,
    int? queuePosition,
  }) {
    return PrintJobEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      copies: copies ?? this.copies,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      queuePosition: queuePosition ?? this.queuePosition,
    );
  }
}

enum PrintJobStatus {
  pending,
  printing,
  completed,
  failed,
  canceled
}

extension PrintJobStatusExtension on PrintJobStatus {
  String get displayName {
    switch (this) {
      case PrintJobStatus.pending: return 'Pending';
      case PrintJobStatus.printing: return 'Printing';
      case PrintJobStatus.completed: return 'Completed';
      case PrintJobStatus.failed: return 'Failed';
      case PrintJobStatus.canceled: return 'Canceled';
    }
  }
}