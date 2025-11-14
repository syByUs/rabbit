import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';


void showMessage(String message, BuildContext context) {
  showToast(message, context:context, position: StyledToastPosition.center, animation: StyledToastAnimation.fade, reverseAnimation: StyledToastAnimation.fade);
}