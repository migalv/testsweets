import 'package:testsweets/src/extensions/widget_position_extension.dart';
import 'package:testsweets/testsweets.dart';

import '../app/logger.dart';

class ReactiveScrollable {
  final log = getLogger('ReactiveScrollable');
  Interaction applyScrollableOnInteraction(
    Iterable<ScrollableDescription> scrollables,
    Interaction widgetDescription,
  ) {
    log.v(widgetDescription);
    final overlapScrollableWithInteraction = scrollables.where(
      (element) => element.scrollableWidgetRect.contains(
        widgetDescription.position.toOffset,
      ),
    );

    /// If there is no overlapping with any scrollable
    /// Return WidgetDescription without changing anything
    if (overlapScrollableWithInteraction.isEmpty) return widgetDescription;

    for (var scrollable in overlapScrollableWithInteraction.toList()) {
      widgetDescription = widgetDescription.copyWith(
        externalities: {
          ...widgetDescription.externalities ?? {},
          scrollable.scrollableWidgetRect
        },
        position: widgetDescription.position.withScrollable(scrollable),
      );
    }

    return widgetDescription;
  }

  Iterable<Interaction> filterAffectedInteractionsByScrollable(
      ScrollableDescription scrollableDescription,
      List<Interaction> viewDescription) {
    log.v(scrollableDescription);

    return viewDescription.where(
      (interaction) =>
          interaction.externalities?.any(
            (rect) =>
                rect.topLeft ==
                scrollableDescription.scrollableWidgetRect.topLeft,
          ) ??
          false,
    );
  }

  Iterable<Interaction> moveInteractionsWithScrollable(
    ScrollableDescription scrollableDescription,
    Iterable<Interaction> affectedInteractions,
  ) {
    log.v(scrollableDescription);

    return affectedInteractions.map((interaction) => interaction.copyWith(
        position: interaction.position.applyScroll(scrollableDescription)));
  }
}
