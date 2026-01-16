import 'package:flutter/material.dart';
import 'package:HFSPL/utils/globals.dart';

import 'custom_views/app_button.dart';
import 'custom_views/app_text_view.dart';
import 'my_home_page.dart';
import 'network/networkcalls.dart';
import 'utils/local_storage.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  final DioClient _client = DioClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Hide the app bar
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Image.asset(
                'assets/images/app_logo.png',
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create your profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextBox(
                      controller: firstNameController,
                      hintText: 'Enter your first name',
                      labelText: 'First Name',
                    ),
                    const SizedBox(height: 10),
                    AppTextBox(
                      controller: lastNameController,
                      hintText: 'Enter your last name',
                      labelText: 'Last Name',
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      onPressed: _updateProfile,
                      isLoading: isLoading,
                      text: 'Update profile',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _updateProfile(dynamic valueBack) async {
    // Validate OTP
    if (firstNameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name'),
        ),
      );
      return;
    }
    if (lastNameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your last name'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Replace this with your Dio API call
      // await Dio().post('YOUR_API_ENDPOINT', data: {
      //   'firstName': firstNameController.text,
      //   'lastName': lastNameController.text,
      // });

      // Handle success, e.g., show a success message

      var resp = await _client.updateprofile(Global_token, Global_uid,
          '${firstNameController.text} ${lastNameController.text}');

      Global_name = resp.name!.toString();
      SharedPreferencesHelper().setString('name', resp.name!);
      SharedPreferencesHelper().setBool('isLoggedIn', true);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                  title: '',
                )),
        (route) => false,
      );
    } catch (error) {
      // Handle error, e.g., show an error message
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
