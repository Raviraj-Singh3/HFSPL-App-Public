import 'package:flutter/material.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Cards/update_card.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ReviewKyc/rejected_members_model.dart';

class RejectedMembers extends StatefulWidget {
  final int groupdId;
  const RejectedMembers({super.key, required this.groupdId});

  @override
  State<RejectedMembers> createState() => _RejectedMembersState();
}

class _RejectedMembersState extends State<RejectedMembers> {
  final DioClient _client = DioClient();
  bool isLoading = true;
  List<RejectedMembersModel> memberList = [];

  _fetchRejectedMembers() async {
    try {
      var response = await _client.getRejectedKycMembers(widget.groupdId);
      setState(() {
        memberList = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchRejectedMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected KYC'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80.0),
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return  UpdateCard(member: memberList[index],
                    onRemove: () {
                      setState(() {
                        _fetchRejectedMembers();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}