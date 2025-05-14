
import 'dynamic_app_icon_platform_interface.dart';

class DynamicAppIcon {
  Future<String?> getPlatformVersion() {
    return DynamicAppIconPlatform.instance.getPlatformVersion();
  }
}
