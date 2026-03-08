import 'package:flutter/material.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/utils/logging.dart';

class LoadingOverlayView extends StatelessWidget {
  const LoadingOverlayView({super.key});

  @override
  Widget build(BuildContext context) {
    logger("Building the loading overlay", "Nexora Overlay");
    return SafeArea(
      child: Material(
        color: Colors.black45,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.loading),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay {
  static OverlayEntry? overlayEntry;

  static void show(BuildContext context, Widget widget) {
    hide();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            color: Colors.black45,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.loading),
                ],
              ),
            ),
          ),
        );
      },
    );

    assert(overlayEntry != null);

    logger("Showing new overlay $overlayEntry", "Nexora Overlay");

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  static void hide() {
    logger("Removing previous overlay", "Nexora Overlay");
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }
}
