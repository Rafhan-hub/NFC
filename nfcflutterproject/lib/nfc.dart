import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCApp extends StatefulWidget {
  const NFCApp({super.key});

  @override
  State<StatefulWidget> createState() => NFCAppState();
}

class NFCAppState extends State<NFCApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String nfcData = 'No NFC data';
  bool isShowNdefWriteButton = false;
  bool isShowNNdefWriteLockButton = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Colors.red,
        appBar: AppBar(title: const Text('NFC Test Application')), 
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    direction: Axis.vertical,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (isShowNdefWriteButton) {
                                setState(() {
                                  isShowNdefWriteButton = false;
                                });
                              } else {
                                setState(() {
                                  isShowNdefWriteButton = true;
                                });
                              }
                            },
                            child: const Text(
                              '.',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (isShowNNdefWriteLockButton) {
                                setState(() {
                                  isShowNNdefWriteLockButton = false;
                                });
                              } else {
                                setState(() {
                                  isShowNNdefWriteLockButton = true;
                                });
                              }
                            },
                            child: const Text(
                              '.',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                result.value = '';
                              });
                            },
                            child: const Text(
                              'Clear',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(border: Border.all()),
                          child: SingleChildScrollView(
                            child: ValueListenableBuilder<dynamic>(
                              valueListenable: result,
                              builder: (context, value, _) =>
                                  Text('${value ?? ''}'),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: GridView.count(
                          padding: const EdgeInsets.all(4),
                          crossAxisCount: 2,
                          childAspectRatio: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: [
                            ElevatedButton(
                                // onPressed: startNfcSession,
                                onPressed: _mockNfcData,
                                // onPressed: startNfcSession,
                                child: const Text('Tag Read From Mock')
                            ),
                            ElevatedButton(
                                // onPressed: startNfcSession,
                                onPressed: _tagRead,
                                // onPressed: startNfcSession,
                                child: const Text('Tag Read')),
                            // isShowNdefWriteButton == true
                            //     ? 
                                ElevatedButton(
                                    onPressed: _ndefWrite,
                                    child: const Text('Ndef Write')
                                ),
                                // : const SizedBox(),
                            isShowNNdefWriteLockButton == true
                                ? ElevatedButton(
                                    onPressed: _ndefWriteLock,
                                    child: const Text('Ndef Write Lock'))
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _mockNfcData() {
    Future.delayed(const Duration(seconds: 1), () {});
    setState(() {
      result.value =
          'Mock NFC Tag data: { "id": "123456789", "type": "NDEF", "content": "Hello, NFC!" }';
    });
  }

  void startNfcSession() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // Extract data from the tag
          result.value = tag.data;
          if (kDebugMode) {
            print('Data From Tag Read ::::::: ${result.value}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error reading NFC tag: $e');
          }
        } finally {
          // Ensure session is stopped
          NfcManager.instance.stopSession();
        }
      },
      onError: (e) async {
        if (kDebugMode) {
          print('Error starting NFC session: ${e.details.toString()}');
          print('Error starting NFC session: ${e.message}');
          print('com.Rafhan.NfcTest ${e.runtimeType}');
          print('Error starting NFC session: $e');
        }
      },
    );
  }

  // ignore: unused_element
  void _tagRead() {
    if (kDebugMode) {
      print('Befor func call of Tag Read');
    }
    try {
      if (kDebugMode) {
        print('Inside try 1');
      }
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          if (kDebugMode) {
            print('Inside try 2');
          }
          setState(() {
            result.value = tag.data;
          });
          
          
          if (kDebugMode) {
            print('Inside try 3');
          }
          if (kDebugMode) {
            print('Data From Tag Read ::::::: ${result.value}');
          }
          NfcManager.instance.stopSession();
          if (kDebugMode) {
            print('Inside try 4');
          }
        },
        onError: (e) async {
          if (kDebugMode) {
            print('Error reading NFC session: ${e.details.toString()}');
            print('Error reading NFC session: ${e.message}');
            print('Error reading NFC session: ${e.runtimeType}');
            print('Error reading NFC session: $e');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Inside Catch 1');
        print(e.toString());
      }
    }
  }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('Hello World!'),
        NdefRecord.createUri(Uri.parse('https://flutter.dev')),
        NdefRecord.createMime(
            'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal(
            'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}
