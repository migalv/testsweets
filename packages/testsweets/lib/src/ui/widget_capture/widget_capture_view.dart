import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:testsweets/src/constants/app_constants.dart';
import 'package:testsweets/src/ui/shared/app_colors.dart';
import 'package:testsweets/src/ui/shared/shared_styles.dart';
import 'package:testsweets/src/ui/shared/widgets/inspect_layout_widget.dart';
import 'package:testsweets/src/ui/shared/widgets/widget_description_dialog_widget.dart';
import 'package:testsweets/src/ui/widget_capture/widget_capture_view.form.dart';
import 'package:testsweets/src/ui/widget_capture/widget_capture_viewmodel.dart';

import 'widget_capture_widgets/capture_view_layout.dart';
import 'widget_capture_widgets/main_view_layout.dart';
import 'widget_capture_widgets/widget_description_capture_layer.dart';
import 'widget_capture_widgets/widget_name_input.dart';

@FormView(fields: [FormTextField(name: 'widgetName')])
class WidgetCaptureView extends StatelessWidget with $WidgetCaptureView {
  final String projectId;
  final String? apiKey;
  final Widget child;

  WidgetCaptureView({
    required this.child,
    required this.projectId,
    this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WidgetCaptureViewModel>.reactive(
      onModelReady: (model) {
        listenToFormUpdated(model);
        widgetNameFocusNode.addListener(() {
          model.setWidgetNameFocused(widgetNameFocusNode.hasFocus);
        });
        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
          model.initialise(projectId: projectId);
        });
      },
      builder: (context, model, _) => ScreenUtilInit(
          builder: () => Overlay(
                initialEntries: [
                  OverlayEntry(
                      builder: (context) => Stack(
                            children: [
                              child,
                              model.inspectLayoutEnable
                                  ? InspectLayoutView()
                                  : _CaptureLayout(
                                      widgetNameController:
                                          widgetNameController,
                                      widgetNameFocusNode: widgetNameFocusNode),
                              Positioned(
                                  bottom: 20,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    width: ScreenUtil().screenWidth,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (!model.captureViewEnabled)
                                          MainViewLayout(),
                                        if (model.captureViewEnabled &&
                                            !model.hasWidgetDescription)
                                          CaptureViewLayout(),
                                      ],
                                    ),
                                  )),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 500),
                                bottom: model.showDescription ? 20 : -200,
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 500),
                                  child: model.showDescription
                                      ? WidgetDescriptionDialog(
                                          description:
                                              model.activeWidgetDescription,
                                          onPressed:
                                              model.closeWidgetDescription,
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              if (model.isBusy)
                                Container(
                                  color: kcBackground.withOpacity(0.3),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: blackBoxDecoration,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            kcPrimaryPurple),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ))
                ],
              )),
      viewModelBuilder: () => WidgetCaptureViewModel(projectId: projectId),
    );
  }
}

class _CaptureLayout extends ViewModelWidget<WidgetCaptureViewModel> {
  const _CaptureLayout({
    Key? key,
    required this.widgetNameController,
    required this.widgetNameFocusNode,
  }) : super(key: key);

  final TextEditingController widgetNameController;
  final FocusNode widgetNameFocusNode;

  @override
  Widget build(BuildContext context, WidgetCaptureViewModel model) {
    return Stack(
      children: [
        if (!model.hasWidgetDescription && model.captureViewEnabled)
          WidgetDescriptionCaptureLayer(),
        if (model.hasWidgetDescription && model.captureViewEnabled) ...[
          Positioned(
              top: model.descriptionTop,
              left: model.descriptionLeft,
              child: GestureDetector(
                onPanUpdate: (panEvent) {
                  final x = panEvent.delta.dx;
                  final y = panEvent.delta.dy;
                  model.updateDescriptionPosition(x, y);
                },
                child: Container(
                  width: WIDGET_DESCRIPTION_VISUAL_SIZE,
                  height: WIDGET_DESCRIPTION_VISUAL_SIZE,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )),
        ],
        FadeInWidget(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              alignment: model.widgetNameInputPositionIsDown
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              widthFactor: 1,
              child: WidgetNameInput(
                errorMessage: model.nameInputErrorMessage,
                closeWidget: () {
                  widgetNameController.clear();
                  model.closeWidgetNameInput();
                },
                saveWidget: model.saveWidgetDescription,
                switchPositionTap: model.switchWidgetNameInputPosition,
                focusNode: widgetNameFocusNode,
                textEditingController: widgetNameController,
              ),
            ),
            isVisible: !model.isBusy &&
                model.hasWidgetDescription &&
                model.captureViewEnabled),
      ],
    );
  }
}
