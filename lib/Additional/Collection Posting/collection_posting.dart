import 'dart:convert';

import 'package:HFSPL/Collection/location.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_collection_2_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/Collection/demand_model.dart';
import 'package:HFSPL/network/responses/Collection/group_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/get_felist_from_branchId.dart';
import 'package:HFSPL/utils/pick_date_function.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CollectionPosting extends StatefulWidget {
  const CollectionPosting({super.key});

  @override
  State<CollectionPosting> createState() => _CollectionPostingState();
}

class _CollectionPostingState extends State<CollectionPosting> {
  final DioClient _client = DioClient();

  List<BranchModel> branchList = [];
  List<ActiveFeModel> feList = [];
  int? selectedBranchId;
  int? selectedFeId;
  List<Group> groupList = [];
  DateTime selectedDate = DateTime.now();
  bool asPerSchedule = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  int? selectedGroupId;
  List<Member> demandMembersList = [];
  Map<String, bool> isMemberPresent = {};
  Map<String, bool> isCollection = {};
  Map<String, bool> isOD = {};
  Map<int, TextEditingController> _controllers = {};

  void getBranches() async {
    try {
      var response = await _client.getAllBranches(Global_uid);
      setState(() {
        branchList = response;
      });
    } catch (e) {
      showMessage(context, "Error: $e ");
    }
  }

  void getFeList() async {
    if (selectedBranchId == null) return;
    
    try {
      var response = await getFeListFromBranchId(selectedBranchId!);
      setState(() {
        feList = response;
        selectedFeId = null; // Reset FE selection when branch changes
        selectedGroupId = null;
        demandMembersList = [];
        isMemberPresent = {};
        isCollection = {};
        isOD = {};
        _controllers.clear();
      });
    } catch (e) {
      showMessage(context, "Error fetching FE list: $e");
    }
  }

  fetchCollectionGroups() async {
    if (selectedFeId == null) return;
    try {
      var response = await _client.collectionGroupsByDate(selectedFeId!,'${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',asPerSchedule);

      setState(() {
        groupList = response;
        selectedGroupId = null;
        demandMembersList = [];
        isMemberPresent = {};
        isCollection = {};
        isOD = {};
        _controllers.clear();
      });
    }
    catch(e) {
      showMessage(context, "$e");
    }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  fetchDemand() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await _client.getDemand(selectedFeId!,'${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',selectedGroupId!,asPerSchedule);
      setState(() {
        demandMembersList = response.members!;
      });
      for (var member in demandMembersList) {
        isMemberPresent[member.memberId.toString()] = false;
        isCollection[member.memberId.toString()] = true;
        isOD[member.memberId.toString()] = false;
      }
    }
    catch(e) {
      showMessage(context, "$e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  
  onSubmitClick() async {
    if (!mounted || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Add validation to ensure required data is available
    if (selectedFeId == null || selectedGroupId == null || demandMembersList.isEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields and ensure member data is loaded')),
      );
      return;
    }

    // Validate that at least one member has collection amount entered
    bool hasValidCollection = false;
    for (var member in demandMembersList) {
      if (isCollection[member.memberId.toString()] == true) {
        final amountText = _controllers[member.memberId!]?.text.trim() ?? '0';
        if (amountText.isNotEmpty && double.tryParse(amountText) != null && double.parse(amountText) > 0) {
          hasValidCollection = true;
          break;
        }
      }
    }

    if (!hasValidCollection) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter collection amount for at least one member')),
      );
      return;
    }

    // Safe loader overlay handling
    try {
      if (mounted) {
        context.loaderOverlay.show();
      }
    } catch (e) {
      // If loader overlay fails, continue without it but show loading state
      setState(() {
        _isLoading = true;
      });
    }

    try {
      Position position = await getCurrentLocation();

      var items = CollectionPostRequest(
        asPerSchedule: asPerSchedule,
        members: demandMembersList.map((e) => CollectionPostMember(
          memberId: e.memberId!,
          postedAmount: double.parse(_controllers[e.memberId!]!.text.trim()),
          isPresent: isMemberPresent[e.memberId.toString()] ?? false,
          isOD: isOD[e.memberId.toString()] ?? false,
          isSelected: isCollection[e.memberId.toString()] ?? false,
          memberName: e.name ?? "",
          lat: position.latitude,
          lng: position.longitude,
          postedBy: int.parse(Global_uid),
        )).toList(),
      );

      await _client.postCollection2(jsonEncode(items));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection Posted Successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      // Safe cleanup
      try {
        if (mounted) {
          context.loaderOverlay.hide();
        }
      } catch (e) {
        // If loader overlay cleanup fails, just update loading state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      
      // Always reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  datepicker() async {
    selectedDate = await pickDate(context, selectedDate, DateTime.now(), DateTime(2100));
    setState(() {});
    fetchCollectionGroups();
  }

  @override
  void initState() {
    super.initState();
    getBranches();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection Posting"),
      ),
      body: LoaderOverlay(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedBranchId,
                  hint: const Text("Select Branch"),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: branchList.map((e) => DropdownMenuItem<int>(
                    value: e.bid,
                    child: Text(e.branchName ?? ""),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBranchId = value;
                    });
                    getFeList();
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedFeId,
                  hint: const Text("Select Field Executive"),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: feList.map((e) => DropdownMenuItem<int>(
                    value: e.feId,
                    child: Text(e.feName ?? ""),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFeId = value;
                    });
                    fetchCollectionGroups();
                  },
                ),
                const SizedBox(height: 16),
                DropdownSearch<Group>(
                  selectedItem: groupList.isNotEmpty && selectedGroupId != null 
                    ? groupList.firstWhere(
                        (element) => element.id == selectedGroupId,
                        orElse: () => groupList.first,
                      )
                    : null,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search group...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    constraints: BoxConstraints(maxHeight: 300),
                  ),
                  items: groupList,
                  itemAsString: (item) => item.name ?? "",
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedGroupId = value.id;
                      });
                      fetchDemand();
                    }
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select Group",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: asPerSchedule,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() {
                              asPerSchedule = value;
                              selectedDate = DateTime.now();
                            });
                            // if(asPerSchedule){
                              fetchCollectionGroups();
                            // }
                          },
                        ),
                        const Text(
                          'As Per Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: asPerSchedule ? null : datepicker,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('dd MMM yyyy').format(selectedDate))
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if(_isLoading)
                const Center(child: CircularProgressIndicator()),
                if(demandMembersList.isNotEmpty && !_isLoading)
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: demandMembersList.length,
                      itemBuilder: (context, index) {
                        Member member = demandMembersList[index];
                        if (!_controllers.containsKey(member.memberId)) {
                          _controllers[member.memberId!] = TextEditingController();
                        }
                        _controllers[member.memberId!]!.text = isOD[member.memberId.toString()] ?? false ? '0' : member.demand?.toString() ?? '0';
                        var date = DateFormat('dd-MM-yyyy').format(member.collectionDate!);
                        
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${member.name} (${member.relativeName})", 
                                  style: const TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                RowWithData(title: 'Loan No:', data: member.loanNumber ?? ''),
                                RowWithData(title: 'EMI:', data: member.emi?.toString() ?? '0'),
                                RowWithData(title: 'OD:', data: member.overdue?.toString() ?? '0'),
                                RowWithData(title: 'Demand:', data: member.demand?.toString() ?? '0'),
                                RowWithData(title: 'Collection Date:', data: date),
                                RowWithData(title: 'I.N.:', data: member.installment?.toString() ?? ''),
                                
                                Row(
                                  children: [
                                    const Text(
                                      'Type:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isCollection[member.memberId.toString()],
                                                  onChanged: (bool? value) {
                                                    if (value == true) {
                                                      setState(() {
                                                        isCollection[member.memberId.toString()] = true;
                                                        isOD[member.memberId.toString()] = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isCollection[member.memberId.toString()] = false;
                                                      });
                                                    }
                                                  },
                                                ),
                                                const Text('Collection'),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isOD[member.memberId.toString()],
                                                  onChanged: (bool? value) {
                                                    if (value == true) {
                                                      setState(() {
                                                        isOD[member.memberId.toString()] = true;
                                                        isCollection[member.memberId.toString()] = false;
                                                        // _controllers[index].text = '0';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isOD[member.memberId.toString()] = false;
                                                        // _controllers[index].text = '0';
                                                      });
                                                    }
                                                  },
                                                ),
                                                const Text('OD'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Row(
                                  children: [
                                    const Text(
                                      'Attendance:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: RadioListTile<bool>(
                                              title: const Text('P'),
                                              value: true,
                                              groupValue: isMemberPresent[member.memberId.toString()],
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  isMemberPresent[member.memberId.toString()] = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<bool>(
                                              title: const Text('A'),
                                              value: false,
                                              groupValue: isMemberPresent[member.memberId.toString()],
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  isMemberPresent[member.memberId.toString()] = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                TextField(
                                  enabled: isCollection[member.memberId.toString()] ?? false,
                                  controller: _controllers[member.memberId!],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Collected Amount',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                   PrimaryButton(
                  onPressed: onSubmitClick,
                  isLoading: _isSubmitting,
                  text: 'POST COLLECTION',
                ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}