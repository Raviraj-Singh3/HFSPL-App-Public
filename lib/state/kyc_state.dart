import 'package:flutter/foundation.dart';
import 'package:HFSPL/models/loan_type.dart';

class KycState extends ChangeNotifier {
  static final KycState _instance = KycState._internal();
  factory KycState() => _instance;
  KycState._internal();
  
  bool _isIndividual = false;
  LoanType _loanType = LoanType.personalLoan;
  
  bool get isIndividual => _isIndividual;
  LoanType get loanType => _loanType;
  int get loanTypeId => _loanType.id;
  
  void setIndividualMode({LoanType? loanType}) {
    _isIndividual = true;
    if (loanType != null) {
      _loanType = loanType;
    }
    notifyListeners();
  }
  
  void setGroupMode() {
    _isIndividual = false;
    notifyListeners();
  }
  
  void setKycMode(bool isIndividual, {LoanType? loanType}) {
    _isIndividual = isIndividual;
    if (loanType != null) {
      _loanType = loanType;
    }
    notifyListeners();
  }
  
  void setLoanType(LoanType loanType) {
    _loanType = loanType;
    notifyListeners();
  }
  
  void setLoanTypeById(int loanTypeId) {
    _loanType = LoanType.fromId(loanTypeId);
    notifyListeners();
  }
  
  // For debugging
  @override
  String toString() {
    return 'KycState(isIndividual: $_isIndividual, loanType: ${_loanType.title} (${_loanType.id}))';
  }
}
