import 'package:HFSPL/Attendance/attendance_history.dart';
import 'package:HFSPL/Leave/leave_history.dart';
import 'package:HFSPL/Notification/attendance_details.dart';
import 'package:HFSPL/Notification/notification_details.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/responses/NotificationModel/getnotification_model.dart';

class NotificationPage extends StatefulWidget {
  final List<GetNotificationModel>? notifications;

  const NotificationPage({super.key, required this.notifications});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DioClient _client = DioClient();
  @override
  Widget build(BuildContext context) {
    List<GetNotificationModel>? notifications = widget.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notifications == null || notifications.isEmpty
          ? const Center(child: Text("No Notifications"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return GestureDetector(
                  onTap: () {
                    _openLeaveDetails(notification);
                    
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: ListTile(
                      title: Text(notification.title!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(notification.body!),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                    ),
                  ),
                );
              },
            ),
    );
  }

  _openLeaveDetails(GetNotificationModel notification) async {

    var result = false;

    if(notification.notificationType == 3) {
      await _client.readNotificaton(notification.notificationId!);
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveHistory()));
      result = true;
      // return;
    }
    else if(notification.notificationType == 5) {
      await _client.readNotificaton(notification.notificationId!);
      setState(() {
        widget.notifications?.remove(notification);
      });
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceHistory()));
      result = true;
    }
    else{
         result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => notification.notificationType == 4 ? AttendanceDetails(guid: notification.guid, notiId: notification.notificationId!) :
                NotificationDetails(guid: notification.guid, notiId: notification.notificationId!),
          ),
        );
    }




    if(result){

      

      setState(() {
        widget.notifications?.remove(notification);
      });

      if(widget.notifications!.isEmpty){
        Navigator.pop(context, true);
      }

    }

  }

}
