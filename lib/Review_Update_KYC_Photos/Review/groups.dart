import 'package:flutter/material.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Review/group_card.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_group.dart';
import 'package:HFSPL/utils/globals.dart';

class SelectGroup extends StatefulWidget {
  const SelectGroup({super.key});

  @override
  State<SelectGroup> createState() => _SelectGroupState();
}

class _SelectGroupState extends State<SelectGroup> {
  final DioClient _client = DioClient();
  bool isLoading = true;

  List<ReviewGroupModel> pendingKycGroups = [];

  String searchQuery = "";
  bool isSearching = false;

  void _searchGroupByName(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  fetchPendingKycGroups() async {
    try {
      var response = await _client.getPendingKycGroups(Global_uid);

      setState(() {
        pendingKycGroups = response;
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
  initState() {
    super.initState();
    fetchPendingKycGroups();
  }

  @override
  Widget build(BuildContext context) {
    // Filter groups based on the search query
    List filteredGroups = pendingKycGroups
        .where((group) => group.groupName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if(isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if(pendingKycGroups.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Group')),
        body: const Center(child: Text("No groups found")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Group'),
        actions: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSearching ? 200 : 50,
                child: TextField(
                        onChanged: (value) => _searchGroupByName(value),
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            isSearching = false;
                          });
                        },
                        decoration: InputDecoration(
                          suffixIcon: isSearching ?
                           IconButton(
                            onPressed: () {
                              setState(() {
                                searchQuery = "";
                                isSearching = !isSearching;
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ):
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isSearching = !isSearching;
                              });
                            },
                            icon: const Icon(Icons.search),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintStyle: const TextStyle(color: Colors.grey),
                          hintText: 'Search Group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )
              ),
              
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80.0),
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  return GroupCard(group: filteredGroups[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
