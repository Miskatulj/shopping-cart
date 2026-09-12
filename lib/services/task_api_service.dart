import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/task.dart';

class TaskApiException implements Exception {
  const TaskApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TaskApiService {
  TaskApiService({HttpClient? client, String? baseUrl})
    : _client = client ?? HttpClient(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _defaultBaseUrl = String.fromEnvironment(
    'TASK_API_BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  final HttpClient _client;
  final String baseUrl;

  Future<List<Task>> fetchTasks() async {
    final response = await _request('GET', '/todos', query: {'_limit': '20'});
    final decoded = _decodeJson(response);

    if (decoded is! List) {
      throw const TaskApiException('The server returned an invalid task list.');
    }

    return decoded.whereType<Map<String, dynamic>>().map(Task.fromJson).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<Task> createTask(Task task) async {
    final response = await _request('POST', '/todos', body: task.toJson());
    final decoded = _decodeJson(response);

    if (decoded is Map<String, dynamic>) {
      return task.copyWith(id: _readId(decoded['id'], fallback: task.id));
    }

    throw const TaskApiException('The task could not be created.');
  }

  Future<Task> updateTask(Task task) async {
    final response = await _request(
      'PUT',
      '/todos/${task.id}',
      body: task.toJson(),
    );
    final decoded = _decodeJson(response);

    if (decoded is Map<String, dynamic>) {
      return Task.fromJson({...task.toJson(), ...decoded});
    }

    throw const TaskApiException('The task could not be updated.');
  }

  Future<void> deleteTask(int id) async {
    await _request('DELETE', '/todos/$id');
  }

  Future<String> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final base = Uri.parse(baseUrl);
    final uri = base.replace(path: '${base.path}$path', queryParameters: query);

    try {
      final request = await _client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 12));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TaskApiException(
          'Request failed (${response.statusCode}). Please try again.',
        );
      }

      return responseBody;
    } on SocketException {
      throw const TaskApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const TaskApiException('The request timed out. Please try again.');
    } on TaskApiException {
      rethrow;
    } catch (_) {
      throw const TaskApiException('Something went wrong. Please try again.');
    }
  }

  Object? _decodeJson(String source) {
    if (source.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(source);
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    return decoded;
  }

  int _readId(Object? value, {required int fallback}) {
    return value is int ? value : int.tryParse('$value') ?? fallback;
  }
}
