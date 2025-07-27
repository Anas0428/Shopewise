class AppData {
  static final _appData = AppData._internal();
  bool isLoggedIn = false;

  String email = "You are not logged in";

  factory AppData() {
    return _appData;
  }

  AppData._internal();
}

final appData = AppData();
