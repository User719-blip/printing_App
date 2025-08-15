import 'package:flutter/material.dart';
import 'package:printing_app/core/theme/apppaleet.dart';
import 'package:printing_app/home/domain/entity/print_entity.dart';

class FilePreview extends StatelessWidget {
  final PrintFileEntity file;
  final VoidCallback onRemove;
  
  const FilePreview({
    super.key,
    required this.file,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppPalette.darkGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildFileIcon(),
        title: Text(
          file.name,
          style: const TextStyle(color: AppPalette.whiteText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${file.extension.toUpperCase()} · ${_formatFileDate(file.addedAt)}',
          style: TextStyle(color: AppPalette.grayText, fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: AppPalette.grayText),
          onPressed: onRemove,
          iconSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildFileIcon() {
    IconData iconData;
    Color iconColor;
    
    if (file.isPdf) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (file.isDocx) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else if (file.isTxt) {
      iconData = Icons.text_snippet;
      iconColor = Colors.amber;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = AppPalette.lightGrayText;
    }
    
    return Icon(iconData, color: iconColor, size: 32);
  }
  
  String _formatFileDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}