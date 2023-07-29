import 'package:http/http.dart' as http;
import 'dart:convert';

class MpesaAPI {
  String consumerKey;
  String consumerSecret;
  String shortcode;
  String passkey;

  MpesaAPI(this.consumerKey, this.consumerSecret, this.shortcode, this.passkey);

  Future<Map<String, dynamic>> checkTransactionStatus(String transactionId) async {
    String accessToken = await _generateAccessToken();
    print(accessToken);

    final url = Uri.parse('https://sandbox.safaricom.co.ke/mpesa/transactionstatus/v1/query');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = json.encode({
      'BusinessShortCode': shortcode,
      'Password': _generatePassword(),
      'Timestamp': _generateTimestamp(),
      'CommandID': 'TransactionStatusQuery',
      'SecurityCredential': 'pKIxFBePwfdgdQnJyPnLp+OeBcrDRyLIBg97S0bvYK/6vrOfVGdrwmrudR0WI7MTKshPPZ0gFyE+mrAnY+iAwaVe7Z7Y9IxNcR7Y1ma3tSyEqn7Lwy+Nyytr+caMyolmGKlOtP/vDWaNjxFlKLGNhC/r6bHcmHL3KJ4rCKzMMx85Iu30/PCPwUuogWtOSvqq7tZMR37EAa/VxtszmU+aGACSCUFHKo8rapwLqmhbfUXuJx8JdlP8gBhyFt+B7w0U+av1VimZScd6P5Gsr+8G0civJYJ5i7LYyOKBlkhsW/JHt3oNRfWXsUEaheTAue2mwVTGeZ36KekafC4jF/xWUA==',
      'TransactionID': transactionId,
      'PartyA': shortcode,
      'IdentifierType': '4',
      'ResultURL': 'https://mydomain.com/TransactionStatus/result/',
      'QueueTimeOutURL': 'https://mydomain.com/TransactionStatus/queue/',
      'Remarks': 'ok',
      'Occasion': 'ok',
      'Initiator': 'testapi'
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(response.body.toString());
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check transaction status: ${response.body.toString()}');
    }
  }

  Future<String> _generateAccessToken() async {
    final url = Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}',
    };
    print('Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final tokenData = json.decode(response.body);
      return tokenData['access_token'];
    } else {
      throw Exception('Failed to generate access token: ${response.statusCode}');
    }
  }

  String _generatePassword() {
    final time = _generateTimestamp();
    final password = '$shortcode$passkey$time';
    final encodedPassword = base64Encode(utf8.encode(password));
    return encodedPassword;
  }

  String _generateTimestamp() {
    final now = DateTime.now();
    final timestamp = now.toString().split('.')[0];
    return timestamp;
  }
}

// Transaction details
String transactionId = 'OEI2AK4Q16';

// Set your M-Pesa API credentials
String consumerKey = 'd8stR5XAA4KXXWgB9nrXs7VYGfdjd5tD';
String consumerSecret = 'nuyefmbSCX6Bd2Uz';
String shortcode = '600987';
String passkey = 'Safaricom999!*!';

void main() async {
  final mpesaApi = MpesaAPI(consumerKey, consumerSecret, shortcode, passkey);
  try {
    final response = await mpesaApi.checkTransactionStatus(transactionId);
    if (response['ResponseCode'] == '0') {
      print('Transaction status: ${response['ResponseDescription']}');
    } else {
      print('Error: ${response['ResponseDescription']}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

