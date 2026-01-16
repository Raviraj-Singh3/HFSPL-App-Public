import 'package:HFSPL/Setting/setting.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/login_page.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/main.dart'; // wherever your navigatorKey is defined
import 'package:HFSPL/Bills/bills.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CustomDrawer extends StatelessWidget {
  final BuildContext parentContext;
  const CustomDrawer({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {

  void logoutOnclick() async {
    Navigator.of(context).pop();
     LocationUtil.stopBackgroundService();
      SharedPreferencesHelper().setBool('isLoggedIn', false);
      saveLogoutToFirebase(Global_uid);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
  }

 void logout(BuildContext context) async {
  
  if (DateTime.now().hour < 18) {
    showDialog(context: context, builder: (context)=>
       AlertDialog(
        title: const Text("Leaving Early?", style: TextStyle(color: Colors.red),),
        content:  const Text("You are signing out before work hours end at 6 PM. Salary may be deducted."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: const Text("Cancel"),
           ),
           TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              logoutOnclick();
            },
            child: const Text("Proceed Anyway"))
        ],
      )
      );
  }
  else {
    logoutOnclick();
  }
}

  
    return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(Global_name),
          accountEmail: Text(Global_designationName),
          currentAccountPicture: Global_profileImageBytes != null
            ? CircleAvatar(
                backgroundImage: MemoryImage(Global_profileImageBytes!),
              )
            : CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("${Global_name[0]}", style: TextStyle(fontSize: 24.0, color: Colors.teal.shade700)),
            ),
            decoration: BoxDecoration(color: Colors.teal.shade700),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Setting()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.receipt_long),
        //   title: const Text('Bills'),
        //   onTap: () {
        //     Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsPage()));
        //   },
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: 
          () => logout(context),
        ),
      ],
    ),
  );
  }
}