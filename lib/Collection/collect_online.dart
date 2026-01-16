
import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/network/responses/Collection/demand_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CollectOnline extends StatefulWidget {
  final Member member;
  const CollectOnline({super.key, required this.member});

  @override
  State<CollectOnline> createState() => _CollectOnlineState();
}

class _CollectOnlineState extends State<CollectOnline> {
   TextEditingController _ammt_controller = TextEditingController();
  final TextEditingController _mob_controller = TextEditingController();
  String qrString = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ammt_controller = TextEditingController(text: widget.member.emi.toString());
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _ammt_controller.dispose();
    _mob_controller.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Member member = widget.member;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              RowWithData(title: 'Member Name:', data: member.name),
              const SizedBox(height: 5,),
              RowWithData(title: 'Spouse Name:', data: member.relativeName),
              const SizedBox(height: 5,),
              RowWithData(title: 'Loan Number:', data: member.loanNumber),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text("Enter Amount:"),
                  // SizedBox(width: 10,),
                  SizedBox(
                    height: 44,
                    width: 150,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _ammt_controller,
                      onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      decoration: const InputDecoration(
                          label: Text("Amount"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(20)))),
                    ),
                  ),
                  FilledButton(onPressed: ()async{
                    //  FocusScope.of(context).unfocus();
                    var amtText = _ammt_controller.text;
                    if (amtText.isNotEmpty){
                       var amt = double.tryParse(amtText);
                        if (amt != null && amt > 0) {
                          // amt is a valid number and greater than 0
                          generateQR(amt);
                          // await Future.delayed(const Duration(seconds: 2));
                          setState(() {
                            qrString = amtText;
                          });
                          
                        } else {
                          // Handle invalid number or less than or equal to 0
                          print('Invalid amount or less than 0');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid amount or less than 0")));
                        }
                      
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
                      // showToastShort("Please enter a valid amount")
                  }
                  }, child: const Text("Generate QR"))
                ],
              ),
              const SizedBox(height: 20,),
              TextField(
                keyboardType: TextInputType.number,
                controller: _mob_controller,
                onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                decoration: const InputDecoration(
                  label: Text("Enter Mobile Number"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              FilledButton(
                onPressed: (){
                   var mobText = _mob_controller.text.trim();
                   var amtText = _ammt_controller.text;
          
                   if(mobText.isNotEmpty && amtText.isNotEmpty){
                      var amt = double.tryParse(amtText);
                      
                      if (mobText.length == 10 && (amt!=null && amt>0)){
                        generatePaymentLink(mobText,amt);
                        }
                        else if (mobText.length != 10){
                            print("Please enter a valid mobile number");
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid mobile number")));
                        }
                        else{
                            print("Please enter a valid amount");
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
                        }
          
                   }
                   else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid mobile number")));
                   }
                },
                 child: const Text("Generate Link")),
                 
               const SizedBox(height: 10),
          
              qrString != ''? QrImageView(
                data: qrString,
                version: QrVersions.auto,
                size: 200.0,
                // backgroundColor: Colors.black38,
              )
              : const Text(''),
            ],
          ),
        ),
      ),
    );
  }
  
  void generateQR(double amt) {
    try {
      // var response = getPaymentQrcode(widget.member.memberId,amt);
      print("response ");
    } catch (e) {
      print("error fetching QR $e");
    }
  }
  
  void generatePaymentLink(String mobText, double amt) {
    print("generate payment Link");
  }
}