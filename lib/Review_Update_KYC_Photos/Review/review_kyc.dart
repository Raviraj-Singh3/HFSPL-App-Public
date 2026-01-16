import 'package:flutter/material.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Cards/review_card.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_members.dart';

class ReviewKYC extends StatefulWidget {

  final int groupdId;
  const ReviewKYC({super.key,  required this.groupdId});

  @override
  State<ReviewKYC> createState() => _ReviewKYCState();
}

class _ReviewKYCState extends State<ReviewKYC> {

  final DioClient _client = DioClient();
  bool isLoading = true;
  List<ReviewMembersModel> memberList = [];

  _fetchReviewMembers() async {
    try {
      var response = await _client.getReviewKycMembers(widget.groupdId);
      setState(() {
        memberList = response;
        isLoading = false;
      });

    } catch (e) {
      print("Error Fetching Review KYC Members API: $e");
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
    _fetchReviewMembers();
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if(memberList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review KYC')),
        body: const Center(child: Text("No members found")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review KYC'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 60.0),
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return ReviewCard(member: memberList[index],
                    onRemove: () {
                      setState(() {
                        memberList.removeAt(index);
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

