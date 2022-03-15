import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:testsweets/src/enums/handler_message_response.dart';
import 'package:testsweets/src/services/sweetcore_command.dart';
import 'package:testsweets/src/services/widget_visibilty_changer_service.dart';

import '../helpers/test_consts.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('WidgetVisibiltyChangerServiceTest -', () {
    setUp(registerServices);
    tearDown(unregisterServices);

    group('toggleVisibilty -', () {
      test(
          'When the latestSweetcoreCommand is not null, Should toggle visiabilty of the widget',
          () {
        final _service = WidgetVisibiltyChangerService();

        _service.sweetcoreCommand = ScrollableCommand(widgetName: 'widgetName');

        /// Sence default visibilty is true
        expect(
            _service.toggleVisibilty([kGeneralInteractionWithZeroOffset],
                [kGeneralInteractionWithZeroOffset]),
            [kGeneralInteractionWithZeroOffset.copyWith(visibility: false)]);
      });
    });
    group('completeCompleter -', () {
      test('When completeCompleter is called, Should complete the completer',
          () {
        final _service = WidgetVisibiltyChangerService();
        _service.completer = Completer();
        _service.completeCompleter(
            HandlerMessageResponse.foundAutomationKeyWithTargets);
        expect(_service.completer!.isCompleted, true);
      });
    });
    group('updateViewWidgetsList -', () {
      test('''When changing any proberty of some widget, Should be abe to
       replace it in descriptionsForView list''', () {
        final _service = WidgetVisibiltyChangerService();

        final result = _service.updateViewWidgetsList([
          kGeneralInteraction.copyWith(visibility: true)
        ], [
          kGeneralInteractionWithZeroOffset,
          kGeneralInteraction.copyWith(visibility: false)
        ]);
        expect(result.elementAt(1),
            kGeneralInteraction.copyWith(visibility: true));
      });
    });
  });

  group('filterTargetedWidgets -', () {
    test('When call, Should extract the targeted widgets by id', () {
      final _service = WidgetVisibiltyChangerService();
      final targetedWidgets = _service.filterTargetedWidgets(
          kGeneralInteractionWithZeroOffset.automationKey, [
        kGeneralInteractionWithZeroOffset
            .copyWith(targetIds: [kGeneralInteraction.id!]),
        kGeneralInteraction
      ]);
      expect(targetedWidgets.first, kGeneralInteraction);
    });
    test('When targetIds is empty, Should return empty list', () {
      final _service = WidgetVisibiltyChangerService();

      final targetedWidgets = _service.filterTargetedWidgets(
          kGeneralInteractionWithZeroOffset.automationKey,
          [kGeneralInteractionWithZeroOffset]);
      expect(targetedWidgets, isEmpty);
    });
  });
}
