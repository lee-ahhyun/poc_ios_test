import 'package:flutter/services.dart';

class PlatformChannelService {
  static const methodChannel = MethodChannel('nportverse_nearby_method_channel');
  static const eventChannel = EventChannel('nportverse_nearby_event_channel');

  static getMethodChannelValue({required String method,
    String? key,
    Map<String, dynamic>? argument}) async {
    final result = await  PlatformChannelService.methodChannel
        .invokeMethod(method, argument);

    if (key != null) {
      return (
      method,
      result[key] as String,
      );
    } else {
      return result.toString();
    }
  }

}
