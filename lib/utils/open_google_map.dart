
import 'package:url_launcher/url_launcher.dart';

void openGoogleMaps(String lat, String lng) async {
    
      String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(Uri.parse(googleUrl));
      } else {
        throw 'Could not open Google Maps';
      }
    }