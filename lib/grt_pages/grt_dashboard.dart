
import 'package:flutter/material.dart';
import 'package:HFSPL/grt_pages/grt_page.dart';
import 'package:HFSPL/grt_pages/pre_grt.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/grt/grt_by_id_model.dart';
import 'package:HFSPL/utils/globals.dart';

class GRTDashboard extends StatefulWidget {
  const GRTDashboard({super.key});

  @override
  State<GRTDashboard> createState() => _GRTDashboardState();
}


class _GRTDashboardState extends State<GRTDashboard> {
  final DioClient _client = DioClient();
  List<GRTById> grtResponseList = [];
  bool isGRT = false;

  bool isLoading = true;

  fetch() async {

    try {

      var response  = await _client.getUserGRT(Global_uid);
      setState(() {
        grtResponseList = response; //
        isLoading = false;
      });

    }

    catch(e){

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('$e')),
       );
      
      setState(() {
        isLoading = false;
      });

    }
  }

  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
     
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRT Dashboard')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (grtResponseList.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRT Dashboard')),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(title: const Text("GRT Dashboard"),),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                    itemCount: grtResponseList.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          grtResponseList[index].groupName!,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Status: ${grtResponseList[index].status == 6 ? 'Pre GRT Assigned' : (grtResponseList[index].status == 8 ? 'GRT Assigned' : 'GRT Completed')}')
                                      ],
                                    ),
                                  ),
                                   grtResponseList[index].status! < 9 ? 
                                      ElevatedButton(
                                        onPressed: () {
                                          onClick(grtResponseList[index]);
                                        },
                                        child: const Text("Continue"))
                                      : const Icon(Icons.check, color: Color.fromARGB(255, 4, 184, 10)),
                                      // : Text("")
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  void onClick(GRTById grtResponseList) async {
    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                            grtResponseList.status == 6?
                              PreGRTPage(
                                  cgtGroup: grtResponseList
                                          ): GRTPage( cgtGroup: grtResponseList,)
                                          ));
    if(result == true) {
      // initState();
      //refresh the page
      setState(() {

        fetch();
      
      });
    }
}
}