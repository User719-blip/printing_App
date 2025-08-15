class PrintFileEntity {
  final String path;
  final String name;
  final String extension;
  final DateTime addedAt;
  final List<int>? bytes; // Store file bytes for web
  
  const PrintFileEntity({
    required this.path,
    required this.name,
    required this.extension,
    required this.addedAt,
    this.bytes,
  });
  
  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isDocx => extension.toLowerCase() == 'docx';
  bool get isTxt => extension.toLowerCase() == 'txt';
  
  // For web platform
  bool get hasBytes => bytes != null && bytes!.isNotEmpty;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintFileEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          addedAt == other.addedAt;

  @override
  int get hashCode => name.hashCode ^ addedAt.hashCode;
}