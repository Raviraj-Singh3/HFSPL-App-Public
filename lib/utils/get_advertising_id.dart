import 'package:advertising_id/advertising_id.dart';

Future<String> getAdvertisingId() async {
  try {
    final adId = await AdvertisingId.id(true);  // true = throw if tracking is limited
    if (adId != null) {
      // print('Advertising ID: $adId');
      return adId;
    } else {
      // print('Advertising ID is null');
      return 'no-ad-id';
    }
  } catch (e) {
    // print('Failed to get Advertising ID: $e');
    return 'no-ad-id';
  }
}