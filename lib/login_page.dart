import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:HFSPL/main.dart';
import 'package:HFSPL/utils/get_advertising_id.dart';
import 'package:HFSPL/utils/show_popup_after_login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'network/networkcalls.dart';
import 'utils/globals.dart';
import 'utils/local_storage.dart';
import 'utils/messages_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController userId = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  bool mobileSubmitted =
      false; // Track if mobile number is submitted successfully
  final DioClient _client = DioClient();
  bool _passObs = true;
  bool _rememberMe = false;
  final _secureStorage = const FlutterSecureStorage();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    
    // Load saved credentials
    _loadSavedCredentials();
    
    
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Load saved credentials from secure storage
  Future<void> _loadSavedCredentials() async {
    try {
      final savedUserId = await _secureStorage.read(key: 'saved_userId');
      final savedPassword = await _secureStorage.read(key: 'saved_password');
      final rememberMe = await _secureStorage.read(key: 'remember_me');
      
      if (savedUserId != null && savedPassword != null && rememberMe == 'true') {
        setState(() {
          userId.text = savedUserId;
          password.text = savedPassword;
          _rememberMe = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading saved credentials: $e');
      }
    }
  }
  
  // Save credentials to secure storage
  Future<void> _saveCredentials() async {
    try {
      if (_rememberMe) {
        await _secureStorage.write(key: 'saved_userId', value: userId.text.trim());
        await _secureStorage.write(key: 'saved_password', value: password.text.trim());
        await _secureStorage.write(key: 'remember_me', value: 'true');
      } else {
        await _secureStorage.delete(key: 'saved_userId');
        await _secureStorage.delete(key: 'saved_password');
        await _secureStorage.delete(key: 'remember_me');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving credentials: $e');
      }
    }
  }
  
   _submit() async {

    if (userId.text == "" || password.text == "") {
      showSnackBar(context, 'All Fields are required');
      return;
    }
    
    // Save credentials if remember me is checked
    await _saveCredentials();
    
    context.loaderOverlay.show();
    final deviceId = await getAdvertisingId();
    try {

    var data = {
        "username": userId.text.trim(),
        "password": password.text.trim(),
        "imsi": "",
        "imei": "",
        "deviceId": deviceId,
        "macAddress": "",
        "isRooted": false,
        "platform": "flutter",
        "versionCode": 240
      };

      var resp = await _client.login(data);

      SharedPreferencesHelper().setString('loginId', userId.text.trim());
      SharedPreferencesHelper().setString('password', password.text.trim());
      SharedPreferencesHelper().setString('token', resp!.token);
      SharedPreferencesHelper().setString('id', resp.uid.toString());
      SharedPreferencesHelper().setString('designationName', resp.designation);
      SharedPreferencesHelper().setString('token_expiry', resp.tokenExpireTime ?? '');

      SharedPreferencesHelper().setBool('IsGRTEnable', resp.isGRTEnable);
      SharedPreferencesHelper().setString('IsFE', resp.designationId.toString());
      SharedPreferencesHelper().setBool('CanDoGRT', resp.canDoGRT);

        // SharedPreferencesHelper()
        //     .setString('mobile', resp.mobileNumber!.toString());

        Global_uid = resp.uid.toString();
        // Global_mobile = resp.mobileNumber!.toString();
        Global_token = resp.token;
        Global_designationName = resp.designation;

        Global_name = resp.name;
        // Global_name = "Null";
        SharedPreferencesHelper().setString('name', Global_name);

        SharedPreferencesHelper().setBool('isLoggedIn', true);

        // SharedPreferencesHelper().setString('designationName', Global_designationName);

         Global_LoginId = userId.text.trim();
         Global_Password = password.text.trim();

        //  print("GLoabal_uid2: $Global_uid");

         _client.setAuthHeaders(Global_LoginId, Global_token, Global_Password);

         await saveLoginToFirebase(Global_uid);

         await showWorkHourStartDialog(context);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const MyApp(
                    
                  )),
          (route) => false,
        );

    } catch (e) {
      showMessage(context, "$e");
      // print("Error: ${e}");
    }
    context.loaderOverlay.hide();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Animation Section
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_balance,
                              size: 80,
                              color: Theme.of(context).primaryColor,
                            ),
                            // Alternative: Use Lottie animation if you have a JSON file
                            // child: Lottie.network(
                            //   'https://assets2.lottiefiles.com/packages/lf20_mjlh3hcy.json',
                            //   height: 150,
                            //   width: 150,
                            // ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Welcome Text
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // User ID Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: userId,
                          decoration: InputDecoration(
                            labelText: 'User ID',
                            hintText: 'Enter your User ID',
                            prefixIcon: Icon(Icons.person_outline, 
                              color: Theme.of(context).primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      
                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          obscureText: _passObs,
                          controller: password,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passObs = !_passObs;
                                });
                              },
                              icon: Icon(
                                _passObs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: PrimaryButton(
                          onPressed: () {
                            _submit();
                          },
                          text: 'Login',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
