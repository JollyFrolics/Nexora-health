import 'package:flutter/material.dart';

class LoadingOverlay {
  OverlayEntry? loadingOverlayEntry;

  void createLoadingOverlay() {
    removeLoadingOverlay();

    assert(loadingOverlayEntry == null);

    loadingOverlayEntry = OverlayEntry(
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

    assert(loadingOverlayEntry != null);

    logger("Showing new overlay $loadingOverlayEntry", "Nexora Overlay");

    Overlay.of(context, debugRequiredFor: widget).insert(loadingOverlayEntry!);
  }

  void removeLoadingOverlay() {
    logger("Removing previous overlay", "Nexora Overlay");
    loadingOverlayEntry?.remove();
    loadingOverlayEntry?.dispose();
    loadingOverlayEntry = null;
  }
}
