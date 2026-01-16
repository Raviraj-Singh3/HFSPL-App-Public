import 'dart:async';

import 'package:HFSPL/Additional/dashbord.dart';
import 'package:HFSPL/Additional/main_dashboard.dart';
import 'package:HFSPL/Audit/dummy.dart';
import 'package:HFSPL/ClientDetails/clientDetails.dart';
import 'package:HFSPL/Additional/Collection-Calling/collection_calling.dart';
import 'package:HFSPL/Demand&Collection.dart/demand_collection.dart';
import 'package:HFSPL/Drawer/drawer.dart';
import 'package:HFSPL/Grievance/greivance.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Notification/notification.dart';
import 'package:HFSPL/OD/od.dart';
import 'package:HFSPL/OD/od_landing_page.dart';
import 'package:HFSPL/OD_Monetaring/map_screen.dart';
import 'package:HFSPL/OD_Monetaring/od_monetaring_home.dart';
import 'package:HFSPL/Other_Loans/other_loan_dashboard.dart';
import 'package:HFSPL/Non MFI/nmfi_dashboard.dart';
import 'package:HFSPL/custom_views/location.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/NotificationModel/getnotification_model.dart';
import 'package:HFSPL/network/responses/demand_collection_model.dart';
import 'package:HFSPL/utils/show_popup_after_login.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/Audit/audit.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Review/groups.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Rejected/rejected_groups.dart';
import 'package:HFSPL/Attendance/attendance.dart';
import 'package:HFSPL/Attendance/mark_attendence.dart';
import 'package:HFSPL/Collection/groups.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Leave/leave.dart';
import 'package:HFSPL/center_pages/centers.dart';
import 'package:HFSPL/grt_pages/grt_dashboard.dart';
import 'package:HFSPL/login_page.dart';
import 'package:HFSPL/group_training/group_training.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'utils/globals.dart';
import 'utils/local_storage.dart';

class MyHomePage extends StatefulWidget {
  final bool showLoginDialog;
  const MyHomePage({super.key, required this.title, this.showLoginDialog = false});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final DioClient _client = DioClient();
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  bool _dialogShowing = false;
  final platform = const MethodChannel('com.HFSPL/dev_options');
  Timer? _devModeMonitor;


  _logout() async {
  
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
  logoutOnclick() async {
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

  @override
  void initState() {
    super.initState();

    _initializeInOrder();
  }

  void _initializeInOrder() async {
    _startServiceStatusListener();
    await _locationChecker(); 
    await _fetchNotification(); 
    await LocationUtil().createNotificationChannel();

    await Future.delayed(const Duration(milliseconds: 300));

    await getProfileImage();

  if (widget.showLoginDialog) {
    await Future.delayed(const Duration(milliseconds: 300)); // brief pause before showing dialog
    if (context.mounted) {
      showWorkHourStartDialog(context);
    }
  }
}

  void _startServiceStatusListener() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        // If location becomes disabled and no dialog is showing, show the dialog
        if (!_dialogShowing) {
          _showLocationDisabledDialog();
        }
      } else if (status == ServiceStatus.enabled) {
        // If location is enabled and a dialog is showing, dismiss it
        if (_dialogShowing) {
          Navigator.of(context, rootNavigator: true).pop();
          _dialogShowing = false;
        }
      }
    });
  }

  Future<void> _locationChecker() async {
    try {
      // This will throw if location is disabled
      await getCurrentLocation();
    } catch (e) {
      // If an error occurs (e.g. location disabled), show the dialog
      if (!_dialogShowing) {
        _showLocationDisabledDialog();
      }
    }
  }

  Future<void> _showLocationDisabledDialog() async {
    _dialogShowing = true;
    // Do not allow the dialog to be dismissed by tapping outside.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Disabled"),
        content: const Text(
          "This app requires location services to function. Please enable location services.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Open app settings and DO NOT close the dialog.
              Geolocator.openAppSettings();
              // Optionally, you can add a short delay and then re-check location.
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () {
              // Exit the app
              SystemNavigator.pop();
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
    // If the dialog is dismissed for any reason, re-check location.
    _dialogShowing = false;
    _locationChecker();
  }

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    _devModeMonitor?.cancel();
    super.dispose();
  }

  

  List <GetNotificationModel>? notifications;

  Future<void> _fetchNotification() async {

    try {

      var response = await _client.getNotification(Global_uid);

      setState(() {
        notifications = response;
      });
      
    } catch (e) {
      
      showMessage(context, "$e");
    }
  }

  _openNotificationPage() async {

    if(notifications == null || notifications!.isEmpty){
      return;
    }

    var result = await Navigator.push( context, MaterialPageRoute(builder: (context) => NotificationPage(notifications: notifications)),);

    if(result){
      _fetchNotification();
      
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "HFSPL",
        ),
        actions: [
          GestureDetector(
            onTap: _openNotificationPage,
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  iconSize: 30, // Adjust icon size
                  onPressed: _openNotificationPage,
                ),
                if (notifications != null) // Show badge only if there are notifications
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                        minWidth: notifications!.length > 9 ? 24 : 20, // Adjust width for large numbers
                        minHeight: 20,
                      ),
                      child: Text(
                        notifications!.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      
      drawer: CustomDrawer(parentContext: context),

      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              // margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome, $Global_name",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "Designation: $Global_designationName",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                // height: MediaQuery.of(context).size.height/2,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildButton(
                            context,
                            icon: Icons.dashboard,
                            label: "Dashboard",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainDashboard()),
                            ),
                          ),
                          // _buildButton(
                          //   context,
                          //   icon: Icons.assignment,
                          //   label: "Audit",
                          //   onTap: () => Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => const Audit()),
                          //   ),
                          // ),
                          if (IsFE)
                          _buildButton(
                            context,
                            icon: Icons.group,
                            label: "Training",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GroupTraining()),
                            ),
                          ),
                          if (IsGRTEnable)
                          _buildButton(
                            context,
                            icon: Icons.dashboard,
                            label: "GRT",
                            onTap: () => CanDoGRT ? Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GRTDashboard()),
                            ): showMessage(context, "GRT is not enabled for your designation"),
                          ),
                          if (IsFE || IsGRTEnable)
                          _buildButton(
                            context,
                            icon: Icons.collections,
                            label: "Collection",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Groups()),
                            ),
                          ),
                          _buildButton(
                            context,
                            icon: Icons.access_time,
                            label: "Attendance",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MarkAttendence()),
                            ),
                          ),
                          _buildButton(
                            context,
                            icon: Icons.leave_bags_at_home,
                            label: "Leave",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Leave()),
                            ),
                          ),
                          // if (IsFE || IsGRTEnable)
                          _buildButton(
                            context,
                            icon: Icons.add_box ,
                            label: "Additional",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddtionalDashboard()),
                            ),
                          ),
                          // _buildButton(
                          //   context,
                          //   icon: Icons.account_balance_wallet,
                          //   label: "NMFI - Personal",
                          //   onTap: () => Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => const NMFIDashboard()),
                          //   ),
                          // ),
                          if (IsFE || IsGRTEnable)
                          _buildButton(
                            context,
                            icon: Icons.block,
                            label: "Rejected",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RejectedGroup()),
                            ),
                          ),
                          if (IsGRTEnable)
                            _buildButton(
                              context,
                              icon: Icons.verified_user,
                              label: "Review",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SelectGroup()),
                              ),
                            ),
                          _buildButton(
                            context,
                            icon: Icons.payment ,
                            label: "D&C",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DemandCollection()),
                            ),
                          ),
                          _buildButton(
                            context,
                            icon: Icons.timer_off_outlined ,
                            label: "Overdue",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ODLandingPage()),
                            ),
                          ),
                          _buildButton(
                            context,
                            icon: Icons.event_note ,
                            label: "Monitoring",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OdMonetaringHome()),
                            ),
                          ),
                          _buildButton(
                            context,
                            icon: Icons.feedback ,
                            label: "Grievance",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Greivance()),
                            ),
                          ),
                          // _buildButton(
                          //   context,
                          //   icon: Icons.logout,
                          //   label: "Sign Out",
                          //   // color: Colors.red,
                          //   onTap: _logout,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (IsFE)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(onPressed: (){onCenterCreate(context);}, text: 'KYC',),
            ),

            // SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OtherLoanDashboard()),
                );
                }, text: 'Other Loans',),
            ),

            const SizedBox(height: 40),

          ],
        ),
      ),
    );

    
  }

  


  Widget _buildButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        // margin: const EdgeInsets.all(8.0), // Spacing around the button
        decoration: BoxDecoration(
          color: color ?? Colors.teal.shade800,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
             BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2, // Ensures the text doesn't exceed two lines
                overflow: TextOverflow.ellipsis, // Handles very long text
                style: const TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.w600,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onCenterCreate(dynamic valueBack) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Centers()));
  }

  Future<void> getProfileImage() async {
    if (Global_profileImageBytes != null) return;
    try {
      final response = await _client.getProfileImage(Global_uid);
      Global_profileImageBytes = response;
    } catch (e) {
      // print("Error: $e");
      // showMessage(context, "Error: $e");
    }
  }


}


  
