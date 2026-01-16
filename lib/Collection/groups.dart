

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:HFSPL/Collection/collection.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Collection/group_model.dart';
import 'package:HFSPL/utils/globals.dart';

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {


final DioClient _client = DioClient();
// int feId = 5;


late DateTime now;
bool asPerSchedule = true;
List<Group> groupList = [];
bool _isLoading = true;

fetchGroups() async {
    try {

      var response = await _client.collectionGroupsByDate(int.tryParse(Global_uid)!,'${now.year}-${now.month}-${now.day}',asPerSchedule);

      setState(() {
        groupList = response;
      });
    }
    catch(e) {
      showMessage(context, "Error fetching data: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  openCollectionPage(int id, String groupName)async{

   var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Collection(groupId: id, groupName: groupName, collectionDate: now, schedule: asPerSchedule),));
    if(result != null){
      fetchGroups();
    }
  }

  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      // helpText: "Select Date For GRT",
      initialDate: now, // Set today as the initial date
      firstDate: now, // Set minimum date to today
      lastDate:
          now.add(const Duration(days: 365))
          , // Max date is 14 days from today
    );
    if (picked != null ) {
      setState(() {
        selectedDate =DateTime(picked.year, picked.month, picked.day);
        // selectedDate = picked; // Update selected date
      });
    }
  }

  _openDatePicker () async {
    await _pickDate(
        context); // Show date picker if at least one checkbox is checked

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }
    setState(() {
      now = selectedDate!;
      
      fetchGroups();
    });
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime dateTime = DateTime.now();
    now = DateTime(dateTime.year, dateTime.month, dateTime.day);
    print("niow $now");
    var trim = now.toString().trim();
    print("trim $trim");
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groups'),),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Schedule", style: TextStyle(fontSize: 16),),
              Checkbox(
            value: asPerSchedule, 
            onChanged: (value){
              setState(() {
                asPerSchedule = value!;
                fetchGroups();
              });
            }
            ),
             Expanded(child: Container()),
            TextButton(
                      onPressed: (){
                        if(asPerSchedule){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please Uncheck Schedule.')),
                          );
                          return;
                        }
                        else {
                          _openDatePicker();
                        }
                      },
                      child: Row(
                        children: [
                          Text("${DateFormat('yyyy-MM-dd').format(now)}", style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 5,),
                          Icon(Icons.calendar_month_rounded)
                        ],
                      )
                      )
            ],
                            ),
          ),
          
          Expanded(
            child: groupList.isEmpty
                ? const Center(
                          child: Text('Data not available')
                        )
              : ListView.builder(
              itemCount: groupList.length,
              padding: EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(groupList[index].name!,),
                    trailing: ElevatedButton(
                      onPressed: (){
                        openCollectionPage(groupList[index].id!, groupList[index].name!);
                      }, 
                      child: Text("CONTINUE")
                      ),
                  ),
                );
              },
              )
            ),
        ],
      ),
    );
  }
}