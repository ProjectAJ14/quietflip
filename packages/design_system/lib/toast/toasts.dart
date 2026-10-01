import 'package:design_system/constants/design_shape.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:toastification/toastification.dart';

class Toast {
  static void notification({required String title, required String body}) =>
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: Text(title),
        description: Text(body),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
        animationBuilder: (context, animation, alignment, child) {
          return ScaleTransition(scale: animation, child: child);
        },
        icon: Icon(Iconsax.notification),
        // No context here (raised from a push handler): the default corner.
        borderRadius: DesignShape.circular(const DesignShape().sm),
        showProgressBar: true,
        dragToClose: true,
        applyBlurEffect: true,
      );

  static void error(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.warning_2),
    borderRadius: DesignShape.circular(DesignShape.of(context).sm),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );

  static void success(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.tick_circle),
    borderRadius: DesignShape.circular(DesignShape.of(context).sm),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );

  static void warning(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.warning,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.danger),
    borderRadius: DesignShape.circular(DesignShape.of(context).sm),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}
