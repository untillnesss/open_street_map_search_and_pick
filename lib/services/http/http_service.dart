import 'package:http/http.dart' as http;

class ClientWithUserAgent extends http.BaseClient {
  final http.Client _client;

  ClientWithUserAgent(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] = DateTime.now().toString();
    return _client.send(request);
  }
}
