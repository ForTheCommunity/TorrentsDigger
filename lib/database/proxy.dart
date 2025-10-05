import 'package:torrents_digger/src/rust/api/database/proxy.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

Future<(int, String, String)> getSavedProxyData() async {
  try {
    var allProxies = await getSavedProxy();

    return allProxies;
  } catch (e) {
    createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    rethrow;
  }
}

Future<BigInt> saveProxy({
  required String proxyName,
  required String proxyType,
  required String proxyServerIp,
  required String proxyServerPort,
  required String proxyUsername,
  required String proxyPassword,
}) {
  try {
    var result = saveProxyApi(
      proxyName: proxyName,
      proxyType: proxyType,
      proxyServerIp: proxyServerIp,
      proxyServerPort: proxyServerPort,
    );
    return result;
  } catch (e) {
    createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    rethrow;
  }
}

Future<List<(int, String)>> getSupportedProxyData() async {
  try {
    var allSupportedProxies = await getSupportedProxyDetails();
    return allSupportedProxies;
  } catch (e) {
    createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    rethrow;
  }
}

Future<BigInt> removeProxy(int proxyId) {
  try {
    var result = deleteProxy(proxyId: proxyId);
    return result;
  } catch (e) {
    createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    rethrow;
  }
}
