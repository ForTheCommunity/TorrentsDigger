import 'package:torrents_digger/src/rust/api/database/proxy.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

Future<InternalProxy?> getSavedProxyData() async {
  try {
    var savedProxy = await getSavedProxy();

    return savedProxy;
  } catch (e) {
    createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    rethrow;
  }
}

Future<BigInt> saveProxy({required InternalProxy proxyData}) {
  try {
    var result = saveProxyApi(proxyData: proxyData);
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
