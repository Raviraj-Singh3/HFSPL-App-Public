import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';

final DioClient _client = DioClient();

  Future<List<ActiveFeModel>> getFeListFromBranchId(int branchId)async {
    try {
      var response = await _client.getAllActiveFe(branchId);
      return response;
    } catch (e) {
      throw Exception(e);
    } 
  }