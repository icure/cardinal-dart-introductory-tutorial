import 'package:cardinal_sdk/auth/authentication_method.dart';
import 'package:cardinal_sdk/auth/credentials.dart';
import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/options/storage_options.dart';

const cardinalUrl = "https://api.icure.cloud";
Map<String, CardinalSdk> sdkCache = {};
String? mainUsername;

Future<CardinalSdk> createSdk(String username, String password) async {
  final sdk = await CardinalSdk.initialize(
    null,
    cardinalUrl,
    AuthenticationMethod.UsingCredentials(Credentials.UsernamePassword(username, password)),
    StorageOptions.PlatformDefault
  );
  sdkCache[username] = sdk;
  return sdk;
}