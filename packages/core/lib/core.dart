
import 'package:core/src/brigdes/core/core_platform_interface.dart';

class Core {
  Future<String?> getPlatformVersion() {
    return CorePlatform.instance.getPlatformVersion();
  }
}
