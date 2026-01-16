import 'dart:io';
import 'package:HFSPL/Collection/location.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/utils/New%20Image%20Picker/new_image_picker.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/center_monitoring/meeting_type_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/center_monitor_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/group_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/member_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/submit_monitoring_response.dart';

class CenterVisit extends StatefulWidget {
  const CenterVisit({super.key});

  @override
  State<CenterVisit> createState() => _CenterVisitState();
}

class _CenterVisitState extends State<CenterVisit> {
  final DioClient _client = DioClient();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _centerFieldKey = GlobalKey();
  
  // Form controllers
  final TextEditingController _groupObservationController = TextEditingController();
  final TextEditingController _centerObservationController = TextEditingController();
  final TextEditingController _centerSearchController = TextEditingController();
  
  // Form data
  List<BranchModel> branchList = [];
  List<ActiveFeModel> feList = [];
  List<MeetingTypeResponse> meetingTypes = [];
  List<CenterMonitorResponse> centers = [];
  List<GroupResponse> groups = [];
  List<MemberResponse> members = [];
  
  // Selected values
  int selectedBranchId = 0;
  int selectedStaffId = 0;
  int selectedMeetingTypeId = 0;
  int selectedCenterId = 0;
  int selectedFilterType = 0; // 0=All, 1=Pending, 2=More than 3 months
  List<int> selectedGroupIds = [];
  int? selectedFeId;
  
  // Member data for submission
  Map<int, String> memberObservations = {};
  Map<int, File?> memberPhotos = {};
  Map<int, bool> memberSelected = {};

  
  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _groupObservationController.dispose();
    _centerObservationController.dispose();
    _centerSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() { isLoading = true; });
    
    try {
      await Future.wait([
        _getAllBranches(),
        _loadMeetingTypes(),
      ]);
    } catch (e) {
      _showError('Failed to load initial data: $e');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future _getAllBranches() async {
    try {
      var response = await _client.getAllBranches(Global_uid);
      setState(() {
        branchList = response;
      });
    } catch (e) {
      showMessage(context, "Error: $e ");
    }
  }

  Future<void> _loadStaffByBranch(int branchId) async {
    try {
      setState(() {
        isLoading = true;
        // Clear all dependent data when branch changes
        selectedStaffId = 0;
        selectedMeetingTypeId = 0;
        selectedCenterId = 0;
        selectedFilterType = 0;
        selectedGroupIds.clear();
        feList.clear();
        centers.clear();
        groups.clear();
        _centerSearchController.clear();
        members.clear();
        memberObservations.clear();
        memberPhotos.clear();
        memberSelected.clear();
        _groupObservationController.clear();
        _centerObservationController.clear();
      });

      var response = await _client.getAllActiveFe(branchId);
      setState(() {
        feList = response;
        isLoading = false;
      });
    } catch (e) {
      showMessage(context, '$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMeetingTypes() async {
    try {
      final types = await _client.getMeetingTypes();
      setState(() {
        meetingTypes = types;
      });
    } catch (e) {
      _showError('Failed to load meeting types: $e');
    }
  }

 

  Future<void> _loadCentersByStaff(int staffId) async {
    try {
      setState(() {
        isLoading = true;
        // Clear dependent data when staff changes
        selectedCenterId = 0;
        selectedGroupIds.clear();
        centers.clear();
        groups.clear();
        _centerSearchController.clear();
        members.clear();
        memberObservations.clear();
        memberPhotos.clear();
        memberSelected.clear();
        _groupObservationController.clear();
        _centerObservationController.clear();
      });

      final centerData = await _client.getCentersByFeIdAndFilter(staffId, selectedFilterType);
      setState(() {
        centers = centerData;
        isLoading = false;
      });
    } catch (e) {
      _showError('Failed to load centers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadGroupsByCenter(int centerId) async {
    try {
      setState(() {
        // Clear dependent data when center changes
        selectedGroupIds.clear();
        groups.clear();
        members.clear();
        memberObservations.clear();
        memberPhotos.clear();
        memberSelected.clear();
        _groupObservationController.clear();
        _centerObservationController.clear();
      });

      final groupData = await _client.getGroupsByCenterId(centerId);
      setState(() {
        groups = groupData;
      });
    } catch (e) {
      _showError('Failed to load groups: $e');
    }
  }

  Future<void> _loadMembersByGroups(List<int> groupIds) async {
    if (groupIds.isEmpty) {
      setState(() {
        members.clear();
        memberObservations.clear();
        memberPhotos.clear();
        memberSelected.clear();
        _groupObservationController.clear();
        _centerObservationController.clear();
      });
      return;
    }

    try {
      final memberData = await _client.getMembersByGroupIds(groupIds);
      setState(() {
        members = memberData;
        // Clear and reinitialize member data
        memberObservations.clear();
        memberPhotos.clear();
        memberSelected.clear();
        
        // Initialize member selections
        for (var member in members) {
          memberSelected[member.id] = true;
          memberObservations[member.id] = '';
          memberPhotos[member.id] = null;
        }
      });
    } catch (e) {
      _showError('Failed to load members: $e');
    }
  }

  Future<void> _pickImage(int memberId) async {
    try {
      final pickedImage = await getImage(ImageSource.camera);
      
      if (pickedImage != null) {
        setState(() {
          memberPhotos[memberId] = pickedImage;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _submitMonitoring() async {
    if (!_validateForm()) return;

    setState(() { isSubmitting = true; });

    try {

      Position position = await getCurrentLocation();
      // Prepare member data
      List<Map<String, dynamic>> memberData = [];
      for (var member in members) {
        if (memberSelected[member.id] == true) {
          memberData.add({
            'clientId': member.id,
            'observation': memberObservations[member.id] ?? '',
            'photoFile': memberPhotos[member.id],
          });
        }
      }

      final response = await _client.submitCenterMonitoring(
        centerId: selectedCenterId,
        staffId: int.parse(Global_uid),
        meetingTypeId: selectedMeetingTypeId,
        groupIds: selectedGroupIds,
        groupObservation: _groupObservationController.text,
        centerObservation: _centerObservationController.text,
        memberData: memberData,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );

      if (response.success) {
        _showSuccess(response.message);
        _resetForm();
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to submit monitoring: $e');
    } finally {
      setState(() { isSubmitting = false; });
    }
  }

  bool _validateForm() {
    if (selectedBranchId == 0) {
      _showError('Please select a branch');
      return false;
    }
    if (selectedStaffId == 0) {
      _showError('Please select staff');
      return false;
    }
    if (selectedMeetingTypeId == 0) {
      _showError('Please select meeting type');
      return false;
    }
    if (selectedCenterId == 0) {
      _showError('Please select center');
      return false;
    }
    if (selectedGroupIds.isEmpty) {
      _showError('Please select at least one group');
      return false;
    }
    if (_groupObservationController.text.isEmpty) {
      _showError('Please enter group observation');
      return false;
    }

    // Check if selected members have observations and photos
    for (var member in members) {
      if (memberSelected[member.id] == true) {
        if (memberObservations[member.id]?.isEmpty == true) {
          _showError('Please add observation for ${member.name}');
          return false;
        }
        if (memberPhotos[member.id] == null) {
          _showError('Please add photo for ${member.name}');
          return false;
        }
      }
    }

    return true;
  }

  void _resetForm() {
    setState(() {
      selectedBranchId = 0;
      selectedStaffId = 0;
      selectedMeetingTypeId = 0;
      selectedCenterId = 0;
      selectedFilterType = 0;
      selectedGroupIds.clear();
      
      feList.clear();
      centers.clear();
      groups.clear();
      members.clear();
      
      memberObservations.clear();
      memberPhotos.clear();
      memberSelected.clear();
      
      _groupObservationController.clear();
      _centerObservationController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Center Visit"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBranchDropdown(),
                  const SizedBox(height: 16),
                  _buildStaffDropdown(),
                  const SizedBox(height: 16),
                  _buildMeetingTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildFilterSelection(),
                  const SizedBox(height: 16),
                  _buildCenterDropdown(),
                  const SizedBox(height: 16),
                  _buildGroupSelection(),
                  const SizedBox(height: 16),
                  _buildMembersList(),
                  const SizedBox(height: 16),
                  _buildObservationFields(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Branch', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedBranchId == 0 ? null : selectedBranchId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select Branch',
          ),
          isExpanded: true,
          items: branchList.map<DropdownMenuItem<int>>((branch) {
            return DropdownMenuItem<int>(
              value: branch.bid,
              child: Container(
                width: double.infinity,
                child: Text(
                  branch.branchName ?? 'No Name',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedBranchId = value;
              });
              _loadStaffByBranch(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStaffDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name Of Staff', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedStaffId == 0 ? null : selectedStaffId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select Staff',
          ),
          isExpanded: true,
          items: feList.map<DropdownMenuItem<int>>((staffMember) {
            return DropdownMenuItem<int>(
              value: staffMember.feId,
              child: Container(
                width: double.infinity,
                child: Text(
                  staffMember.feName ?? 'No Name',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedStaffId = value;
              });
              _loadCentersByStaff(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMeetingTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type of Meeting', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedMeetingTypeId == 0 ? null : selectedMeetingTypeId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select Meeting Type',
          ),
          isExpanded: true,
          items: meetingTypes.map<DropdownMenuItem<int>>((meetingType) {
            return DropdownMenuItem<int>(
              value: meetingType.id,
              child: Container(
                width: double.infinity,
                child: Text(
                  meetingType.typeOfMeet,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMeetingTypeId = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilterSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Center Filter', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: [
            RadioListTile<int>(
              title: const Text('All'),
              value: 0,
              groupValue: selectedFilterType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedFilterType = value!;
                });
                if (selectedStaffId > 0) {
                  _loadCentersByStaff(selectedStaffId);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('Pending'),
              value: 1,
              groupValue: selectedFilterType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedFilterType = value!;
                });
                if (selectedStaffId > 0) {
                  _loadCentersByStaff(selectedStaffId);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('More than 3 Months'),
              value: 2,
              groupValue: selectedFilterType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedFilterType = value!;
                });
                if (selectedStaffId > 0) {
                  _loadCentersByStaff(selectedStaffId);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCenterSearchDialog() async {
    final selected = await showDialog<CenterMonitorResponse>(
      context: context,
      builder: (BuildContext context) {
        List<CenterMonitorResponse> filteredCenters = List.from(centers);
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Search Center'),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type to search centers...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredCenters = List.from(centers);
                          } else {
                            filteredCenters = centers
                                .where((center) => center.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredCenters.isEmpty
                          ? const Center(
                              child: Text('No centers found'),
                            )
                          : ListView.builder(
                              itemCount: filteredCenters.length,
                              itemBuilder: (context, index) {
                                final center = filteredCenters[index];
                                return ListTile(
                                  title: Text(center.name),
                                  selected: selectedCenterId == center.id,
                                  selectedTileColor: Colors.blue.withOpacity(0.1),
                                  onTap: () {
                                    Navigator.pop(context, center);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedCenterId = selected.id;
        _centerSearchController.text = selected.name;
      });
      _loadGroupsByCenter(selected.id);
    }
  }

  Widget _buildCenterDropdown() {
    return Column(
      key: _centerFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Center Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _centerSearchController,
          readOnly: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Tap to search and select center',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _centerSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        selectedCenterId = 0;
                        _centerSearchController.clear();
                        selectedGroupIds.clear();
                        groups.clear();
                        members.clear();
                        memberObservations.clear();
                        memberPhotos.clear();
                        memberSelected.clear();
                        _groupObservationController.clear();
                        _centerObservationController.clear();
                      });
                    },
                  )
                : null,
          ),
          onTap: () {
            if (selectedStaffId == 0) {
              _showError('Please select staff first to load centers');
            } else if (isLoading) {
              _showError('Loading centers, please wait...');
            } else if (centers.isEmpty) {
              _showError('No centers available for selected staff');
            } else {
              _showCenterSearchDialog();
            }
          },
        ),
      ],
    );
  }

  Widget _buildGroupSelection() {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Groups', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: groups.map((group) {
              return CheckboxListTile(
                title: Text(group.name),
                value: selectedGroupIds.contains(group.id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedGroupIds.add(group.id);
                    } else {
                      selectedGroupIds.remove(group.id);
                    }
                  });
                  _loadMembersByGroups(selectedGroupIds);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Members', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Checkbox(
              value: members.isNotEmpty && members.every((member) => memberSelected[member.id] == true),
              onChanged: (value) {
                setState(() {
                  for (var member in members) {
                    memberSelected[member.id] = value == true;
                  }
                });
              },
            ),
            const Text('Select All'),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                member.relativeName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: memberSelected[member.id] ?? true,
                          onChanged: (value) {
                            setState(() {
                              memberSelected[member.id] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Member Observation',
                        border: OutlineInputBorder(),
                      ),
                      // maxLines: 3,
                      onChanged: (value) {
                        memberObservations[member.id] = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          onPressed: () => _pickImage(member.id),
                        ),
                        const SizedBox(width: 8),
                        if (memberPhotos[member.id] != null)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    if (memberPhotos[member.id] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            memberPhotos[member.id]!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildObservationFields() {
    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Group Observation (Required)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _groupObservationController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter group observation',
          ),
          // maxLines: 3,
        ),
        const SizedBox(height: 16),
        const Text('Center Observation (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _centerObservationController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter center observation',
          ),
          // maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    if (members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitMonitoring,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit', style: TextStyle(fontSize: 16)),
      ),
    );
  }
    Future _showSelectionDialog<T>(List<T> items, String title) async {
    
    if(items.isEmpty){
      return;
    }
  else { return showDialog(
    context: context,
    // barrierDismissible: T == OdMember,
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
                  // else if (item is OdMember) {
                  //   return ListTile(
                  //     title: Text('${item.memberName} W/O ${item.spouse}'),
                  //     onTap: () => Navigator.pop(context, item),
                  //   );
                  // }
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
