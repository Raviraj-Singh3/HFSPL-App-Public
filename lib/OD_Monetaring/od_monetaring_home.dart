
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/OD_Monetaring/member_details.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/network/responses/OD/od_group_list.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OdMonetaringHome extends StatefulWidget {
  const OdMonetaringHome({super.key});

  @override
  State<OdMonetaringHome> createState() => _OdMonetaringHomeState();
}

class _OdMonetaringHomeState extends State<OdMonetaringHome> {
  final DioClient _client = DioClient();

  List<BranchModel> branchList = [];
  int? selectedBranchId;
  List<ActiveFeModel> feList = [];
  int? selectedFeId;
  List<OdGroupList> odGroupList = [];
  bool isLoading = false;
  String searchQuery = "";
  bool isSearching = false;
  
  // Filter variables
  String selectedFilter = "All";
  final List<String> filterOptions = [
    "All",
    "0-30 days",
    "31-60 days", 
    "61-90 days",
    "90+ days"
  ];


  _getAllBranches() async {
    try {
     var response = await _client.getAllBranches(Global_uid);
      setState(() {
        branchList = response;
      });

    BranchModel? branch = await _showSelectionDialog(branchList, "Select Branch");
    if (branch != null) {
      setState(() {
        selectedBranchId = branch.bid;
      });
    }
    _getFe();
      
    } catch (e) {
      showMessage(context, "Error: $e ");
    }
  }

  _getFe()async {
    try {
      var response = await _client.getAllActiveFe(selectedBranchId!);
      setState(() {
        feList = response;
      });

      ActiveFeModel? fe = await _showSelectionDialog(feList, "Select FE");
      if (fe != null) {
        setState(() {
        selectedFeId = fe.feId;
      });
      }

      setState(() {
        isLoading = true;
      });

      odGroupList = await _client.getOdGroupList(selectedFeId!);

      setState(() {
        isLoading = false;
      });
      

    } catch (e) {
      showMessage(context, '$e');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _searchGroupByName(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Date utility functions
  int _calculateDaysFromOdStart(String odStartDate) {
    try {
      // Parse the date format "18-Dec-2024"
      DateFormat format = DateFormat('dd-MMM-yyyy');
      DateTime odDate = format.parse(odStartDate);
      DateTime currentDate = DateTime.now();
      
      return currentDate.difference(odDate).inDays;
    } catch (e) {
      print('Error parsing date: $e');
      return 0;
    }
  }

  bool _isMemberInFilterRange(OdMember member) {
    int daysFromOdStart = _calculateDaysFromOdStart(member.odStartDate);
    
    switch (selectedFilter) {
      case "0-30 days":
        return daysFromOdStart >= 0 && daysFromOdStart <= 30;
      case "31-60 days":
        return daysFromOdStart >= 31 && daysFromOdStart <= 60;
      case "61-90 days":
        return daysFromOdStart >= 61 && daysFromOdStart <= 90;
      case "90+ days":
        return daysFromOdStart > 90;
      default:
        return true; // "All" filter
    }
  }

  List<OdGroupList> _getFilteredGroups() {
    if (selectedFilter == "All") {
      return odGroupList;
    }

    List<OdGroupList> filteredGroups = [];
    
    for (OdGroupList group in odGroupList) {
      List<OdMember> filteredMembers = group.members
          .where((member) => _isMemberInFilterRange(member))
          .toList();
      
      if (filteredMembers.isNotEmpty) {
        filteredGroups.add(OdGroupList(
          groupName: group.groupName,
          members: filteredMembers,
          memberCount: filteredMembers.length,
        ));
      }
    }
    
    return filteredGroups;
  }
  _selectMember(List<OdMember> members) async {

    OdMember? member = await _showSelectionDialog(members, "Select Member");

    if(member != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetails(member: member)));
    }

  }



@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllBranches();
  }

  @override
  Widget build(BuildContext context) {
    List<OdGroupList> filteredGroups = _getFilteredGroups()
        .where((group) => group.groupName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OD Monetaring'),
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
      body: isLoading ?
        Center(child: const CircularProgressIndicator())
      : filteredGroups.isEmpty && isLoading == false ?
        const Center(child: Text("No Group Found"))
        :
          Column(
            children: [
              // Filter chips section
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      bool isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          selectedColor: Colors.blue.withValues(alpha: 0.3),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Groups list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    return GroupCard(filteredGroups[index]);
                  },
                  ),
                ),
            ],
          ),
    );
  }

  Widget GroupCard(OdGroupList group) {
    // Calculate OD duration statistics for this group
    Map<String, int> odStats = _calculateGroupOdStats(group.members);
    
    return InkWell(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Total Members: ${group.memberCount}",
                style: const TextStyle(fontSize: 14),
              ),
              if (selectedFilter == "All") ...[
                const SizedBox(height: 4),
                Text(
                  "OD Stats: 0-30: ${odStats['0-30']}, 31-60: ${odStats['31-60']}, 61-90: ${odStats['61-90']}, 90+: ${odStats['90+']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
      onTap: (){
        _selectMember(group.members);
      },
    );
  }

  Map<String, int> _calculateGroupOdStats(List<OdMember> members) {
    Map<String, int> stats = {
      '0-30': 0,
      '31-60': 0,
      '61-90': 0,
      '90+': 0,
    };

    for (OdMember member in members) {
      int daysFromOdStart = _calculateDaysFromOdStart(member.odStartDate);
      
      if (daysFromOdStart >= 0 && daysFromOdStart <= 30) {
        stats['0-30'] = stats['0-30']! + 1;
      } else if (daysFromOdStart >= 31 && daysFromOdStart <= 60) {
        stats['31-60'] = stats['31-60']! + 1;
      } else if (daysFromOdStart >= 61 && daysFromOdStart <= 90) {
        stats['61-90'] = stats['61-90']! + 1;
      } else if (daysFromOdStart > 90) {
        stats['90+'] = stats['90+']! + 1;
      }
    }

    return stats;
  }

  Future<T?> _showSelectionDialog<T>(List<T> items, String title) async {
    
    if(items.isEmpty){
      return null;
    }
  else { return showDialog(
    context: context,
    barrierDismissible: T == OdMember,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: items
                .map((item) {
                  // Cast the item to the specific type for accessing fields
                  if (item is BranchModel) {
                    return ListTile(
                      title: Text(item.branchName!.isEmpty ? "No Name" : item.branchName ?? "No"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                  else if (item is ActiveFeModel) {
                    return ListTile(
                      title: Text(item.feName!.isEmpty ? "No Name" : item.feName ?? "No"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                  else if (item is OdMember) {
                    return ListTile(
                      title: Text('${item.memberName} W/O ${item.spouse}'),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                   else {
                    return ListTile(
                      title: Text("Unsupported item"),
                      onTap: () => Navigator.pop(context, null),
                    );
                  }
                })
                .toList(), // Ensures it returns List<Widget>
          ),
        ),
      );
    },
  );
  }
}
}