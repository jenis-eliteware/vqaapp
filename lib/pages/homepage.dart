import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:vqaapp/pages/resultpage.dart';
import 'package:image/image.dart' as img;

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  File? imageFile;

  clearimage() {
    setState(() {
      imageFile = null;
    });
  }

  final fieldText = TextEditingController();
  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        // bottomNavigationBar: BottomNav(),
        // drawer: DrawMenu(),
        appBar: AppBar(
          title: Text(
            'Visual QA System',
          ),
        ),
        body: SafeArea(
            child: Column(children: [
          Center(
            child: Container(
              width: 310,
              padding: EdgeInsets.all(50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(800),
                child: Image.asset(
                  'assets/images/search.jpeg',
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 250, 20),
            child: Text(
              'Search Here',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Something',
                focusColor: Colors.green,
                suffixIcon: IconButton(
                  // Icon to
                  icon: Icon(Icons.clear), // clear text
                  onPressed: clearText,
                ),
              ),
              controller: fieldText,
            ),
          ),
          SafeArea(
            child: imageFile == null
                ? Container(
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(60, 80, 50, 80),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.camera),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40))),
                                    fixedSize: MaterialStatePropertyAll(
                                        Size(120, 70))),
                                onPressed: () {
                                  _getFromCamera();
                                },
                                label: Text('Camera'),
                              ),
                            ),
                            Container(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40))),
                                    fixedSize: MaterialStatePropertyAll(
                                        Size(123, 70))),
                                onPressed: () {
                                  _getFromGallery();
                                },
                                label: Text('Upload'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: EdgeInsets.fromLTRB(104, 20, 104, 0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Column(
                      children: [
                        Image.file(
                          imageFile!,
                          //fit: BoxFit.cover,
                          height: 200,
                          width: 200,
                        ),
                        Container(
                          child: TextButton(
                            child: Text(
                              "Clear",
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                            onPressed: () {
                              clearimage();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40))),
                  fixedSize: MaterialStatePropertyAll(Size(200, 60))),
              onPressed: () async {
                // List<int> _bytes = await imageFile!.readAsBytes();
                Uint8List imageBytes = await imageFile!.readAsBytes();
                img.Image image = img.decodeImage(imageBytes)!;
                img.Image pngImage = img.copyResize(image, width: 800);
                Uint8List pngBytes = img.encodePng(pngImage);
                String base64String = base64Encode(pngBytes);
                // String _base64String = base64.encode(_bytes);
                String textInput = fieldText.text;
                if (imageFile != null &&
                    base64String.isNotEmpty &&
                    textInput.isNotEmpty) {
                  final url =
                      Uri.parse('https://anash-visual-qa.hf.space/run/predict');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'data': [base64String, textInput],
                    }),
                  );

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body)['data'];
                    print(data);
                    print(
                        'Request Success with status: ${response.statusCode}.');
                    // Do something with data
                  } else {
                    print(
                        'Request failed with status: ${response.statusCode}.');
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => output(
                              response.body,
                            )),
                  );
                } else {
                  print(
                      'Error: Image file, base64 string, or text input is missing.');
                }

                // sendUserData(textapi, imgapi);

                // uploadImage();
                // _postData();
                // makeRequest();
                // apicall;
              },
              child: Text('Search'),
            ),
          ),
        ])));
  }

  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
}
