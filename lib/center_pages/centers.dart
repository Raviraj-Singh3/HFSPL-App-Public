import 'package:HFSPL/Collection/location.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/center_pages/groups.dart';
import 'package:HFSPL/center_pages/village_dropdown.dart';
import 'package:HFSPL/custom_views/app_button_secondary.dart';
import 'package:geolocator/geolocator.dart';
import '../custom_views/app_text_view.dart';
import '../network/networkcalls.dart';
import '../network/responses/center_model/center_model.dart';
import '../utils/globals.dart';

class Centers extends StatefulWidget {
  const Centers({super.key});

  @override
  State<Centers> createState() => _CentersState();
}

class _CentersState extends State<Centers> {
  String selectedVillageId = '';
  bool isCenterCreating = false;
  final TextEditingController _textController = TextEditingController();
  final DioClient _client = DioClient();
  List<CenterModel> centerList = [];
  List<CenterModel> filteredCenterList = [];

  fetch() async {
    try {
      var response = await _client.getCentersByUserId(Global_uid);
      setState(() {
        centerList = response;
        filteredCenterList = response;
      });
    } catch (e) {
      showMsg("something went wrong $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
    _textController.addListener(() {
    filterCenters(_textController.text);
  });
  }

  void filterCenters(String query) {
  setState(() {
    filteredCenterList = centerList
        .where((center) => center.centerName!
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text("Center")),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                        title: Text(filteredCenterList[index].centerName!),
                        subtitle: Text(
                            "Total Groups = ${centerList[index].groupCount.toString()}"),
                        trailing: AppButtonSecondary(
                          onPressed: onCenterSelect,
                          text: 'Select',
                          valueToPassBack: filteredCenterList[index],
                        )),
                  );
                },
                itemCount: filteredCenterList.length,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            AppTextBox(
              controller: _textController,
              keyboardType: TextInputType.text,
              hintText: 'Enter center name',
              labelText: 'Center name',
            ),
            const SizedBox(
              height: 10,
            ),
            VillageDropDown(
              onChanged: (value) {
                selectedVillageId = value;
              },
            ),
            
            PrimaryButton(onPressed: (){_createCenter(context);}, text: "Create Center"),
            const SizedBox(
              height: 10,
            )
          ]),
        ),
      ),
    );
  }

  _createCenter(value) async {
    //selectedVillageId
    //_textController
    if (_textController.text.trim().isEmpty) {
      // show alert for required text
      showMsg('Please Enter Center Name');
    } else if (selectedVillageId == '') {
      // show alert for required village
      showMsg('Please select a village');
    } else {
      // submit center
      // call add center api
      try {
        setState(() {
          isCenterCreating = true;
        });
        Position position = await getCurrentLocation();
        var data = [
          {
            "CenterName": _textController.text.trim(),
            "Lat": position.latitude,
            "Lng": position.longitude,
            "Uid": Global_uid,
            "VillageId": selectedVillageId
          }
        ];
        var resp = await _client.createCenter(data);
        setState(() {
          centerList.add(resp);
          isCenterCreating = false;
        });
        onCenterSelect(resp);
      } catch (e) {
        showMsg(e.toString());
        setState(() {
          isCenterCreating = false;
        });
      }
    }
  }

  showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(msg),
      ),
    );
  }

  onCenterSelect(dynamic value) async {
    CenterModel selectedCenter = value as CenterModel;
    // print('selected center ${selectedCenter.groupCount}');
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupsPage(
                selectedCenter: selectedCenter,
              )),
    );
    if (result != null) {
      // some value
    }
  }
}
