import 'package:flutter/foundation.dart';
import 'package:printing_app/core/errors/erros_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing_app/core/errors/erros_core.dart' as core_errors;

class SupabaseService {
  static const String _url = 'https://yfsubvpbrzuydmexscmy.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlmc3VidnBicnp1eWRtZXhzY215Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MTMxNjgsImV4cCI6MjA3MDQ4OTE2OH0.UXxx0GrFF0ove71w9CuK_q-mgQHeTAK8-L-EJwCWhy4';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  // Get a unique device ID for anonymous users
  static Future<String> getDeviceId() async {
    // Use flutter_secure_storage or shared_preferences to store device ID
    // For simplicity, using a UUID from the client session
    final String clientId = client.auth.currentSession?.accessToken ?? DateTime.now().millisecondsSinceEpoch.toString();
    return clientId;
  }
  
  // Upload a file to Supabase storage
  static Future<String> uploadFile(List<int> fileBytes, String fileName) async {
    try {
      final deviceId = await getDeviceId();
      final String filePath = 'public/$deviceId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      // ignore: unused_local_variable
      final String response = await client.storage.from('print_files').uploadBinary(
        filePath,
        Uint8List.fromList(fileBytes),
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );
      
      // If uploadBinary throws, it will be caught by the catch block below.
      // Otherwise, response is the file path.
      final String fileUrl = client.storage.from('print_files').getPublicUrl(filePath);
      return fileUrl;
    } catch (e, stackTrace) {
      if (e is core_errors.StorageException) rethrow;
      
      throw core_errors.StorageException(
        message: 'File upload failed: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  // Create a print job in the queue
  static Future<Map<String, dynamic>> createPrintJob({
    required String fileName,
    required String fileUrl,
    required int copies,
  }) async {
    try {
      final deviceId = await getDeviceId();
      
      final response = await client.from('print_jobs').insert({
        'device_id': deviceId,
        'file_name': fileName,
        'file_url': fileUrl,
        'copies': copies,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) {
        throw QueueException(
          message: 'Failed to create print job: No data returned',
        );
      }

      return response.first;
    } catch (e, stackTrace) {
      if (e is QueueException) rethrow;
      
      throw QueueException(
        message: 'Create print job failed: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  // Get real-time updates for a job
  static Stream<Map<String, dynamic>> getJobUpdates(String jobId) {
    return client
      .from('print_jobs')
      .stream(primaryKey: ['id'])
      .eq('id', jobId)
      .map((event) {
        if (event.isEmpty) {
          throw QueueException(message: 'Job not found');
        }
        return event.first;
      });
  }
  
  // Get the position in queue
  static Future<int> getQueuePosition(String jobId) async {
    try {
       print('Getting queue position for job: $jobId');
      // Count pending jobs created before this job
      
    try {
      final response = await client.rpc('get_queue_position', params: {'job_id': jobId});
      
      if (response is Map && response.containsKey('error') && response['error'] != null) {
         print('Error in response: ${response['error']}');
        throw QueueException(
          message: 'Failed to get queue position: ${response['error']}',
          code: 'RPC_ERROR',
        );
      }

      if (response is int) {
        print('Queue position: $response');
        return response;
      }
      
     final position = int.tryParse(response.toString()) ?? 1;
      print('Queue position (parsed): $position');
      return position;
  } catch(e) {
    print('RPC call error: $e');
    return 1;
  }
    } catch (e, stackTrace) {
      if (e is QueueException) rethrow;
      
      throw QueueException(
        message: 'Get queue position failed: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  // Cancel a print job
  static Future<void> cancelPrintJob(String jobId) async {
    try {
      final response = await client
        .from('print_jobs')
        .update({'status': 'canceled'})
        .eq('id', jobId);
      
      if (response.error != null) {
        throw QueueException(
          message: 'Failed to cancel print job: ${response.error!.message}',
          code: response.error!.code,
        );
      }
    } catch (e, stackTrace) {
      if (e is QueueException) rethrow;
      
      throw QueueException(
        message: 'Cancel print job failed: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }
}