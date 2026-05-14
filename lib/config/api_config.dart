class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5170/api';
  // For physical device on same Wi-Fi:
  // static const String baseUrl = 'http://YOUR_PC_IP:5062/api';

  static const String authEndpoint = '$baseUrl/auth';
  static const String usersEndpoint = '$baseUrl/users';
}
