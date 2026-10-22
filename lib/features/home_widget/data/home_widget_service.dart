import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const String appGroupId = 'group.com.myjournal.app';
  static const String androidWidgetName = 'MyJournalWidgetProvider';

  static Future<void> updateWidgetData({
    required int completedTasks,
    required int totalTasks,
    required String latestMoodEmoji,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.saveWidgetData<String>('tasks_summary', '$completedTasks / $totalTasks');
      await HomeWidget.saveWidgetData<String>('latest_mood', latestMoodEmoji);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'MyJournalWidget',
      );
    } catch (_) {
      // Graceful fallback if widget is not placed or on unsupported platform
    }
  }
}
