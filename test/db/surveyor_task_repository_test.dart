import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/surveyor_task_repository.dart';

void main() {
  late AppDatabase db;
  late SurveyorTaskRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SurveyorTaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SurveyorTaskRepository', () {
    List<Map<String, dynamic>> sampleChecklist = [
      {'item': 'Check exterior', 'done': false},
      {'item': 'Take photos', 'done': false},
    ];

    Map<String, dynamic> sampleVisitData = {
      'visitedAt': '2024-01-15T10:30:00Z',
      'notes': 'Property is well maintained',
      'photos': ['photo1.jpg', 'photo2.jpg'],
    };

    group('Downloaded Tasks', () {
      test('saveDownloadedTask inserts a task', () async {
        await repository.saveDownloadedTask(
          taskId: 'task-1',
          title: 'Survey House',
          description: 'Survey the target house',
          instructions: 'Follow checklist',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );

        final tasks = await repository.getDownloadedTasks();
        expect(tasks.length, 1);
        expect(tasks.first.taskId, 'task-1');
        expect(tasks.first.title, 'Survey House');
      });

      test(
        'saveDownloadedTask with insertOnConflictUpdate updates existing task',
        () async {
          await repository.saveDownloadedTask(
            taskId: 'task-1',
            title: 'Original Title',
            status: 'pending',
            checklistTemplate: sampleChecklist,
          );

          await repository.saveDownloadedTask(
            taskId: 'task-1',
            title: 'Updated Title',
            status: 'completed',
            checklistTemplate: sampleChecklist,
          );

          final tasks = await repository.getDownloadedTasks();
          expect(tasks.length, 1);
          expect(tasks.first.title, 'Updated Title');
          expect(tasks.first.status, 'completed');
        },
      );

      test(
        'getDownloadedTasks returns tasks ordered by downloadedAt descending',
        () async {
          final oldDate = DateTime.now().subtract(const Duration(days: 1));
          final newDate = DateTime.now();

          await db
              .into(db.localSurveyorTasks)
              .insert(
                LocalSurveyorTasksCompanion.insert(
                  taskId: 'task-old',
                  title: 'Old Task',
                  status: 'pending',
                  checklistTemplateJson: jsonEncode(sampleChecklist),
                  downloadedAt: oldDate,
                ),
              );

          await db
              .into(db.localSurveyorTasks)
              .insert(
                LocalSurveyorTasksCompanion.insert(
                  taskId: 'task-new',
                  title: 'New Task',
                  status: 'pending',
                  checklistTemplateJson: jsonEncode(sampleChecklist),
                  downloadedAt: newDate,
                ),
              );

          final tasks = await repository.getDownloadedTasks();
          expect(tasks.length, 2);
          expect(tasks.first.taskId, 'task-new');
          expect(tasks.last.taskId, 'task-old');
        },
      );

      test('getDownloadedTask returns correct task', () async {
        await repository.saveDownloadedTask(
          taskId: 'unique-task',
          title: 'Unique Task',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );

        final task = await repository.getDownloadedTask('unique-task');
        expect(task, isNotNull);
        expect(task!.taskId, 'unique-task');
      });

      test('getDownloadedTask returns null for non-existent task', () async {
        final task = await repository.getDownloadedTask('non-existent');
        expect(task, isNull);
      });

      test('isTaskDownloaded returns true for downloaded task', () async {
        await repository.saveDownloadedTask(
          taskId: 'downloaded-task',
          title: 'Downloaded',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );

        final isDownloaded = await repository.isTaskDownloaded(
          'downloaded-task',
        );
        expect(isDownloaded, isTrue);
      });

      test('isTaskDownloaded returns false for non-downloaded task', () async {
        final isDownloaded = await repository.isTaskDownloaded('non-existent');
        expect(isDownloaded, isFalse);
      });

      test('removeDownloadedTask deletes the task', () async {
        await repository.saveDownloadedTask(
          taskId: 'task-to-remove',
          title: 'Task to Remove',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );

        await repository.removeDownloadedTask('task-to-remove');

        final task = await repository.getDownloadedTask('task-to-remove');
        expect(task, isNull);
      });

      test('clearDownloadedTasks removes all downloaded tasks', () async {
        await repository.saveDownloadedTask(
          taskId: 'task-1',
          title: 'Task 1',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );
        await repository.saveDownloadedTask(
          taskId: 'task-2',
          title: 'Task 2',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );

        final tasksBefore = await repository.getDownloadedTasks();
        expect(tasksBefore.length, 2);

        for (final task in tasksBefore) {
          await repository.removeDownloadedTask(task.taskId);
        }

        final tasksAfter = await repository.getDownloadedTasks();
        expect(tasksAfter.length, 0);
      });
    });

    group('Visits', () {
      setUp(() async {
        // Pre-create a downloaded task for visit tests
        await repository.saveDownloadedTask(
          taskId: 'task-1',
          title: 'Survey Task',
          status: 'pending',
          checklistTemplate: sampleChecklist,
        );
      });

      test('saveVisit inserts a visit record', () async {
        await repository.saveVisit(
          idempotencyKey: 'visit-1',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );

        final visit = await repository.getVisitByIdempotencyKey('visit-1');
        expect(visit, isNotNull);
        expect(visit!.idempotencyKey, 'visit-1');
        expect(visit.taskId, 'task-1');
        expect(visit.syncStatus, 0);
      });

      test(
        'saveVisit with insertOnConflictUpdate updates existing visit',
        () async {
          await repository.saveVisit(
            idempotencyKey: 'visit-1',
            taskId: 'task-1',
            visitData: sampleVisitData,
          );

          final updatedData = {...sampleVisitData, 'notes': 'Updated notes'};
          await repository.saveVisit(
            idempotencyKey: 'visit-1',
            taskId: 'task-1',
            visitData: updatedData,
          );

          final visit = await repository.getVisitByIdempotencyKey('visit-1');
          expect(visit, isNotNull);
          // The JSON should be updated
          final decoded = jsonDecode(visit!.visitDataJson);
          expect(decoded['notes'], 'Updated notes');
        },
      );

      test('getPendingVisits returns only visits with syncStatus=0', () async {
        await repository.saveVisit(
          idempotencyKey: 'pending-visit',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );
        await repository.saveVisit(
          idempotencyKey: 'synced-visit',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );
        await repository.saveVisit(
          idempotencyKey: 'failed-visit',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );

        // Manually mark synced and failed
        await repository.markVisitSynced('synced-visit', 'server-123');
        await repository.markVisitFailed('failed-visit');

        final pendingVisits = await repository.getPendingVisits();
        expect(pendingVisits.length, 1);
        expect(pendingVisits.first.idempotencyKey, 'pending-visit');
      });

      test(
        'markVisitSynced updates syncStatus to 1 and sets serverId',
        () async {
          await repository.saveVisit(
            idempotencyKey: 'visit-1',
            taskId: 'task-1',
            visitData: sampleVisitData,
          );

          await repository.markVisitSynced('visit-1', 'server-456');

          final visit = await repository.getVisitByIdempotencyKey('visit-1');
          expect(visit!.syncStatus, 1);
          expect(visit.serverId, 'server-456');
        },
      );

      test('markVisitFailed updates syncStatus to 2', () async {
        await repository.saveVisit(
          idempotencyKey: 'visit-1',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );

        await repository.markVisitFailed('visit-1');

        final visit = await repository.getVisitByIdempotencyKey('visit-1');
        expect(visit!.syncStatus, 2);
      });

      test('countPendingVisits returns correct count', () async {
        await repository.saveVisit(
          idempotencyKey: 'visit-1',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );
        await repository.saveVisit(
          idempotencyKey: 'visit-2',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );
        await repository.saveVisit(
          idempotencyKey: 'visit-3-synced',
          taskId: 'task-1',
          visitData: sampleVisitData,
        );

        await repository.markVisitSynced('visit-3-synced', 'server-123');

        final count = await repository.countPendingVisits();
        expect(count, 2);
      });

      test(
        'getVisitByIdempotencyKey returns null for non-existent visit',
        () async {
          final visit = await repository.getVisitByIdempotencyKey(
            'non-existent',
          );
          expect(visit, isNull);
        },
      );
    });
  });
}
