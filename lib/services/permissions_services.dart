import 'package:permission_handler/permission_handler.dart' as PHandler;

class PermissionServices{
  static var _locationStatus, _phoneStatus;
  static void checkPermissions() async {
    _locationStatus = await PHandler.Permission.location.request();
    _phoneStatus = await PHandler.Permission.phone.request();
  }

  static isLocationGranted() {
    return _locationStatus == PHandler.PermissionStatus.granted;
  }

  static isPhoneGranted(){
    return _phoneStatus == PHandler.PermissionStatus.granted;
  }

  static isPhoneGrantedCheck() async{
    _phoneStatus = await PHandler.Permission.phone.request();
    return isPhoneGranted();
  }

  static isLocationGrantedCheck() async {
    _locationStatus = await PHandler.Permission.location.request();
    return isLocationGranted();
  }
}
