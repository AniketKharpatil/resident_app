import 'dart:async';
import 'dart:io';

import 'package:doc_app/Screens/BottomNavBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'dart:convert';
import 'package:otp_text_field/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class GetOtpPage extends StatefulWidget {
  // const GetOtpPage({Key? key}) : super(key: key);

  @override
  _GetOtpPageState createState() => _GetOtpPageState();
}

class _GetOtpPageState extends State<GetOtpPage> {
  TextEditingController aadhar = new TextEditingController();
  var uuid = new Uuid().v4();
  // var uid = "782917283130";
  Future otpapi(uid) async {
    var url = Uri.parse("https://stage1.uidai.gov.in/onlineekyc/getOtp/");

    var body = json.encode({"uid": "$uid", "txnId": "$uuid"});

    var headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var response = await http.post(url, headers: headers, body: body);

    final resp = json.decode(response.body);
    print(response.body);

    if (resp["status"] == "Y") {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return OtpVerificationPage(uuid, aadhar.text);
      }));
    } else if (resp["status"] == "N") {
      print(response.reasonPhrase);
    }
  }

  @override

  // Sign a message
  final message = "Tap Proceed button to complete the transaction";

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: TextFormField(
                    controller: aadhar,
                    decoration: InputDecoration(labelText: "Enter Aadhaar no."),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: Text("$message"),
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                  onPressed: () => otpapi(aadhar.text), child: Text("Proceed")),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpVerificationPage extends StatefulWidget {
  final uuid;
  final aadhar;
  OtpVerificationPage(this.uuid, this.aadhar);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  var otpsub = "";
  var data = '';

  // var uuid = new Uuid().v4();
  var headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  // var uid = "782917283130";
  Future checkOTP(otpsub) async {
    var ekurl = Uri.parse("https://stage1.uidai.gov.in/onlineekyc/getEkyc/");
    var url = Uri.parse('https://stage1.uidai.gov.in/onlineekyc/getAuth/');
    var vidurl = Uri.parse("https://stage1.uidai.gov.in/vidwrapper/generate");
    // https://stage1.uidai.gov.in/vidwrapper/generate
    //  https://stage1.uidai.gov.in/vidwrapper/retrieve
    var body = json.encode({
      "uid": "${widget.aadhar}",
      "txnId": "${widget.uuid}",
      "otp": "$otpsub"
    });

    // var vidbody = json.encode({
    //   "uid": "$uid",
    //   "mobile": "919867263683",
    //   "otp": "$otpsub",
    //   "otpTxnId": "${widget.uuid}"
    // });
    var response = await http.post(ekurl, headers: headers, body: body);
    final resp = json.decode(response.body);

    if (resp["status"] == "Y") {
      print(response.body);
      var jdata = jsonDecode(response.body);
      setState(() {
        data = jdata["eKycString"];
      });

      // final filename = "file.txt";
      var file = await _localFile;
      file.writeAsString(data.toString());
      // File(filename).writeAsString(data.toString());
      print(
          ".................................Huraaaahhh working .........................................");
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return SuccessPage(data);
      }));
    } else {
      print(response.reasonPhrase);
      Fluttertoast.showToast(
        msg: response.reasonPhrase.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 60,
                  width: MediaQuery.of(context).size.width - 50,
                  child: OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width - 40,
                    fieldStyle: FieldStyle.box,
                    fieldWidth: 40,
                    style: TextStyle(fontSize: 16),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    onCompleted: (pin) {
                      setState(() {
                        otpsub = pin;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text('Confirm'),
                  onPressed: () async {
                    print("otp value: $otpsub");
                    checkOTP(otpsub);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SelectableText("$data"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessPage extends StatefulWidget {
  // const SuccessPage({Key? key}) : super(key: key);
  final data;
  SuccessPage(this.data);

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {

void navback() {
      new Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar(),),
        );
      });
    }

    startTime() async {
      var duration = new Duration(seconds: 3);
      return new Timer(duration, navback);
    }

    @override
    initState() {
      super.initState();
      this.navback();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Booking Successful !!!",
            style: TextStyle(
                fontSize: 27, fontWeight: FontWeight.bold, color: Colors.green),
          ),

          // Text(widget.data),
        ],
      ),
    ));
  }
}



//   headers: {
  //  'content-type': 'text/xml'
  //   },

  // var client = IOClient();
  // var url1 =
  //     "https://otp-stage.uidai.gov.in/uidotpserver/2.5/public/7/8/MEY2cG1nhC02dzj6hnqyKN2A1u6U0LcLAYaPBaLI-3qE-FtthtweGuk ";
  // // var url = "http://developer.uidai.gov.in/otp/1.6//6/8/";
  // var url2 = "https://auth.uidai.gov.in/otp/2.5/public/7/8/";
  // var xml = '<?xml version="1.0" encoding="UTF-8"? standalone="yes"?>';
  // Future otpapi() async {
  //   var req = await http.Request(
  //     'POST',
  //     Uri.parse(url1),
  //     //   headers: {
  //     //  'content-type': 'text/xml'
  //     //   },
  //   );
  //   req.headers.addAll({
  //     // HttpHeaders.authorizationHeader: 'Basic $credential',
  //     'content-type': 'text/xml' // or text/xml;charset=utf-8
  //   });
  //   req.body = xml;
  //   var streamedResponse = await client.send(req);
  //   print(streamedResponse.statusCode);

  //   var responseBody =
  //       await streamedResponse.stream.transform(utf8.decoder).join();
  //   print(responseBody);
  //   client.close();

  // print(response.statusCode);
  // print(response.reasonPhrase);
  // final jdata = response.body;
  // return jdata;
  // }