import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/presentation/controllers/home_controller.dart';

class MultipleFloating extends StatelessWidget {
  MultipleFloating({super.key, required this.fabKey});

  final ctrl = Get.find<HomeController>();
  final GlobalKey<ExpandableFabState> fabKey;

  @override
  Widget build(BuildContext context) {
    return Obx(() => (ctrl.isTextPrompt.value == false)
        ? FloatingActionButton(
            heroTag: UniqueKey(),
            onPressed: () async {
              if (await ctrl.speech.hasPermission &&
                  ctrl.speech.isNotListening) {
                await ctrl.startListening();
              } else if (ctrl.speech.isListening) {
                await ctrl.stopListening();
              } else {
                ctrl.initialize();
              }
            },
            shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2)),
            backgroundColor: Theme.of(context).primaryColor,
            child: Obx(
              () => Icon(
                (ctrl.speechListen.value) ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          )
        : ExpandableFab(
            key: fabKey,
            fanAngle: 120,
            distance: 60,
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.menu_open_rounded),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
            ),
            closeButtonBuilder: RotateFloatingActionButtonBuilder(
              child: InkWell(
                  onTap: () {
                    final state = fabKey.currentState;
                    if (state != null) {
                      state.toggle();
                    }
                  },
                  child: const Icon(Icons.close)),
              fabSize: ExpandableFabSize.small,
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
            ),
            children: [
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: () async {
                  if (await ctrl.speech.hasPermission &&
                      ctrl.speech.isNotListening) {
                    await ctrl.startListening();
                  } else if (ctrl.speech.isListening) {
                    await ctrl.stopListening();
                  } else {
                    ctrl.initialize();
                  }
                },
                shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 2)),
                backgroundColor: Theme.of(context).primaryColor,
                child: Obx(
                  () => Icon(
                    (ctrl.speechListen.value) ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: () {
                  (ctrl.isStopped.value) ? ctrl.playTTs() : ctrl.stopTTs();
                },
                shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 2)),
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  (ctrl.isStopped.value) ? Icons.play_arrow : Icons.stop,
                  color: Colors.white,
                ),
              ),
              FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: () {
                  final state = fabKey.currentState;
                  if (state != null) {
                    state.toggle();
                    ctrl.resetAll();
                  }
                },
                shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 2)),
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.white,
                ),
              )
            ],
          ));
  }
}
