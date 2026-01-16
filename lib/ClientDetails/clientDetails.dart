import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';

class Clientdetails extends StatefulWidget {
  const Clientdetails({super.key});

  @override
  State<Clientdetails> createState() => _ClientdetailsState();
}

class _ClientdetailsState extends State<Clientdetails> {
  final DioClient _client = DioClient();

  List branches = [], centers = [], groups = [], clients = [];
  int? selectedBranch, selectedCenter, selectedGroup, selectedClient;
  Map<String, dynamic>? clientDetails;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  // Fetch branches
  Future<void> fetchBranches() async {
    var data = await _client.getBranches();
    setState(() {
      branches = data;
    });
  }

  // Fetch centers when branch is selected
  Future<void> fetchCenters(int branchId) async {
    var data = await _client.getCenters(branchId);
    setState(() {
      centers = data;
      selectedCenter = null;
      groups = [];
      clients = [];
      clientDetails = null;
    });
  }

  // Fetch groups when center is selected
  Future<void> fetchGroups(int centerId) async {
    var data = await _client.getGroups(centerId);
    setState(() {
      groups = data;
      selectedGroup = null;
      clients = [];
      clientDetails = null;
    });
  }

  // Fetch clients when group is selected
  Future<void> fetchClients(int groupId) async {
    var data = await _client.getClients(groupId);
    setState(() {
      clients = data;
      selectedClient = null;
      clientDetails = null;
    });
  }

  // Fetch client details when client is selected
  Future<void> fetchClientDetails(int clientId) async {
    var data = await _client.getClientDetails(clientId);
    setState(() {
      clientDetails = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Client Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch Dropdown
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(labelText: "Select Branch"),
                value: selectedBranch,
                items: branches.map((b) {
                  return DropdownMenuItem<int>(
                    value: b["BID"],
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(b["BRANCHNAME"])),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedBranch = val);
                  fetchCenters(val!);
                },
              ),
              SizedBox(height: 16),
        
              // Center Dropdown
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(labelText: "Select Center"),
                value: selectedCenter,
                items: centers.map((c) {
                  return DropdownMenuItem<int>(
                    value: c["CENTERID"],
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(c["CENTERNAME"],))),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedCenter = val);
                  fetchGroups(val!);
                },
              ),
              SizedBox(height: 16),
        
              // Group Dropdown
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(labelText: "Select Group"),
                value: selectedGroup,
                items: groups.map((g) {
                  return DropdownMenuItem<int>(
                    value: g["id"],
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(g["groupName"],)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedGroup = val);
                  fetchClients(val!);
                },
              ),
              SizedBox(height: 16),
        
              // Client Dropdown
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(labelText: "Select Client"),
                value: selectedClient,
                items: clients.map((c) {
                  return DropdownMenuItem<int>(
                    value: c["id"],
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(c["Name"])),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedClient = val);
                  fetchClientDetails(val!);
                },
              ),
              SizedBox(height: 16),
        
              // Client Details
              clientDetails != null
              ? Card(
                  elevation: 4,
                  margin: EdgeInsets.only(top: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Client Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        ...clientDetails!.entries.map((entry) {
                          return entry.value != null && entry.value.toString().trim().isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "${entry.key}: ${entry.value}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : SizedBox.shrink(); // Hides empty/null values
                        }).toList(),
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
