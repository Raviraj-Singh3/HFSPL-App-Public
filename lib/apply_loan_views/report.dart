
import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/apply_loan_views/web_viewer.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Crif/crif_response.dart';
import 'package:HFSPL/network/responses/kyc/snapshot_model/snapshot_model.dart';
import 'package:HFSPL/utils/globals.dart';
import '../state/kyc_state.dart';

class Report extends StatefulWidget {
  final SnapshotModel snapshotModel;
  const Report({super.key, required this.snapshotModel});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {

  CrifResponseModel? data;
  final DioClient _client = DioClient();
  bool isLoading = true;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print("snapshot model ${widget.snapshotModel.id}");
    fetchData();

  }

   fetchData() async {
    try {
      var d = await _client.checkCibil(widget.snapshotModel.id!, int.parse(Global_uid));

      setState(() {
           data = CrifResponseModel.fromJson(d);
           isLoading = false;
      });

    } catch(e) {

      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("$e")));

      setState(() {
        isLoading = false;
      });
    }
  }

  downloadReport(String memberName, String path) async {
    try {
      
      var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HtmlViewerPage(
                  memberName: memberName,
                  path: path,
                )));
      // print("response of in Download $response");
      
    } catch (e) {
      // print("Error in Download ");
      // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Error Download ${e}")));
    }
  }
  
  @override
Widget build(BuildContext context) {
  if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (data == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: const Center(child: Text('Data not available')),
    );
  }

  var decision = data?.finalDecisionRows?[0];
  return Scaffold(
    appBar: AppBar(title: const Text('Report')),
    body: Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.green.shade700, // Border color
                width: 2.0, // Border width
              ),
            ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Column(
              children: [
                RowWithData(title: 'Status :', data: decision?.status, color: Colors.green.shade600, fontWeight: FontWeight.bold,),
                RowWithData(title: 'Any Over Due :', data: decision?.totalOD?.toString() ?? 'N/A'),
                RowWithData(title: 'Any Write Off :', data: decision?.totalWO?.toString() ?? 'N/A'),
                RowWithData(title: 'Total Installment :', data: decision?.totalInstallment?.toString() ?? 'N/A'),
                RowWithData(title: 'Total Outstanding :', data: decision?.totalOutStanding?.toString() ?? 'N/A'),
                RowWithData(title: 'Monthly Eligibility :', data: decision?.monthlyEligibleAmt?.toString() ?? 'N/A'),

                const SizedBox(height: 20,),

                const Text("Eligible Products:", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                // style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20,),

                const Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("No. Of EMI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                  Text("Eligible Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                ],),

                const SizedBox(height: 10,),

                Expanded(
                  child: ListView.builder(itemCount: data?.finalDecisionRows?.length,itemBuilder: (context, index) {
                    return Column(
                      children: [
                        RowWithData(
                          data: data?.finalDecisionRows?[index].eligibleProduct?.toString(),
                          title: data?.finalDecisionRows?[index].eligibleProductEMI.toString()  ?? '',
                        ),
                      ],
                    );
                  // 
                  },),

                ),
                const SizedBox(height: 10,),
                
                Expanded(
                  child: ListView.builder(itemCount: data?.memberIndReportPaths?.length,itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data?.memberIndReportPaths?[index].item1?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: ()=> downloadReport(data!.memberIndReportPaths![index].item1!, data!.memberIndReportPaths![index].item2!), 
                          child: const Text("Download"))
                      ],
                    );
                  // 
                  },),
                  
                ),
                const SizedBox(height: 40,)

              ],
            ),
            
            ),
        ),
        

      ],
    )
  )
  ;
}

}