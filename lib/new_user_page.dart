import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HFSPL/custom_views/app_button.dart';

class NewuserPage extends StatefulWidget {
  const NewuserPage({Key? key}) : super(key: key);

  @override
  NewuserPageState createState() => NewuserPageState();
}

class NewuserPageState extends State<NewuserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Udyat Micro Finance'),
      // ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to HFSPL Micro Finance',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Thanks for your interest in HFSPL Micro Finance. Team will contact you soon.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              AppButton(
                onPressed: _onExit,
                text: 'Ok',
              ),
            ],
          )),
    );
  }

  _onExit(value) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
