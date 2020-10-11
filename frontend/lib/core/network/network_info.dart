import 'package:data_connection_checker/data_connection_checker.dart';

// final String SERVER_IP = 'http://10.0.2.2:8081';
// final String SERVER_IP = 'http://192.168.1.22:8081';
final String SERVER_IP = 'http://192.168.1.21:8081';
// final String SERVER_IP = 'http://172.20.10.6:8081';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
