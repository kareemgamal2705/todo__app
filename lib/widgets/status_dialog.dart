import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum _DialogKind { loading, success, error }

Future<bool> runWithStatusDialog(
  BuildContext context,
  Future<void> Function() action, {
  String loadingMessage = 'Please wait...',
  String successMessage = 'Done successfully',
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _StatusDialog(kind: _DialogKind.loading, message: loadingMessage),
  );

  try {
    await action();
    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pop();

    if (!context.mounted) return false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _StatusDialog(kind: _DialogKind.success, message: successMessage),
    );
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pop();

    if (!context.mounted) return false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StatusDialog(
        kind: _DialogKind.error,
        message: e.toString().replaceFirst('Exception: ', ''),
      ),
    );
    return false;
  }
}

class _StatusDialog extends StatefulWidget {
  final _DialogKind kind;
  final String message;

  const _StatusDialog({required this.kind, required this.message});

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.kind != _DialogKind.loading) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  String get _asset {
    switch (widget.kind) {
      case _DialogKind.loading:
        return 'assets/lotties/loading.json';
      case _DialogKind.success:
        return 'assets/lotties/success.json';
      case _DialogKind.error:
        return 'assets/lotties/error.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset(
                  _asset,
                  repeat: widget.kind == _DialogKind.loading,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
