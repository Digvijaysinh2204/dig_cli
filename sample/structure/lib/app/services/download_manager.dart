import 'dart:async';

import 'package:background_downloader/background_downloader.dart';

import '../utils/import.dart';

class DownloadManager extends GetxService {
  StreamSubscription<TaskUpdate>? _subscription;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<DownloadManager> init() async {
    for (final locale in AppLocalizations.supportedLocales) {
      await _configureForLocale(locale);
    }
    await FileDownloader().trackTasks();
    return this;
  }

  Future<void> _configureForLocale(Locale locale) async {
    final localizations = lookupAppLocalizations(locale);
    final groupName = 'download_${locale.languageCode}';

    FileDownloader().configureNotificationForGroup(
      groupName,
      running: TaskNotification(
        '{displayName}',
        localizations.downloading('{progress}'),
      ),
      complete: TaskNotification(
        '{displayName}',
        localizations.downloadComplete,
      ),
      error: TaskNotification('{displayName}', localizations.downloadFailed),
      paused: TaskNotification('{displayName}', localizations.downloadPaused),
      progressBar: true,
      tapOpensFile: true,
    );
  }

  /// Get the appropriate notification group based on current locale
  String get _notificationGroup {
    final code = Get.find<LanguageService>().locale.languageCode;
    return 'download_$code';
  }

  Future<String?> downloadFile({
    required String url,
    String? filename,
    Map<String, String>? headers,
    String? directory,
    BaseDirectory baseDirectory = BaseDirectory.applicationSupport,
    String? group,
    Updates updates = Updates.statusAndProgress,
    bool requiresWiFi = false,
    int retries = 3,
    int priority = 10,
    String? metaData,
    String? displayName,
    DateTime? creationTime,
    bool allowPause = true,
    Function(String taskId, double progress)? onProgress,
    Function(String taskId, TaskStatus status)? onStatusChange,
  }) async {
    String actualFilename = filename ?? _extractFilenameFromUrl(url);
    actualFilename = await _ensureExtension(actualFilename, url);

    final task = DownloadTask(
      url: url,
      filename: actualFilename,
      headers: headers ?? {},
      directory: directory ?? '',
      baseDirectory: baseDirectory,
      group: group ?? _notificationGroup,
      updates: updates,
      requiresWiFi: requiresWiFi,
      retries: retries,
      priority: priority,
      metaData: metaData ?? '',
      displayName: displayName ?? actualFilename,
      creationTime: creationTime ?? DateTime.now(),
      allowPause: allowPause,
    );

    if (onProgress != null || onStatusChange != null) {
      _subscription?.cancel();
      _subscription = FileDownloader().updates.listen((update) {
        if (update is TaskStatusUpdate && onStatusChange != null) {
          onStatusChange(update.task.taskId, update.status);
        } else if (update is TaskProgressUpdate && onProgress != null) {
          onProgress(update.task.taskId, update.progress);
        }
      });
    }

    final result = await FileDownloader().download(task);
    if (result.status == TaskStatus.complete) {
      final newPath = await FileDownloader().moveToSharedStorage(
        task,
        SharedStorage.downloads,
      );
      final l10n = AppLocalizations.of(Get.context!)!;
      showToast(message: l10n.downloadComplete, type: ToastType.success);
      kLog(title: 'DownloadManager', content: 'File downloaded: $newPath');
      if (newPath != null) {
        kLog(
          title: 'DownloadManager',
          content: 'File moved to Downloads: $newPath',
        );

        Get.find<NotificationService>().showCustomNotification(
          title: actualFilename,
          body: l10n.downloadComplete,
          payload: {'path': newPath, 'type': 'Download'},
        );
      }
    }
    return result.status == TaskStatus.complete ? task.taskId : null;
  }

  /// Clean up resources
  void dispose() {
    _subscription?.cancel();
  }

  /// Extract filename from URL
  String _extractFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<String> _ensureExtension(String filename, String url) async {
    if (filename.contains('.') && filename.split('.').last.length <= 5) {
      return filename;
    }

    try {
      final uri = Uri.parse(url);
      final lastSegment = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : '';

      if (lastSegment.contains('.')) {
        final ext = lastSegment.split('.').last;
        return '$filename.$ext';
      }
    } catch (_) {}

    return '$filename.pdf';
  }
}
