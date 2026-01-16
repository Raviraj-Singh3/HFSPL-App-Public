import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:HFSPL/network/connectivity_interceptor.dart';
import '../state/kyc_state.dart';
import 'package:HFSPL/network/responses/Additional%20pages%20response/non_verified_members.dart';
import 'package:HFSPL/network/responses/Collection-Calling/collection_calling_response_model.dart';
import 'package:HFSPL/network/responses/Greivance/greivance_response_model.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_details_model.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_history_model.dart';
import 'package:HFSPL/network/responses/LeaveResponse/reporting_person_model.dart';
import 'package:HFSPL/network/responses/Login/login_model.dart';
import 'package:HFSPL/network/responses/NotificationModel/attendance_update_model.dart';
import 'package:HFSPL/network/responses/NotificationModel/getnotification_model.dart';
import 'package:HFSPL/network/responses/OD/member_past_visit_details_model.dart';
import 'package:HFSPL/network/responses/OD/od_branchwise_response.dart';
import 'package:HFSPL/network/responses/OD/od_calling_remark_response_model.dart';
import 'package:HFSPL/network/responses/OD/od_group_list.dart';
import 'package:HFSPL/network/responses/ODMODEL/od_total_model.dart';
import 'package:HFSPL/network/responses/Offer%20Response/lead_details_response.dart';
import 'package:HFSPL/network/responses/Offer%20Response/mobile_response.dart';
import 'package:HFSPL/network/responses/Offer%20Response/offer_response_model.dart';
import 'package:HFSPL/network/responses/PhonePayResponse/phonepay_response_model.dart';
import 'package:HFSPL/network/responses/Today_overdue/today_overdue_response_model.dart';
import 'package:HFSPL/network/responses/demand_collection_model.dart';
import 'package:HFSPL/network/responses/fe_wise_demand_collection_model.dart';
import 'package:HFSPL/network/responses/user_roles_response.dart';
import 'package:HFSPL/network/safe_api_call.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_members_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_saved_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_snapshots_model.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/network/responses/AuditModel/groups_model.dart';
import 'package:HFSPL/network/responses/Collection/demand_model.dart';
import 'package:HFSPL/network/responses/Collection/group_model.dart';
import 'package:HFSPL/network/responses/FaceMatch/face_match.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_response.dart';
import 'package:HFSPL/network/responses/OCR/ocr_response_model.dart';
import 'package:HFSPL/network/responses/ReviewKyc/rejected_members_model.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_group.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_members.dart';
import 'package:HFSPL/network/responses/VoterCard/voter_card_model.dart';
import 'package:HFSPL/network/responses/aadhar/otpresponse_model.dart';
import 'package:HFSPL/network/responses/aadhar_model.dart';
import 'package:HFSPL/network/responses/cgt/cgt_model.dart';
import 'package:HFSPL/network/responses/cgt/clientwithBankDetails.dart';
import 'package:HFSPL/network/responses/cgt/hm_model.dart';
import 'package:HFSPL/network/responses/cgt/loan_tenure_model.dart';
import 'package:HFSPL/network/responses/cgt/model_get_cgt_by_id.dart';
import 'package:HFSPL/network/responses/grt/grt_by_id_model.dart';
import 'package:HFSPL/network/responses/kyc/renewal_mtl_model.dart';
import 'package:HFSPL/network/responses/kyc/snapshot_model/snapshot_model.dart';
import 'package:HFSPL/utils/globals.dart';

import 'responses/Attendance/attendance_model.dart';
import 'responses/center_model/center_model.dart';
import 'responses/center_model/group_list.dart';
import 'responses/kyc/kyc_additional_members.dart';
import 'responses/kyc/kyc_category_response.dart';
import 'responses/kyc/kyc_question_response.dart';
import 'responses/kyc/kyc_status.dart';
import 'responses/kyc/kyc_sub_category_response.dart';
import 'responses/kyc/post_kyc_model/post_kyc_model.dart';
import 'responses/kyc/post_kyc_model/question.dart';
import 'responses/otp_verify_response_modal.dart';
import 'package:HFSPL/network/responses/Funder/funder_details_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_branch_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_center_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_member_response.dart';
import 'package:HFSPL/network/responses/Additional%20pages%20response/non_verified_groups.dart';
import 'package:HFSPL/network/responses/Offer Response/gold_loan_response.dart';
import 'package:HFSPL/network/responses/app_version.dart';
import 'package:HFSPL/network/responses/center_monitoring/meeting_type_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/center_monitor_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/group_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/member_response.dart';
import 'package:HFSPL/network/responses/center_monitoring/submit_monitoring_response.dart';
import 'package:HFSPL/network/responses/dde/dde_eligible_member_model.dart';
import 'package:HFSPL/network/responses/dde/dde_assigned_model.dart';
import 'package:HFSPL/network/responses/dde/verification_eligible_member_model.dart';
import 'package:HFSPL/network/requests/dde_request_models.dart';

class DioClient {
  DioClient() {
    _dio.options.headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };
    addInterceptor(ConnectivityInterceptor());
    addInterceptor(LogInterceptor(requestBody: true, responseBody: true));
    setAuthHeaders(Global_LoginId, Global_token, Global_Password);
    
  }

  final Dio _dio = Dio();

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

   // Set Authorization Header Once at Initialization
  void setAuthHeaders(String username, String token, String password) {
    if (username.isNotEmpty && token.isNotEmpty) {
      String rawAuth = "$username---$token:$password";
      String encodedAuth = base64Encode(utf8.encode(rawAuth));

      _dio.options.headers['Authorization'] = "Basic $encodedAuth";
    }
  }

  Future<String> getImage(String imageUrl) async {
    // Perform the HTTP request
    final Response<List<int>> response = await _dio.get<List<int>>
    (
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      // Image bytes are in response.data
      final List<int> imageBytes = response.data!;

      // Convert to base64
      return base64Encode(imageBytes);
    } else {
      // Handle error
      throw Exception('Failed to get $imageUrl');
    }
  }


  final baseurl = 'http://localhost:59506';//local

// Server API -----------------------------------

final isIndividual = KycState().isIndividual;
final loanTypeId = KycState().loanTypeId;

  Future<String> generateOtp(String mobileNumber) async {
    try {
      final response = await _dio
          .post('$baseurl/api/ClientApp/Auth/loginByMobile?Mobile=$mobileNumber');
      
        return response.data;
      // return "Otp sent on testing 11******11";
    } catch (e) {
      
      if (e is DioException) {
        throw e.response?.data;
      }
      throw Exception('error');
    }
  }

  Future<VerifyOtpResponse> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/Auth/validateOtp?OTP=$otp&Mobile=$mobileNumber');

      return VerifyOtpResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {}
        throw e.response?.data;
      }
      throw Exception('error');
    }
  }

  Future<List<SnapshotModel>> loadIndivisualSnapshot() async {
    try {
      final response = await _dio.get(
          '$baseurl/api/ClientApp/IndividualKyc/GetSnapshotList?UserId=$Global_uid&loanType=$loanTypeId');
      return SnapshotModel.listFromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {}
        throw e.response?.data;
      }
      throw Exception('error');
    }
  }

  Future<List<SnapshotModel>> loadGroupSnapshot(int groupId) async {
    // return loadIndivisualSnapshot();
    try {
      final response =
          await _dio.post('$baseurl/api/KYC/ListSnapshot?groupId=$groupId');
      return SnapshotModel.listFromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {}
        throw e.response?.data;
      }
      throw Exception('error');
    }
  }

  Future<SnapshotModel> createIndividualSnapshot(
      String userId, String villageId, String snapshotName) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/CreateSnapshot?UserId=$userId&SnapShotName=$snapshotName&VillageId=$villageId&loanType=$loanTypeId');
      return SnapshotModel.listFromJson(response.data)[0];
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {}
        throw e.response?.data["Message"];
      }
      throw Exception('Offline/getCenterGroupV2?error $e');
    }
  }

  Future<SnapshotModel> createGroupSnapshot(
      int groupId, String snapshotName) async {
      return safeApiCall(() async {
      final response = await _dio.post('$baseurl/api/KYC/AddMemberSnapshot?groupId=$groupId&SnapshotName=$snapshotName');
      return SnapshotModel.listFromJson(response.data).last;
  });
    // try {
    //   final response = await _dio.post(
    //       '$baseurl/api/KYC/AddMemberSnapshot?groupId=$groupId&SnapshotName=$snapshotName');
    //       print("response.data ${response.data}");
    //   return SnapshotModel.listFromJson(response.data).last;
    // } catch (e) {
    //   if (e is DioException) {
    //     if (e.response?.statusCode == 400) {}
    //     throw e.response?.data["Message"];
    //   }
    //   throw Exception('Offline/getCenterGroupV2?error $e');
    // }
  }

  Future<VerifyOtpResponse> updateprofile(
      String token, String uid, String name) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/Auth/updateName?token=$token&uid=$uid&name=$name');

      if (response.statusCode == 200) {
        return VerifyOtpResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to post');
      }
    } catch (e) {
      throw Exception('error');
    }
  }

  //-----------------KYC-------------------//

  Future<List<KycCategory>> getKycCategoryIndividual(int snapshotId) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/CategoryList?snapshotId=$snapshotId&loanType=$loanTypeId');
      return KycCategory.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycCategory>> getKycCategory(int snapshotId) async {
    try {
      final response = await _dio
          .post('$baseurl/api/KYC/CategoryList?snapshotId=$snapshotId');
      return KycCategory.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> getAdditionalMembersIndividual(
      int snapshotId) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/GetAllAdditionalMembers?snapshotid=$snapshotId');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> getAdditionalMembers(int snapshotId) async {
    // return getAdditionalMembersIndividual(snapshotId);
    try {
      final response = await _dio.post(
          '$baseurl/api/KYC/GetAllAdditionalMembers?snapshotid=$snapshotId');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> addAdditionalMemberIndividual(
      int snapshotId, String memberName) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/AddAdditionalMemberSnapshot?snapshotId=$snapshotId&MemberName=$memberName');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> addAdditionalMember(
      int snapshotId, String memberName) async {
    // return addAdditionalMemberIndividual(snapshotId, memberName);
    try {
      final response = await _dio.post(
          '$baseurl/api/KYC/AddAdditionalMemberSnapshot?snapshotId=$snapshotId&MemberName=$memberName');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> updateNomineeIndividual(
      int snapshotId, int nomineeid) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/updateNominee?snapshotid=$snapshotId&nomineeid=$nomineeid');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycAdditionalMember>> updateNominee(
      int snapshotId, int nomineeid) async {
    // return updateNomineeIndividual(snapshotId, nomineeid);
    try {
      final response = await _dio.post(
          '$baseurl/api/KYC/UpdateNominee?snapshotid=$snapshotId&nomineeid=$nomineeid');
      return KycAdditionalMember.listFromJson(response.data);
    } catch (e) {
      throw Exception('error');
    }
  }

  Future<List<KycSubCategory>> getKycSubCategories(int catId) async {
    return safeApiCall(() async {
      var response = await _dio.post(isIndividual ? '$baseurl/api/ClientApp/IndividualKyc/SubCategoryList?catId=$catId' : '$baseurl/api/KYC/SubCategoryList?catId=$catId');
      return KycSubCategory.listFromJson(response.data);
    });
  }

  Future<List<KycQuestion>> getKycQuestions(
      int catId, int subCatid, int snapshotId, int? additionalMemberId) async {
    try {
      final response = await _dio.post(
        isIndividual
            ? '$baseurl/api/ClientApp/IndividualKyc/GetQuestions?catId=$catId&snapshotId=$snapshotId&subcatId=$subCatid&additionalMemberId=$additionalMemberId&loanType=$loanTypeId'
            :
              '$baseurl//api/KYC/GetQuestions?catId=$catId&snapshotId=$snapshotId&subcatId=$subCatid&additionalMemberId=$additionalMemberId');
      return KycQuestion.listFromJson(response.data);
    } catch (e) {
      throw Exception('error $e');
    }
  }

  Future<String> postKyc(
      int catId,
      int subCatid,
      int snapshotId,
      int? additionalMemberId,
      List<SavedQuestion> answers,
      Map<int, File> mediaFileList) async {
    return safeApiCall(() async {
      var data = PostKycModel(
              questionCategoryId: catId,
              snapshotId: snapshotId,
              questionSubCategoryId: subCatid,
              additionalSnapshotId: additionalMemberId,
              questions: answers)
          .toJson();
      FormData formData = FormData();
      for (var map in mediaFileList.entries) {
        // Get file extension
        String filePath = map.value.path;
        String extension = filePath.split('.').last.toLowerCase();
        
        // Set appropriate filename based on extension
        String filename = 'file${map.key}.$extension';
        
        formData.files.add(MapEntry(
          map.key.toString(),
          await MultipartFile.fromFile(
            map.value.path,
            filename: filename,
          ),
        ));
      }
      formData.fields.add(MapEntry('listAdded', data));
      final response = await _dio.post(
          isIndividual
              ? '$baseurl/api/ClientApp/IndividualKyc/SaveKycModel'
              :
                '$baseurl/api/KYC/SaveKycModel',
          data: formData);
      return response.data as String;
    });
  }

  Future<String> completeSnapshot(int snapshotId) async {
    try {
      
      final response = await _dio.post(isIndividual
          ? '$baseurl/api/ClientApp/IndividualKyc/CompleteSnapshot?snapshotId=$snapshotId&loanType=$loanTypeId'
          : '$baseurl/api/KYC/CompleteSnapshot?snapshotId=$snapshotId');
      return response.data as String;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw e.response?.data["Message"];
        }
      }
      throw Exception('error $e');
    }
  }

  Future<List<KycStatus>> getKycStatus(int snapshotId) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/ClientApp/IndividualKyc/getKycStatus?snapshotid=$snapshotId&loanType=$loanTypeId');
      Global_kycStatusList = KycStatus.listFromJson(response.data);
      return Global_kycStatusList;
    } catch (e) {
      throw Exception('error $e');
    }
  }

  Future<List<CenterModel>> getCentersByUserId(String userId) async {
    try {
      final response = await _dio
          .get('$baseurl/api/Offline/getCenterGroupV2?userId=$userId');
      return CenterModel.listFromJson(response.data);
    } catch (e) {
      throw Exception('Offline/getCenterGroupV2?error $e');
    }
  }

  Future<List<HmModel>> getHmResult(String userId) async {
    try {
      final response =
          await _dio.post('$baseurl/api/stores/GetHmResult?userId=$userId');

      // Parsing the response to List<HmModel>
      List<HmModel> result = (response.data as List)
          .map((json) => HmModel.fromJson(json))
          .toList();
      return result;
    } catch (e) {
      throw Exception('api/stores/GetHmResult?userId $e');
    }
  }

  Future<List<CGTModel>> getCGT(String loginID) async {
    try {
      final response =
          await _dio.post('$baseurl/api/stores/getCGT2?loginID=$loginID');

      List<CGTModel> result = (response.data as List)
          .map((json) => CGTModel.fromJson(json))
          .toList();

      return result;
    } catch (e) {
      throw Exception('api/stores/getCGT2?loginID $e');
    }
  }

  Future<List<CGTById>> getCGTById(String cgtId) async {
    try {
      final response =
          await _dio.post('$baseurl/api/stores/getCGT2ById?cgtId=$cgtId');
      return CGTById.listFromJson(response.data);
    } catch (e) {
      throw Exception('api/stores/getCGT2ById?cgtId $e');
    }
  }

  Future<CenterModel> createCenter(data) async {
    try {
      final response = await _dio.post('$baseurl/api/KYC/AddCenter', data: jsonEncode(data));
      return CenterModel.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw e.response?.data["Message"];
        }
      }
      throw Exception('Offline/getCenterGroupV2?error $e');
    }
  }

  Future<GroupModel> createGroup(

    String userId, String centerId, String groupName) async {

    return safeApiCall(() async {
    final response = await _dio.post('$baseurl/api/KYC/AddGroup', data: [
        {"GroupName": groupName, "Uid": userId, "CenterId": centerId}
      ]);
      return GroupModel.fromMap(response.data);
  });
    // try {
    //   final response = await _dio.post('$baseurl/api/KYC/AddGroup', data: [
    //     {"GroupName": groupName, "Uid": userId, "CenterId": centerId}
    //   ]);
    //   return GroupModel.fromMap(response.data);
    // } catch (e) {
    //   if (e is DioException) {
    //     if (e.response?.statusCode == 400) {
    //       throw e.response?.data["Message"];
    //     }
    //   }
    //   throw Exception('AddGroup?error $e');
    // }
  }

  Future<String> requestPostCGT(requestPostCGT) async {
    try {
      final response = await _dio.post(
        '$baseurl/api/stores/postCGT2',
        data:
            jsonEncode(requestPostCGT.toJson()), // Convert request body to JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer your_auth_token', // Add authorization header if required
          },
        ),
      );
      // return RequestPostCGT.fromMap(response.data);
      return "Success";
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw e.response?.data["Message"];
        }
      }
      throw Exception('api/stores/postCGT2 $e');
    }
  }

  Future<List<dynamic>> getVillageListByUserid(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Offline/getvilllist?userId=$userId');
      return response.data as List;
    });
    // try {
    //   final response =
    //       await _dio.get('$baseurl/api/Offline/getvilllist?userId=$userId');
    //   // return jsonDecode(response.data) as List;
    //   return response.data as List;
    // } catch (e) {
    //   throw Exception('Offline/getvilllist?error $e');
    // }
  }

  Future<int> resendOtp(String clientId) async {
    try {
      final response =
          await _dio.get('$baseurl/api/Verification/ReSendOtpClient?clientId=$clientId');
      // return jsonDecode(response.data) as List;
      return response.data as int;
    } catch (e) {
      throw Exception('Verification/ReSendOtpClient?error $e');
    }
  }

  
  Future<String> submitOtp(String clientId,String otp) async {
    try {
      final response =
          await _dio.get('$baseurl/api/Verification/verifyOtpClient?clientId=$clientId&otp=$otp');
      // return jsonDecode(response.data) as List;
      return response.data as String;
    } catch (e) {
      throw Exception('Verification/verifyOtpClient?error $e');
    }
  }


  Future postCGT (items) async {
    try {
      final response = await _dio.post(
         '$baseurl/api/stores/postCGT2',
         data: jsonEncode(items),
       );
       return response;
    }  
  catch(e){
    if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw e.response?.data["Message"];
        }
      }
    throw Exception('baseurl/api/stores/postCGT2 $e');
  }
}
  Future<List<GRTById>> getUserGRT (String userId) async {
    return safeApiCall(() async {
      final response = await _dio.get(
         '$baseurl/api/GrtApp/GetUserGrtBranches?userid=$userId',
       );
       List<GRTById> result = GRTById.listFromJson(response.data);
      return result;
    });
  //   try {
  //     final response = await _dio.get(
  //        '$baseurl/api/GrtApp/GetUserGrtBranches?userid=$userId',
  //      );
  //      List<GRTById> result = GRTById.listFromJson(response.data);
  //     return result;
  //   }  
  // catch(e){
  //   throw Exception('baseurl/GrtApp/GetUserGrtBranches $e');
  // }
}

Future<List<GRTById>> getGRTById(grtId) async {
    try {
      final response =
          await _dio.post('$baseurl/api/GrtApp/GetUserGrtById', data: jsonEncode(grtId));
      return GRTById.listFromJson(response.data);
    } catch (e) {
       if (e is DioException) {
          throw e.response?.data["Message"];
      }
      throw Exception('baseurl/api/GrtApp/GetUserGrtById $e');
    }
  }

  Future postPreGRT (items) async {
    return safeApiCall(() async {
      final response = await _dio.post(
         '$baseurl/api/GrtApp/PostPreGRT',
         data: items,
       );
       return response;
    });
  //   try {
  //     final response = await _dio.post(
  //        '$baseurl/api/GrtApp/PostPreGRT',
  //        data: items,
  //      );
  //      return response;
  //   }  
  // catch(e){
  //   throw Exception('baseurl/api/GrtApp/PostPreGRT $e');
  // }
}

Future postGRT (items) async {
    try {
      final response = await _dio.post(
         '$baseurl/api/GrtApp/PostGRT',
         data: items,
       );
       return response;
    }  
  catch(e){
    if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw e.response?.data["Message"];
        }
      }

      throw Exception('GRT Failled : $e');
      
    // throw Exception('baseurl/api/GrtApp/PostGRT $e');
  }
}

  Future<String> postGRTImages(
      String memberCgtId,
      String additionalTag,
      String latitude,
      String longitude,
      File imageFile,
      String fileName
      ) async {
    try {
      
      // Create FormData object
      FormData formData = FormData();
      // Add file to FormData
       formData.files.add(MapEntry(
          "${memberCgtId}_${additionalTag}_${latitude},$longitude",
          await MultipartFile.fromFile(
            imageFile.path,
            filename:fileName, // Adjust the filename as needed
          ),
        ));

      final response = await _dio.post(
          '$baseurl/api/GrtApp/PostGRT',
          data: formData);
      return response.data as String;
    } catch (e) {
      if (e is DioException) {
        throw e.response?.data["Message"] as String;
      } else {
        throw "Something went wrong";
      }
    }
  }

  Future<List<Group>> collectionGroupsByDate(int feId, String date, bool asPerSchedule) async {
    return safeApiCall(() async {
      final response = await _dio.post(
          '$baseurl/api/Collection/GetGroupsByDate?feId=$feId&date=$date&AsPerSchedule=$asPerSchedule');
      // print("collection get groups by date ${response.data}");
      List<Group> result = Group.listFromJson(response.data);
      return result;
    });
    // try {
    //   final response = await _dio.post(
    //       '$baseurl/api/Collection/GetGroupsByDate?feId=$feId&date=$date&AsPerSchedule=$asPerSchedule');
    //   // print("collection get groups by date ${response.data}");
    //   List<Group> result = Group.listFromJson(response.data);
    //   return result;
    // } catch (e) {
    //   throw Exception('error $e');
    // }
      }

  Future<GroupDemandData> getDemand(int feId, String date, int groupId, bool asPerSchedule) async {
    try {
      final response = await _dio.post(
          '$baseurl/api/Collection/GetDemand?feId=$feId&date=$date&groupId=$groupId&AsPerSchedule=$asPerSchedule');
      // print("collection get groups by date ${response.data}");
      return GroupDemandData.fromJson(response.data);
    } catch (e) {
      throw Exception('error $e');
    }
      }
  

  Future<String> postGroupImage(
      File imageFile,
      String fileName,
       data
      ) async {
    try {
      
      // Create FormData object
      FormData formData = FormData();
        // print("lat ${latitude} long ${longitude}");
      // Add file to FormData
       formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(
            imageFile.path,
            filename:fileName, // Adjust the filename as needed
          ),
        ));
        formData.fields.add(MapEntry('data', data));
        // print("data.. $data");

      final response = await _dio.post(
          '$baseurl/api/Collection/SubmitGroupDoc',
          data: formData);
          
      return response.data as String;
    } catch (e) {
      if (e is DioException) {
        throw e.response?.data["Message"] as String;
      } else {
        throw "Something went wrong";
      }
    }
  }

  Future postCollection (items) async {
    return safeApiCall(() async {
    
      final response = await _dio.post(
         '$baseurl/api/Collection/PostCollection',
         data: items,
       );
      return response.data;
    });
  
}


Future<List<AttendanceModel>> getAttendance (userId) async {
  return safeApiCall(() async {
    final response = await _dio.get(
         '$baseurl/api/Hr/GetAttendance?userId=$userId',
       );
       return AttendanceModel.listFromJson(response.data);
  });
}

Future getAddess(Position position) async {
  const String apiKey = "apikey";
  return safeApiCall(() async {
    final dioNoAuth = Dio();
    final response = await dioNoAuth.get(
      'https://us1.locationiq.com/v1/reverse.php',
      queryParameters: {
        'key': apiKey,
        'lat': position.latitude,
        'lon': position.longitude,
        'format': 'json',
      },
      options: Options(headers: <String, dynamic>{}),
    );
    return response.data;
  });
}

Future postAttendance(data) async {

  return safeApiCall(() async {
      final response = await _dio.post(
         '$baseurl/api/Hr/PostAttendance',
         data: jsonEncode(data)
       );
    return response;
    });
}

Future <OTPResponseModel> genAdharOTP(String aadhar, String caseId) async {

  var data = {
        "AadhaarNo": aadhar,
        "CaseId": caseId
      };

  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/GenerateKycOTP', data: jsonEncode(data));
    // print("response ... gen otp ${(response.data)}");
    return OTPResponseModel.fromJson(response.data);
  });
}

Future <AadharModel>submitAdharOtp(data) async {

  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/VerifyKycOTP', data: jsonEncode(data));
    // print("response ... of otp submit ${(response.data)}");
    return AadharModel.fromJson(response.data);
  });
}

Future <FaceMatchModel> tryFacematch(File clickedImage, File adharImage) async {
  // Convert images to MultipartFile
  FormData formData = FormData.fromMap({
    'clickedImage': await MultipartFile.fromFile(clickedImage.path, filename: 'clicked_image.jpg'),
    'adharImage': await MultipartFile.fromFile(adharImage.path, filename: 'adhar_image.jpg'),
  });
  return safeApiCall(() async {
    var response = await _dio.post(
      '$baseurl/api/KYC/FaceMatchFromAdhar',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
   return FaceMatchModel.fromJson(response.data);
  });
}

Future checkCibil(int id, int userid) async {
  return safeApiCall(() async {
    var response = await _dio.post(isIndividual
        ? '$baseurl/api/ClientApp/IndividualKyc/CheckCibil?snapshotId=$id&userId=$userid'
        :
          '$baseurl/api/KYC/CheckCibil?snapshotId=$id&userId=$userid');
    // print("response of cibil ${(response.data)}");
    return response.data;
  });
}

Future downloadReport(String memberName, String path) async {
  return safeApiCall(() async {
    var response = await _dio.get(isIndividual
        ? '$baseurl/api/ClientApp/IndividualKyc/DownloadReport?memberName=$memberName&path=$path'
        :
      '$baseurl/api/KYC/DownloadReport?memberName=$memberName&path=$path');
    return response.data;
  });
}

Future<List<LeaveModelResponse>> getLeaveBalance(String userId) {
  return safeApiCall(() async {
    final response =
        await _dio.get('$baseurl/api/Hr/GetLeaveBalance?userId=$userId');
    return LeaveModelResponse.listFromJson(response.data);
  });
}

Future<List<LeaveHistoryModel>> getLeaveHistory(String userId) async {

  return safeApiCall(() async {

    var response = await _dio.get('$baseurl/api/Hr/GetLeaveHistories?userId=$userId');

    return LeaveHistoryModel.listFromJson(response.data);
    
  });
}

Future<List<AttendanceModel>> getAttendanceHistory(int userId) async {

return safeApiCall(() async {
    final response = await _dio.get('$baseurl/api/Hr/GetMonthAttendanceHistory?userId=$userId');
    return AttendanceModel.listFromJson(response.data);
  });
}

Future <ClientAccountDetailsResponse> getClientWithBank(branchId, groupId, clientId, selectedTenure ) async {

  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/Operation/Account/GetFilledDetails?branchId=$branchId&groupId=$groupId&clientId=$clientId&selectedTenure=$selectedTenure');

    // print("response.. $response");
    return ClientAccountDetailsResponse.fromJson(response.data);
  });
}

Future <LoanTenureModel> getLoanTenure(clientId) async {

  return safeApiCall(() async {

    var response = await _dio.post('$baseurl/api/Operation/Account/GetLoanTenure?clientId=$clientId');

    return LoanTenureModel.fromJson(response.data);

  });
}


Future submitBankUpdate(data, File pickedFile, String filename) async {
  return safeApiCall(() async {
     FormData formData = FormData();
    formData.fields.add(MapEntry("data", jsonEncode(data)));
    formData.files.add(MapEntry(
        "file",
        await MultipartFile.fromFile(
          pickedFile.path,
          filename: filename, // Specify the filename
        ),
      ));
    var response = await _dio.post('$baseurl/api/Operation/Account/PostFillDetails', data: formData, options: Options(headers: {
      "Content-Type": "multipart/form-data",
    }));
    return response;
  });
}

Future <OCRResponseModel> getOCR(File pdfFile) async {

  FormData formData = FormData.fromMap({
  "file": await MultipartFile.fromFile(pdfFile.path),
  });

  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/PerfiosOcr', data: formData, options: Options(headers: {
    'Content-Type': 'multipart/form-data',
    }),);
    return OCRResponseModel.fromJson(response.data);
  });
}

  Future<List<ReviewGroupModel>> getPendingKycGroups(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/KYC/GetPendingReviewCenterGroups?userId=$userId');
      return ReviewGroupModel.listFromJson(response.data);
    });
  }

  Future<List<ReviewMembersModel>> getReviewKycMembers(int groupId) async {

    return safeApiCall(() async {
      
      var response = await _dio.post('$baseurl/api/KYC/GetPendingReviewMembers?groupId=$groupId');

      return ReviewMembersModel.listFromJson(response.data);

    });
  }

  Future<List<ReviewGroupModel>> getRejectedGroup(String userId) async {

    return safeApiCall(() async {

      var response = await _dio.post('$baseurl/api/KYC/GetKYCRejectedCenterGroups?userId=$userId');

      return ReviewGroupModel.listFromJson(response.data);
      
    });

  }

  Future<List<RejectedMembersModel>> getRejectedKycMembers(int groupId) async {

    return safeApiCall(() async {
      
      var response = await _dio.post('$baseurl/api/KYC/GetKYCRejectedMembers?groupId=$groupId');

      return RejectedMembersModel.listFromJson(response.data);

    });
  }

  Future updateRejectedPhoto(data, File image, String fileName) async {
    return safeApiCall(() async {
      FormData formData = FormData();

    // Add JSON data under the "data" field
    formData.fields.add(MapEntry("listAdded", jsonEncode(data)));

    formData.files.add(MapEntry(
        "file", // Key for the file is null when no field name is required
        await MultipartFile.fromFile(
          image.path,
          filename: fileName, // Specify the filename
        ),
      ));

      var response = await _dio.post('$baseurl/api/Images/UpdateRejectedPhoto',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
      });
  }

  Future getKycPhoto(clientId, clientCgtId, reason) async {

    return safeApiCall(() async {
      
      var response = await _dio.get('$baseurl/api/Images/GetRejectedPhoto?clientCgtId=$clientCgtId&clientId=$clientId&reason=$reason',
        options: Options(
        responseType: ResponseType.bytes, // Ensure we get binary data
      ),
      );

      Uint8List imageBytes = Uint8List.fromList(response.data);

      return imageBytes;

    });

  }

  Future rejectKyc(data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/KYC/RejectMemberPhotosByBranch', data: jsonEncode(data));
      return response.data;
      });
  }

  Future approveKyc(int clientId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/KYC/ApproveMemberPhotosByBranch?clientId=$clientId');
      return response.data;
    });
  }

  Future<List<AuditSnapshotModel>> getAuditSnapshots(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Audit/getAuditSnapshots?userId=$userId');
      return AuditSnapshotModel.listFromJson(response.data);
    });
  }

  Future<List<BranchModel>> getAllBranches(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveBranches?userId=$userId');
      return BranchModel.listFromJson(response.data);
    });
  }

  Future createAuditSnapshot(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Audit/CreateSnapshot', data: jsonEncode(data));
      return response.data;
    });
  }

  Future<List<AuditCategoryModel>> getAuditCategories(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Audit/getAuditCategories?userId=$userId');
      return AuditCategoryModel.listFromJson(response.data);
    });
  }

  Future postAudit(data)async{
    FormData formData = FormData();
    formData.fields.add(MapEntry('listAdded', data));
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Audit/postAuditSnapshots', data: formData);
      return response.data;
    });
  }

  Future<List<ActiveFeModel>> getAllActiveFe(int branchId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveFe?branchId=$branchId');
      return ActiveFeModel.listFromJson(response.data);
    });
  }

  Future<List<ActiveGroupsModel>> getAllActiveGroups(int feId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveGroups?feId=$feId');
      return ActiveGroupsModel.listFromJson(response.data);
    });
  }

   Future<List<ActiveGroupsModel>> getDisbGroups(int feId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getDisbGroups?feId=$feId');
      return ActiveGroupsModel.listFromJson(response.data);
    });
  }

  Future<List<AuditMembersModel>> getAllActiveMembers(int groupId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveDisbClients?groupId=$groupId');
      return AuditMembersModel.listFromJson(response.data);
    });
  }

  Future<List<SavedAuditResponseModel>> getAuditSavedData(data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Audit/getAuditSavedData',data: jsonEncode(data));
      return SavedAuditResponseModel.listFromJson(response.data);
    });
  }

  Future endAudit(int snapshotId, String userId)async {
    return safeApiCall(() async {
       var response = await _dio.post('$baseurl/api/Audit/endAuditByAuditor?snapshotId=$snapshotId&userId=$userId');
        return response.data;
    });
  }

  Future loanPurposes()async {
    return safeApiCall(() async {
       var response = await _dio.get('$baseurl/api/Operation/Account/GetLoanPurposes');
        return response.data;
    });
  }

  Future updateLoanPurpose(String value, int memberId)async {
    return safeApiCall(() async {
       var response = await _dio.post('$baseurl/api/Operation/Account/UpdateLoanPurpose?value=$value&memberId=$memberId');
        return response.data;
    });
  }

  Future<VoterCardModel> verifyVoterCard(String voterId)async {
    return safeApiCall(() async {
       var response = await _dio.post('$baseurl/api/KYC/VerifyVoterId',data: jsonEncode({"voterId": voterId}));
     return VoterCardModel.fromJson(response.data);
    });
  }

  // HFSPL-->>

  Future<LoginModel?> login(data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/LoginV3/login', data: jsonEncode(data));
      return LoginModel.fromJson(response.data);
    },
  );
  }

  Future<List<ReportingPersonModel>> getReportingPerson(String userid)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Hr/GetReportingPerson?userId=$userid');
      return ReportingPersonModel.listFromJson(response.data);
    });
  }

  Future applyLeave(FormData formdata)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Hr/SubmitLeave', data: formdata);
      return response.data;
    });
  }

  Future<OdTotalModel> getTotalOd(data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/OD/GetTotalOd', data: jsonEncode(data));
      return OdTotalModel.fromJson(response.data);
    });
  }
  Future<List<ODBranchWiseResponse>> getTotalOdBranchWise(data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/OD/GetTotalOdByRegion', data: jsonEncode(data));
      return ODBranchWiseResponse.listFromJson(response.data);
    });
  }

  Future<DemandCollectionModel> getDemandCollection(int userId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/stores/GetDemandCollectionBranchWise?userId=$userId');
      return DemandCollectionModel.fromJson(response.data);
    });
  
  }

  Future<FeWiseDemandCollectionModel> getFeWiseDemandCollection(int userId, {int? branchId}) async {
    return safeApiCall(() async {
      String url = '$baseurl/api/stores/GetDemandCollectionFEWise?userId=$userId';
      if (branchId != null) {
        url += '&branchId=$branchId';
      }
      var response = await _dio.get(url);
      return FeWiseDemandCollectionModel.fromJson(response.data);
    });
  }

  Future<List<GetNotificationModel>> getNotification(String userId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Notification/GetNotificationsOfUser?userId=$userId');
      return GetNotificationModel.listFromJson(response.data);
    });
  
  }

  Future<LeaveDetailsModel> getLeaveDetails(String guid)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Hr/GetLeaveDetailsForApproval?guid=$guid');
      return LeaveDetailsModel.fromJson(response.data);
    });
  
  }
    Future<AttendanceUpdateModel> getAttApprovalDetails(String guid)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Hr/GetAttendanceUpdateDetailsForApproval?guid=$guid');
      return AttendanceUpdateModel.fromJson(response.data);
    });
  
  }

  Future postApproveLeave(String data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Hr/ApproveLeave', data: data);
      return response.data;
    });
  }
    Future postApproveAttendance(String data)async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Hr/ApproveAttendanceUpdate', data: data);
      return response.data;
    });
  }

  Future readNotificaton(int id)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Notification/ReadNotification?id=$id');
      return response.data;
    });
  }

   // Fetch Branches
  Future<List<dynamic>> getBranches() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveBranches');
      return response.data;
    });
  }

  // Fetch Centers by Branch ID
  Future<List<dynamic>> getCenters(int feId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Dashboard/getAllActiveCenters?feId=$feId');
      return response.data;
    });
  }

  // Fetch Groups by Center ID
  Future<List<dynamic>> getGroups(int centerId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Dashboard/GetGroups?centerId=$centerId');
      return response.data;
    });
  }

  // Fetch Clients by Group ID
  Future<List<dynamic>> getClients(int groupId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Dashboard/GetClients?groupId=$groupId');
      return response.data;
    });
  }

  // Fetch Client Details by Client ID
  Future<Map<String, dynamic>> getClientDetails(int clientId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Dashboard/GetClientDataWithPhotos?userId=$clientId');
      return response.data;
    });
  }

  Future <List<OdGroupList>> getOdGroupList(int feId) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/OD/GetGroupList?feId=$feId');
      return OdGroupList.listFromJson(response.data);
    });
  }

  Future<GetMemberPastVisitDetails> getMemberPastDetails(int misId) async {

    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/CenterMonitoring/GetMemberPastDetailsWithLocation?mid=$misId');
      return GetMemberPastVisitDetails.fromJson(response.data);
    });
  }

  Future getMonitaring(int historyId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Images/GetMonitoringPhoto?id=$historyId',
        options: Options(
        responseType: ResponseType.bytes, // Ensure we get binary data
      ),
      );

      Uint8List imageBytes = Uint8List.fromList(response.data);

      return imageBytes;
    });


  }

  Future postMonitoring(formdata) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/CenterMonitoring/PostMemberMonitoring', data: formdata);
      return response.data;
    });
  }

  Future<PhonePeResponse> getPaymentQrcode(int mid, double amt) async {

    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/PhonePe/GetQrString?mid=$mid&amount=$amt');
      return PhonePeResponse.fromJson(response.data);
    });
  }

  Future<PhonePeResponse> checkPaymentStatus(String transactionId ) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/PhonePe/CheckStatus?transactionId=$transactionId');
      return PhonePeResponse.fromJson(response.data);
    });
  }

  Future<PhonePeResponse> generateLink(String mobile, int mid, double amt) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/PhonePe/GetPaymentLink?mobile=$mobile&mid=$mid&amount=$amt');
      return PhonePeResponse.fromJson(response.data);
    });
  }

  Future getGroupLocation(int groupId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Collection/GetGroupLocation?groupId=$groupId');
      return response.data;
    });
  }

  Future<List<GetGrievanceCategoriesResponse>> getGrievanceCategories() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Hr/GetGrievanceCategories');
      return GetGrievanceCategoriesResponse.listFromJson(response.data) ;
    });
  }

  Future postGrievance(FormData formdata) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Hr/PostGrievance', data: formdata);
      return response.data;
    });
  }
  Future<OverdueCallingRemarkResponse> getOverdueCallingRemark(int clientId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/OD/GetMemberOverdueCalling?clientId=$clientId');
      return OverdueCallingRemarkResponse.fromJson(response.data);
    });
  }

  Future postOverdueCallingRemark(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/OD/PostOverdueCallingData', data: data);
      return response.data;
    });
  }

  Future<List<CollectionCallingResponse>> getCollectionCalling(DateTime dateTo, String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/getCollectionCalling?dateTo=$dateTo&feid=$userId');
      return CollectionCallingResponse.listFromJson(response.data);
    });
  }

  Future getCallingRemarks() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/getCollectionRemarks');
      return response.data;
    });
  }
  Future getRemarksAndReasons() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/GetRemarksReason');
      return response.data;
    });
  }
  Future getSpouseWorkRemarks() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/getCollectionSpouseWorkRemarks');
      return response.data;
    });
  }
  Future postCollectionCalling(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Telecalling/updateCollectionCallingRemark', data: data);
      return response.data;
    });
  }

  Future<MobileCheckResponse> checkMobileForLoan(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/CheckMobileForLoan', data: data);
    
      return MobileCheckResponse.fromJson(response.data);
    });
  }

 

Future createLead(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/CreateLead', data: data);
      return response.data;
    });
  }

  Future<OfferResponseModel> getOffers(leadId) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/GetOffers', data: {"LeadId": leadId});
      return OfferResponseModel.fromJson(response.data);
    });
  }

  Future summaryOfferApi(leadId) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/GetSummary', data: {"LeadId": leadId}
      );
    
      return response.data;
    });
  }

  Future sendOfferEmail(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Loan/SendOfferEmail',data: data
      );
      return response.data;
    });
  }

  Future saveLeadDetails(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/Lead/SaveLeadDetails',data: data
      );
    
      return response.data;
    });
  }

  Future<GoldLoanResponse> applyGoldLoan({
    required String mobileNumber,
    required String firstName,
    required String lastName,
    required String pan,
    required String email,
    required String pincode,
    required int loanAmount,
  }) async {
    final data = {
      "mobileNumber": mobileNumber,
      "firstName": firstName,
      "lastName": lastName,
      "pan": pan,
      "email": email,
      "pincode": pincode,
      "loanAmount": loanAmount,
    };
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/Gold-loans', data: data);
      return GoldLoanResponse.fromJson(response.data);
    });
  }

  Future checkExistingLead(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Operation/Lead/CheckExistingLead', data: data);
      return response.data;
    });
  }

  Future<LeadDetailsResponse> getLeadDetails(userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Operation/Lead/GetLeadByLoginId?userId=$userId'
      );
    
      return LeadDetailsResponse.fromJson(response.data);
    });
  }

  Future<FunderDetailsResponse> getFunderDetails(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/GetFunderDetailsByUserId?userId=$userId');
      return FunderDetailsResponse.fromJson(response.data);
    });
  }

  Future<List<FunderCenterResponse>> getAllActiveCenters(int feId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveCenters1?feId=$feId');
      return FunderCenterResponse.listFromJson(response.data);
    });
  }

  Future<List<FunderMemberResponse>> getAllDisbursedMembers(int centerId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Telecalling/GetAllDisburseMembersOfCenter?centerId=$centerId');
      return FunderMemberResponse.listFromJson(response.data);
    });
  }

  Future<Map<String, dynamic>> initiatePhoneUpdate(int clientId, String phone, String name, int updatedBy) async {
    return safeApiCall(() async {
      final data = {
        "ClientId": clientId,
        "Phone": phone,
        "Name": name,
        "UpdatedBy": updatedBy
      };
      var response = await _dio.post('$baseurl/api/Telecalling/InitiatePhoneUpdate', data: data);
      return response.data;
    });
  }

  Future<Map<String, dynamic>> verifyPhoneUpdate(int clientId, String phone, String otp, int updatedBy) async {
    return safeApiCall(() async {
      final data = {
        "ClientId": clientId,
        "Phone": phone,
        "Otp": otp,
        "UpdatedBy": updatedBy
      };
      var response = await _dio.post('$baseurl/api/Telecalling/VerifyPhoneUpdate', data: data);
      return response.data;
    });
  }

  Future<List<ActiveFeModel>> getAllActiveFeForBM(int userId)async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getAllActiveFeByUserId?userId=$userId');
      return ActiveFeModel.listFromJson(response.data);
    });
  }

  Future<List<VerifyOwnFundNonVerifiedGroups>> getNonVerifiedGroups(int feId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Common/getOwnfundNonVerifiedGroups?feId=$feId');
      return VerifyOwnFundNonVerifiedGroups.listFromJson(response.data);
    });
  }

  Future<List<VerifyOwnFundNonVerifiedMembers>> getNonVerifiedMembers(int groupId, {String groupName = "", int feId = 0}) async {
    return safeApiCall(() async {
      var url = '$baseurl/api/Common/getOwnfundNonVerifiedMembers?groupId=$groupId';
      if (groupName.isNotEmpty) {
        url += '&groupName=${Uri.encodeComponent(groupName)}';
      }
      if (feId > 0) {
        url += '&feId=$feId';
      }
      var response = await _dio.get(url);
      return VerifyOwnFundNonVerifiedMembers.listFromJson(response.data);
    });
  }
  Future verifyOwnfundNonVerifiedMember(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Common/verifyOwnfundNonVerifiedMember', data: data);
      return response.data;
    });
  }

   Future sendOtpForOwnfundNonVerifiedMember(int clientId) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Common/resendOtpOwnfundNonVerifiedMember?clienId=$clientId');
      return response.data;
    });
  }

    Future postCollection2 (items) async {
    return safeApiCall(() async {
    
      final response = await _dio.post(
         '$baseurl/api/Collection/PostCollection2',
         data: items,
       );
      return response.data;
    });
  
}

Future paySprintOcr(FormData formData) async {
  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/sprintOcrAadhar', data: formData, options: Options(
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    ));
    return response.data;
  });
}

Future testSprint() async {
  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/testPennyDrop');
    return response.data;
  });
}

Future<RenewalMtlResponse> checkRenewalMtl(String uid, int groupId) async {
  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/CheckRenewalMTL?uid=$uid&groupId=$groupId');
    return RenewalMtlResponse.fromJson(response.data);
  });
}

Future submitRenewalMTL(int type, int snapId, int nUid, int groupId, String name) {
  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/KYC/CreateRenewalMTL?type=$type&oldsnapId=$snapId&nUid=$nUid&groupId=$groupId&name=$name');
    return response.data;
  });
}

Future<HousingLoanResponse> applyHousingLoan({
  required String mobileNumber,
  required String firstName,
  required String lastName,
  required String pan,
  required String dob,
  required String email,
  required String pincode,
  required int monthlyIncome,
  required int housingLoanAmount,
  required String propertyType,
}) async {
  final data = {
    "mobileNumber": mobileNumber,
    "firstName": firstName,
    "lastName": lastName,
    "pan": pan,
    "dob": dob,
    "email": email,
    "pincode": pincode,
    "monthlyIncome": monthlyIncome,
    "housingLoanAmount": housingLoanAmount,
    "propertyType": propertyType,
  };
  return safeApiCall(() async {
    var response = await _dio.post('$baseurl/api/Operation/Housing-loan', data: data);
    return HousingLoanResponse.fromJson(response.data);
  });
}

  Future getProfileImage(String userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/Staff/GetImage?userId=$userId',
        options: Options(
        responseType: ResponseType.bytes,
      ));
      return response.data;
    });
  }

    Future uploadProfileImage(String userId, FormData formData) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Staff/UploadImage?userId=$userId', data: formData);
      return response.data;
    });
  }

  Future<AppVersionResp?> fetchVersion(int versionCode) async {
    return safeApiCall(()async {
      var response = await _dio.get('$baseurl/api/AppVersion/CurrentVersionV3?version=$versionCode&appType=1');
      return AppVersionResp.fromJson(response.data);
    });
  }

  Future<UserRoleFlags> getUserRoles(String userId) async {
    return safeApiCall(()async {
      var response = await _dio.get('$baseurl/api/Staff/RoleFlags?userId=$userId');
      return UserRoleFlags.fromJson(response.data);
    });
  }

  Future<List<TodayOverdueModel>> getTodayOverdue(int branchId, int feid) async {
    return safeApiCall(()async {
      var response = await _dio.get('$baseurl/api/Telecalling/getTodayOverdue?branchId=$branchId&feId=$feid');
      return TodayOverdueModel.listFromJson(response.data);
    });
  }

  Future requestAttendanceUpdate(data) async {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Hr/RequestAttendanceUpdate', data: jsonEncode(data));
      return response.data;
    });
  }

  // Center Monitoring APIs
  
  // Get meeting types for center monitoring
  Future<List<MeetingTypeResponse>> getMeetingTypes() async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/CenterMonitoring/GetMeetingTypes');
      return MeetingTypeResponse.listFromJson(response.data);
    });
  }

  // Get centers by FE ID with filter type (0=All, 1=Pending, 2=More than 3 months)
  Future<List<CenterMonitorResponse>> getCentersByFeIdAndFilter(int feId, int filterType) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/CenterMonitoring/GetCentersByFeAndFilter?feId=$feId&filterType=$filterType');
      return CenterMonitorResponse.listFromJson(response.data);
    });
  }

  // Get groups by center ID for monitoring
  Future<List<GroupResponse>> getGroupsByCenterId(int centerId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/CenterMonitoring/GetGroupsByCenter?centerId=$centerId');
      return GroupResponse.listFromJson(response.data);
    });
  }

  // Get members by selected group IDs
  Future<List<MemberResponse>> getMembersByGroupIds(List<int> groupIds) async {
    return safeApiCall(() async {
      var response = await _dio.post(
        '$baseurl/api/CenterMonitoring/GetMembersByGroups',
        data: jsonEncode({'groupIds': groupIds})
      );
      return MemberResponse.listFromJson(response.data);
    });
  }

  // Submit center monitoring data
  Future<SubmitMonitoringResponse> submitCenterMonitoring({
    required int centerId,
    required int staffId,
    required int meetingTypeId,
    required List<int> groupIds,
    required String groupObservation,
    required String centerObservation,
    required List<Map<String, dynamic>> memberData, // Contains clientId, observation, and photo file
    required String latitude,
    required String longitude,
  }) async {
    return safeApiCall(() async {
      FormData formData = FormData();
      
      // Add basic fields
      formData.fields.addAll([
        MapEntry('centerId', centerId.toString()),
        MapEntry('staffId', staffId.toString()),
        MapEntry('meetingTypeId', meetingTypeId.toString()),
        MapEntry('groupIds', jsonEncode(groupIds)),
        MapEntry('groupObservation', groupObservation),
        MapEntry('centerObservation', centerObservation),
        MapEntry('latitude', latitude),
        MapEntry('longitude', longitude),
      ]);

      // Add member data
      for (int i = 0; i < memberData.length; i++) {
        var member = memberData[i];
        formData.fields.add(MapEntry('members[$i].clientId', member['clientId'].toString()));
        formData.fields.add(MapEntry('members[$i].observation', member['observation'] ?? ''));
        
        if (member['photoFile'] != null) {
          formData.files.add(MapEntry(
            'members[$i].photo',
            await MultipartFile.fromFile(
              member['photoFile'].path,
              filename: '${member['clientId']}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ));
        }
      }

      var response = await _dio.post('$baseurl/api/CenterMonitoring/SubmitMonitoring', data: formData);
      return SubmitMonitoringResponse.fromJson(response.data);
    });
  }

  // Future<String> uploadBill(
  //   File billFile, 
  //   String filename,
  //   String billNumber,
  //   String productName,
  //   int amount,
  //   String description,
  //   String category
  // ) async {
  //   FormData formData = FormData();
  //     formData.files.add(MapEntry(
  //       'file',
  //       await MultipartFile.fromFile(billFile.path, filename: filename),
  //     ));
  //     formData.fields.addAll([
  //       MapEntry('userId', Global_uid),
  //       MapEntry('billNumber', billNumber),
  //       MapEntry('productName', productName),
  //       MapEntry('amount', amount.toString()),
  //       MapEntry('category', category),
  //       MapEntry('description', description),
  //     ]);
  //     return safeApiCall(() async {
  //     var response = await _dio.post('$baseurl/api/Bill/Upload', data: formData);
  //     return response.data;
  //   });
  // }

  // ==================== NMFI DDE API Methods ====================

  /// Get DDE eligible members for Field Executive
  Future<List<DDEEligibleMemberModel>> getDDEEligibleMembers(int userId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetDDEEligibleMembers?userId=$userId&loanType=$loanTypeId');
      return (response.data as List)
          .map((json) => DDEEligibleMemberModel.fromJson(json))
          .toList();
    });
  }

  /// Assign DDE to selected members
  Future<String> assignDDE(AssignDDERequest request) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/AssignDDE', 
        data: request.toJson());
      return response.data ?? 'DDE assigned successfully';
    });
  }

  /// Get assigned DDE list for Field Executive
  Future<List<DDEAssignedModel>> getAssignedDDEList(int userId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetAssignedDDEList?userId=$userId&loanType=$loanTypeId', 
        );
      return (response.data as List)
          .map((json) => DDEAssignedModel.fromJson(json))
          .toList();
    });
  }

  /// Get DDE details by ID
  Future<Map<String, dynamic>> getDDEDetailsById(int ddeScheduleId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetDDEDetailsById?ddeScheduleId=$ddeScheduleId&loanType=$loanTypeId', 
        );
      return response.data;
    });
  }

  /// Post DDE completion with file uploads
  Future<String> postDDE(PostDDERequest request, {File? passbookFile, File? bankStatementFile}) {
    return safeApiCall(() async {
      FormData formData = FormData();
      formData.fields.add(MapEntry("data", jsonEncode(request.toJson())));
      
      // Add passbook file if provided
      if (passbookFile != null) {
        formData.files.add(MapEntry(
          "passbook",
          await MultipartFile.fromFile(
            passbookFile.path,
            filename: "passbook_${request.ddeScheduleId}.jpg",
          ),
        ));
      }
      
      var response = await _dio.post(
        '$baseurl/api/ClientApp/IndividualDDE/PostDDE',
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );
      return response.data ?? 'DDE completed successfully';
    });
  }

  // ==================== Perfios (IFSC/Account Name) ====================

  /// Get bank details (BankName, BranchName) by IFSC using Perfios
  Future<Map<String, dynamic>> getBankDetailsByIfsc(String ifsc) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/Perfios/Ifsc?ifsc=$ifsc');
      return response.data;
    });
  }

  /// Check account holder name from bank by IFSC and account number using Perfios
  Future<String?> getAccountNameByIfscAndAccount(String ifsc, String accountNumber) {
    return safeApiCall(() async {
      var response = await _dio.post(
        '$baseurl/api/Perfios/BankNameCheck?ifsc=$ifsc&accountNumber=$accountNumber',
      );
      return response.data;
    });
  }

  /// Get verification eligible members for Branch Manager
  Future<List<VerificationEligibleMemberModel>> getVerificationEligibleMembers(int userId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetVerificationEligibleMembers?userId=$userId&loanType=$loanTypeId', 
        );
      return VerificationEligibleMemberModel.listFromJson(response.data);
    });
  }

  /// Assign verification to selected members
  Future<String> assignVerification(AssignVerificationRequest request) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/AssignVerification', 
        data: request.toJson());
      return response.data ?? 'Verification assigned successfully';
    });
  }

  /// Get assigned verification list for Branch Manager
  Future<List<DDEAssignedModel>> getAssignedVerificationList(int userId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetAssignedVerificationList?userId=$userId&loanType=$loanTypeId', 
        );
      return (response.data as List)
          .map((json) => DDEAssignedModel.fromJson(json))
          .toList();
    });
  }

  /// Get verification details by ID
  Future<Map<String, dynamic>> getVerificationDetailsById(int ddeScheduleId) {
    return safeApiCall(() async {
      var response = await _dio.post('$baseurl/api/ClientApp/IndividualDDE/GetVerificationDetailsById?ddeScheduleId=$ddeScheduleId&loanType=$loanTypeId', 
        );
      return response.data;
    });
  }

  /// Post verification completion with file uploads
  Future<Map<String, dynamic>> postVerification(PostVerificationRequest request, {File? houseImage, File? businessImage}) {
    return safeApiCall(() async {
      FormData formData = FormData();
      formData.fields.add(MapEntry("data", jsonEncode(request.toJson())));
      if (houseImage != null) {
        formData.files.add(MapEntry(
          "houseImage",
          await MultipartFile.fromFile(
            houseImage.path,
            filename: "house_${request.ddeScheduleId}.jpg",
          ),
        ));
      }
      if (businessImage != null) {
        formData.files.add(MapEntry(
          "businessImage",
          await MultipartFile.fromFile(
            businessImage.path,
            filename: "business_${request.ddeScheduleId}.jpg",
          ),
        ));
      }
      var response = await _dio.post(
        '$baseurl/api/ClientApp/IndividualDDE/PostVerification',
        data: formData,
      );
      return response.data;
    });
  }

  /// Get today's demand and collection statistics
  Future<Map<String, dynamic>> getTodayDemandCollection(int userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/stores/GetTodayDemandCollection?userid=$userId');
      return response.data;
    });
  }

  /// Get today's OD (Overdue) statistics by user ID
  Future<Map<String, dynamic>> getTodayOdByUserId(int userId) async {
    return safeApiCall(() async {
      var response = await _dio.get('$baseurl/api/OD/GetTodayOdByUserId?userId=$userId');
      return response.data;
    });
  }
}

