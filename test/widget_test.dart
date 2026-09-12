import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('shows splash screen with task manager branding', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Plan, track, and finish your work.'), findsOneWidget);
  });

  testWidgets('navigates from splash screen to task list', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}
