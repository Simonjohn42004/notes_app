import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArguement on BuildContext {
  T? getArgument<T>() {
    final modelRoute = ModalRoute.of(this);
    if(modelRoute == null) return null;
    final args = modelRoute.settings.arguments;
    if(args == null || args is !T) return null;
    return args as T;
  }
}