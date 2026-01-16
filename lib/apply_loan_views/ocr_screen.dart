import 'package:flutter/material.dart';
import 'package:HFSPL/network/responses/OCR/ocr_response_model.dart';

class OCRScreen extends StatelessWidget {
  final List<Document>? documents;

  OCRScreen({Key? key, this.documents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return documents == null || documents!.isEmpty
        ? const Center(
            child: Text('No Data Available'),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents!.length,
            itemBuilder: (context, index) {
              var document = documents![index];
              var fields = document?.ocrData?.fields;
              var additionalDetails = document.additionalDetails;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Page ${index + 1}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const Divider(),
                        fields == null || fields.isEmpty
                            ? const Text("No Fields Available")
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: fields.length,
                                itemBuilder: (context, fieldIndex) {
                                  String key =
                                      fields.keys.elementAt(fieldIndex);
                                  String? value =
                                      fields[key]?.value ?? 'No Value';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            key,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(value!),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          // if(additionalDetails?.addressSplit?.district != null)
                          // Text(additionalDetails!.addressSplit!.district!),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
