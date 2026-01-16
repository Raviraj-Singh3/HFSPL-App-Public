import 'package:HFSPL/Demand&Collection.dart/shimmer_loading.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/demand_collection_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemandCollection extends StatefulWidget {
  const DemandCollection({super.key});

  @override
  State<DemandCollection> createState() => _DemandCollectionState();
}

class _DemandCollectionState extends State<DemandCollection> {
  final DioClient _client = DioClient();
  DemandCollectionModel? demandCollectionResponse;
  double? collectionPercentage;
  List <BranchData>? branchData;
  bool isLoading = true;


  List<BranchData> filteredBranches = [];
  List<BranchData> selectedBranches = [];

  void _getDemandCollection() async {
    // context.loaderOverlay.show();
    setState(() {
      demandCollectionResponse = null;
      isLoading = true;
    });
    
    try {
      var response = await _client.getDemandCollection(int.parse(Global_uid));
      setState(() {
        demandCollectionResponse = response;
        collectionPercentage = (response.totalSumOfDemand! > 0)
            ? (response.totalSumOfCollection! / response.totalSumOfDemand!) * 100
            : 0.0;
        branchData = response.branchWiseData ?? [];
      });
      _applySavedFilters();
    } catch (e) {
      // print("Error fetching data: $e");
      showMessage(context, "$e");
    }
    // context.loaderOverlay.hide();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _applySavedFilters() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? savedBranchIds = prefs.getStringList('selected_branch_ids');

  if (savedBranchIds != null) {
    setState(() {
      selectedBranches = branchData!.where((branch) => savedBranchIds.contains(branch.branchID.toString())).toList();
    });
  }
}

  Future<void> _saveSelectedBranches() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> branchIds = selectedBranches.map((branch) => branch.branchID!.toString()).toList();
  await prefs.setStringList('selected_branch_ids', branchIds);

}

  @override
  void initState() {
    _getDemandCollection();
    
    super.initState();
  }

  void _showBranchSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        TextEditingController searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModalState) {
            void _filterBranches(String query) {
              setModalState(() {
                filteredBranches = branchData!
                    .where((branch) =>
                        branch.branchName!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Branch",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: _filterBranches,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: branchData!.length,
                        itemBuilder: (context, index) {
                          var branch = branchData![index];
                          bool isSelected = selectedBranches
                              .any((b) => b.branchID == branch.branchID);
                          return ListTile(
                            title: Text(branch.branchName!),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.check_circle_outline),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedBranches.removeWhere(
                                      (b) => b.branchID == branch.branchID);
                                } else {
                                  selectedBranches.add(branch);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _saveSelectedBranches();
                        setState(() {}); // Update the main screen with selections
                        Navigator.pop(context);
                      },
                      child: Text("Done"),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demand & Collection"),

      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _getDemandCollection,
        ),
      ],
      ),
      body: isLoading
              ? buildShimmerLoading()
              : (demandCollectionResponse == null || (demandCollectionResponse?.branchWiseData?.isEmpty ?? true))
                  ? const Center(child: Text("No data found"))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Demand & Collection Summary",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryCard("Total Demands", Text("${demandCollectionResponse!.totalNumberOfDemand}"), Icons.assignment, Colors.orange),
                                  SizedBox(width: 10,),
                                  Flexible(child: _summaryCard("Total Collections", Text("${demandCollectionResponse!.totalNumberOfCollection}"), Icons.check_circle, Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryCard("Demand Amount", Text("₹${demandCollectionResponse!.totalSumOfDemand}"), Icons.currency_rupee, Colors.red),
                                  SizedBox(width: 10,),
                                  Flexible(
                                    child: _summaryCard("Collection Amount",
                                      Text("₹${demandCollectionResponse!.totalSumOfCollection} (${collectionPercentage?.toStringAsFixed(2)}%)", textAlign: TextAlign.center,
                                      // Column(
                                      // // crossAxisAlignment: CrossAxisAlignment.center,
                                      // children: [
                                      //   Text("₹${demandCollectionResponse!.totalSumOfCollection}"),
                                      //     Text(
                                      //         "${collectionPercentage?.toStringAsFixed(2)}% Collected",
                                      //         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      //       ),
                                      // ],
                                    ), Icons.currency_rupee,
                                      Colors.blue,),
                                  ),
                                  // _summaryCard(
                                  //   "Collection Amount",
                                  //   Column(
                                  //     children: [
                                  //       Text("₹${demandCollectionResponse!.totalSumOfCollection}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  //       const SizedBox(height: 4),
                                  //       Text(
                                  //         "${collectionPercentage?.toStringAsFixed(2)}% Collected",
                                  //         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   Icons.currency_rupee,
                                  //   Colors.blue,
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                    InkWell(
                    onTap: _showBranchSelectionModal,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Select Branches",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (selectedBranches.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: selectedBranches.map((branch) {
                            return Chip(
                              label: Text('${branch.branchName}'),
                              backgroundColor: Colors.blue.shade50,
                              deleteIcon: const Icon(Icons.cancel, size: 18),
                              onDeleted: () {
                                setState(() {
                                  selectedBranches.remove(branch);
                                });
                                _saveSelectedBranches();
                              },
                            );
                          }).toList(),
                        ),
                  SizedBox(height: 10),

                  // Branch-wise Data Section
                  // const Text(
                  //   "Branch-wise Demand & Collection",
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  // ),
                  // const SizedBox(height: 8),


                  ListView.builder(
                    
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedBranches.isNotEmpty ? selectedBranches.length : branchData?.length ?? 0,
                    itemBuilder: (context, index) {
                      var branch = selectedBranches.isNotEmpty ? selectedBranches[index] : branchData![index];
                      double branchPercentage = branch.sumOfDemand! > 0 ? (branch.sumOfCollection! / branch.sumOfDemand!) * 100 : 0.0;

                      double? odCollection;

                      if (branch.sumOfDemand == 0 && branch.sumOfCollection! > 0) {
                         odCollection = branch.sumOfCollection!;
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.2),
                            child: Icon(Icons.location_city, color: Colors.blueAccent),
                          ),
                          title: Text(branch.branchName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Demand: ₹${branch.sumOfDemand}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),

                              if (odCollection != null) Text("OD Collection: ₹$odCollection", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))
                              else Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Collection: ₹${branch.sumOfCollection}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                                  Text("${branchPercentage.toStringAsFixed(2)}% Collected", style: TextStyle(color: Colors.grey[600])),

                                ],
                              ),
                              
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // // Refresh Button
                  // const SizedBox(height: 20),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     icon: const Icon(Icons.refresh),
                  //     label: const Text("Refresh Data"),
                  //     onPressed: _getDemandCollection,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blueAccent,
                  //       padding: const EdgeInsets.symmetric(vertical: 14),
                  //       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, Widget value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42, // Responsive width
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          value
        ],
      ),
    );
  }
}
