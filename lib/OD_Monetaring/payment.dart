import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:HFSPL/Audit/dummy.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/PhonePayResponse/phonepay_response_model.dart';
import '../network/responses/OD/od_group_list.dart';

class PaymentOd extends StatefulWidget {
  final OdMember member;
  final String demandAmount;
  const PaymentOd({super.key, required this.member, required this.demandAmount});

  @override
  State<PaymentOd> createState() => _PaymentOdState();
}

class _PaymentOdState extends State<PaymentOd> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mobController = TextEditingController();
  final DioClient _client = DioClient();
  PhonePeResponse? phonePeResponse;
  String qrString = '';
  Timer? _timer;
  int _secondsRemaining = 300; // 5 minutes = 300 seconds
  bool _isTimerRunning = false;
  bool isLinkSent = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.demandAmount;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Start countdown timer. When time expires, show an expiration dialog and reset state.
  void startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        _showQRExpiredDialog();
      }
    });
  }

  // Reset the timer and clear the QR so that the original form appears again.
  void resetQR() {
    _timer?.cancel();
    setState(() {
      qrString = '';
      _secondsRemaining = 300;
      _isTimerRunning = false;
      isLinkSent = false;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Show dialog when QR expires.
  void _showQRExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("QR Expired"),
        content: const Text("The QR code is no longer valid. Please generate a new one."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              resetQR();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // When QR string is received, show only the QR view.
  @override
  Widget build(BuildContext context) {
    // If a QR is generated, show only the QR, timer, and refresh button.
    if (qrString.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Payment - QR Generated")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: qrString,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 16),
              Text("Remaining Time: ${formatTime(_secondsRemaining)}"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPaymentStatus,
                child: const Text("REFRESH PAYMENT STATUS"),
              ),
              const SizedBox(height: 16),
              // Optionally add a button to cancel and go back.
              ElevatedButton(
                onPressed: resetQR,
                child: const Text("CANCEL & GO BACK"),
              ),
            ],
          ),
        ),
      );
    }
    else if(isLinkSent) {
      return Scaffold(
        appBar: AppBar(title: const Text("Payment - QR Link Generated")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text("Remaining Time: ${formatTime(_secondsRemaining)}"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPaymentStatus,
                child: const Text("REFRESH PAYMENT STATUS"),
              ),
              const SizedBox(height: 16),
              // Optionally add a button to cancel and go back.
              ElevatedButton(
                onPressed: resetQR,
                child: const Text("CANCEL & GO BACK"),
              ),
            ],
          ),
        ),
      );
    }

    // If no QR generated yet, show the full payment form.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              RowWithData(title: 'Member Name:', data: widget.member.memberName),
              const SizedBox(height: 5),
              RowWithData(title: 'Spouse Name:', data: widget.member.spouse),
              const SizedBox(height: 5),
              RowWithData(title: 'Loan Number:', data: widget.member.loanNo),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 44,
                    width: 150,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _amountController,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(
                        label: Text("Amount"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      String amtText = _amountController.text;
                      if (amtText.isNotEmpty) {
                        double? amt = double.tryParse(amtText);
                        if (amt != null && amt > 0) {
                          generateQR(amt);
                        } else {
                          showMessage(context, "Invalid amount or less than 0");
                        }
                      } else {
                        showMessage(context, "Please enter a valid amount");
                      }
                    },
                    child: const Text("Generate QR"),
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                controller: _mobController,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(
                  label: Text("Enter Mobile Number"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  String mobText = _mobController.text.trim();
                  String amtText = _amountController.text;
                  if (mobText.isNotEmpty && amtText.isNotEmpty) {
                    double? amt = double.tryParse(amtText);
                    if (mobText.length == 10 && (amt != null && amt > 0)) {
                      generatePaymentLink(mobText, amt);
                    } else if (mobText.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid mobile number")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid amount")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a valid mobile number")),
                    );
                  }
                },
                child: const Text("Generate Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to generate QR code and start the timer.
  void generateQR(double amt) async {
    try {
      var response = await _client.getPaymentQrcode(widget.member.misId, amt);
      setState(() {
        phonePeResponse = response;
        if (phonePeResponse?.data?.transactionId != null &&
            phonePeResponse?.data?.qrString != null) {
          qrString = phonePeResponse!.data!.qrString!;
          startTimer();
        }
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    }
  }

  // Check the payment status and act accordingly.
  void _checkPaymentStatus() async {
    if (phonePeResponse?.data?.transactionId == null) {
      showMessage(context, "Transaction Id is not available.");
      return;
    }
    var response = await _client.checkPaymentStatus(phonePeResponse!.data!.transactionId!);
    if (response.success == true) {
      if (response.code == "PAYMENT_SUCCESS") {
        print("inside");
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Amount posted successfully..!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      resetQR();
                    },
                    child: const Text("Ok"),
                  ),
                ],
              ),
            ),
          ),
        );
        // Navigator.pop(context);
      } else {
        showMessage(context, '${response.message}');
      }
    }
  }

  // Stub for generating payment link.
  void generatePaymentLink(String mobText, double amt) async {
    try {
      var response = await _client.generateLink(mobText, widget.member.misId, amt);
      setState(() {
        phonePeResponse = response;
        if (phonePeResponse?.data?.transactionId != null &&
            phonePeResponse?.data?.payLink != null) {
              isLinkSent = true;
              startTimer();
              showMessage(context, "Payment link sent on SMS.");
        }
        else {
          showMessage(context, "Something went wrong.");
        }
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    }
    
  }
}
