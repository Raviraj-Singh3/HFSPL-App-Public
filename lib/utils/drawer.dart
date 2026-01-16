// import 'package:flutter/material.dart';

// class MyDrawer extends StatelessWidget {
//   const MyDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//         // backgroundColor: const Color.fromARGB(255, 24, 82, 129),
//         child: Padding(
//           padding: const EdgeInsets.only(left: 8, top: 100, bottom: 8),
//           child: SingleChildScrollView(
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 // Important: Remove any padding from the ListView.
//                 // padding: EdgeInsets.only(left: 5, top: 100),
//                 children: [
//                   // const DrawerHeader(
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.blue,
//                   //   ),
//                   //   child: Text('Drawer Header'),
//                   // ),
//                   ListTile(
//                     title: const Text('HFSPL'),
//                     selected: _selectedIndex == 0,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(0);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     title: const Text('Audit'),
//                     selected: _selectedIndex == 1,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(1);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const Audit()),
//                       );
//                     },
//                   ),
                  
//                   ListTile(
//                     title: const Text('Group Training'),
//                     selected: _selectedIndex == 2,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(2);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const GroupTraining()),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: const Text('GRT Dashboard'),
//                     selected: _selectedIndex == 3,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(3);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const GRTDashboard()),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: const Text('Collection'),
//                     selected: _selectedIndex == 4,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(4);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const Groups()),
//                       );
//                     },
//                   ),
//                   ExpansionTile(
//                     title: const Text('Attendance'),
//                     leading: const Icon(Icons.access_time),
//                     childrenPadding: const EdgeInsets.only(left: 40),
//                     children: <Widget>[
//                       ListTile(
//                         title: const Text('Mark Attendance'),
//                         onTap: () {
//                           _onItemTapped(5);
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const MarkAttendence()),
//                           );
//                         },
//                       ),
//                       ListTile(
//                         title: const Text('View Attendance'),
//                         onTap: () {
//                           Navigator.pop(context);
//                           // Add your page for viewing attendance here
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const AttendancePage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
              
                  
              
              
//                   ListTile(
//                     title: const Text('Leave'),
//                     selected: _selectedIndex == 6,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(6);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const Leave()),
//                       );
//                     },
//                   ),

//                 if (Global_designationName == 'BM')
//                   ListTile(
//                     title: const Text('Review KYC'),
//                     selected: _selectedIndex == 7,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(7);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SelectGroup()),
//                       );
//                     },
//                   ),

//                   ListTile(
//                     title: const Text('Rejected KYC'),
//                     selected: _selectedIndex == 8,
//                     onTap: () {
//                       // Update the state of the app
//                       _onItemTapped(8);
//                       // Then close the drawer
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const RejectedGroup()),
//                       );
//                     },
//                   ),
              
//                   // Expanded(child: Container()),
//                   ListTile(
//                     title: const Text(
//                       "Sign Out",
//                       style:
//                           TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//                     ),
//                     leading: const Icon(
//                       Icons.logout,
//                       color: Colors.red,
//                     ),
//                     onTap: _logout,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//   }
// }