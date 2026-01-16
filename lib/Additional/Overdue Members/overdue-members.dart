import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/OD/od_group_list.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class OverdueMembers extends StatefulWidget {
  const OverdueMembers({super.key});

  @override
  State<OverdueMembers> createState() => _OverdueMembersState();
}

class _OverdueMembersState extends State<OverdueMembers> {

  List<OdGroupList> odGroupList = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  void _sortGroupsByMinDuesDays() {
  odGroupList.sort((a, b) {
    final minA = a.members.map((m) => m.duesDays).reduce((a, b) => a < b ? a : b);
    final minB = b.members.map((m) => m.duesDays).reduce((a, b) => a < b ? a : b);
    return minA.compareTo(minB);
  });
}

Future<void> _callNumber(String phoneNumber) async {
  if (phoneNumber.isNotEmpty) {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == null || !res) {
      showMessage(context, "Failed to make the call");
    }
  }
}

  fetch() async {
    try {

      var response = await _client.getOdGroupList(int.parse(Global_uid));

      setState(() {
        odGroupList = response;
         _sortGroupsByMinDuesDays();
        isLoading = false;
      });
      
    } catch (e) {
      // Handle error
      showMessage(context, "$e");
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
  return Scaffold(
    appBar: AppBar(
      title: const Text("Overdue Members"),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : odGroupList.isEmpty
            ? const Center(child: Text("No overdue members found."))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 80),
                itemCount: odGroupList.length,
                itemBuilder: (context, index) {
                  final group = odGroupList[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        group.groupName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      children: group.members.map((member) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  elevation: 3,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "👤 ${member.memberName} (${member.spouse})",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _callNumber(member.mobile),
            ),
          ],
        ),
        Text("📞 ${member.mobile}", style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        Text("Loan No: ${member.loanNo}", style: const TextStyle(fontSize: 14)),
        Text("Loan Date: ${member.loanDate}", style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildInfoBox("OverDue", "₹${member.totAmtPayable}"),
            _buildInfoBox("Total OS", "₹${member.totalOS}"),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildInfoBox("OD Start", member.odStartDate),
            _buildInfoBox("Dues Days", member.duesDays.toString()),
          ],
        ),
      ],
    ),
  ),
)
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
  );
}
Widget _buildInfoBox(String title, String value) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}



}


