import 'package:flutter/material.dart';
import 'package:Cubetrone/uploading.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  late RichTextController _controller;
  String _outputText = '';
  String? _selectedBoard;
  final List<String> _boardOptions = ['Master', 'Slave'];
  String _selectedPort = '';
  List<String> _availablePorts = [];
  bool _isUploading = false;
  Timer? _portTimer;
  final List<String> mainItems = [
    "Master",
    "DC Motor",
    "Ultrasonic",
    "OLED Display"
  ];
  final Map<String, List<String>> subItems = {
    "Master": ["sound()"],
    "DC Motor": ["greenmotor()", "redmotor()", "car()"],
    "Ultrasonic": ["ultrasonic()"],
    "OLED Display": ["tvprint()"],
  };

  @override
  void initState() {
    super.initState();
    _controller = RichTextController(
      text:
          '#include<CubeTrone.h>\nCubeTrone c;\nvoid setup() {\n c.begin();\n // put your setup code here, to run once:\n\n}\n\nvoid loop() {\n  // put your main code here, to run repeatedly:\n\n}',
      patternMatchMap: {
        RegExp(
          r'//.*|/\*[\s\S]*?\*/',
        ): const TextStyle(color: Colors.grey),
        RegExp(
          r'<[\s\S]*?>',
        ): const TextStyle(color: Color(0xFF177B50)),
        RegExp(
          "setup|loop|delay|SoftwareSerial|Serial|bluetoothSerial|begin|sound|greenmotor|redmotor|car|ultrasonic|tvprint|available|readStringUntil|readString|println|print|pinMode|digitalWrite|digitalRead|analogWrite|analogRead|/g",
        ): const TextStyle(color: Colors.deepOrangeAccent),
        RegExp(
          "CubeTrone|void|bool|int|short|long|float|double|char|String|enum|const|class|/g",
        ): const TextStyle(color: Color(0xFF177B50)),
        RegExp(
          "for|do|while|if|else|case|continue|default|break|try|catch|#include|/g",
        ): const TextStyle(color: Color(0xFF9A368A)),
      },
      onMatch: (List<String> matches) {},
    );
    availablePorts();
    portPolling();
  }

  @override
  void dispose() {
    _controller.dispose();
    _portTimer?.cancel();
    super.dispose();
  }

  void availablePorts() async {
    Process.run('arduino-cli', [
      'board',
      'list',
      '--format',
      'json',
    ]).then((ProcessResult boardListResult) {
      if (boardListResult.exitCode == 0) {
        try {
          Map<String, dynamic> boardList = jsonDecode(boardListResult.stdout);
          List<dynamic> detectedPorts = boardList['detected_ports'];
          List<String> ports = detectedPorts
              .map((port) => port['port']['address'] as String)
              .toList();
          setState(() {
            _availablePorts = ports;
            if (!_availablePorts.contains(_selectedPort)) {
              _selectedPort = '';
            }
          });
        } catch (e) {
          setState(() {
            _outputText = 'Error parsing board list \u{1F614} $e';
          });
        }
      } else {
        setState(() {
          _outputText =
              'Failed to get board list \u{1F614} ${boardListResult.stderr}';
        });
      }
    });
  }

  void portPolling() {
    _portTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      availablePorts();
    });
  }

  void compileAndUpload() async {
    setState(() {
      _isUploading = true;
    });
    final String boardType = _selectedBoard == 'Master'
        ? 'arduino:avr:uno'
        : 'arduino:avr:attiny:cpu=attiny85';
    final codeFile = File('Cubetrone.ino');
    await codeFile.writeAsString(_controller.text);

    Process.run('arduino-cli', [
      'compile',
      '--fqbn',
      boardType,
      codeFile.path,
    ]).then((ProcessResult compileResult) {
      if (compileResult.exitCode == 0) {
        setState(() {
          _outputText = 'Compilation successful! \u{1F601}\n';
        });

        if (_selectedPort.isNotEmpty) {
          Process.run('arduino-cli', [
            'upload',
            '-p',
            _selectedPort,
            '--fqbn',
            boardType,
            codeFile.path,
          ]).then((ProcessResult uploadResult) {
            if (uploadResult.exitCode == 0) {
              setState(() {
                _outputText += 'Upload successful! \u{1F601}';
                _isUploading = false;
              });
            } else {
              setState(() {
                _outputText += 'Upload failed \u{1F614} ${uploadResult.stderr}';
                _isUploading = false;
              });
            }
          });
        } else {
          setState(() {
            _outputText += 'No port selected for upload';
            _isUploading = false;
          });
        }
      } else {
        setState(() {
          _outputText = 'Compilation failed \u{1F614} ${compileResult.stderr}';
          _isUploading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _outputText = 'Error occurred \u{1F614} $error';
        _isUploading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.125,
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10.0)),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.825,
            left: MediaQuery.of(context).size.width * 0.125,
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Text(
                _outputText,
                style: const TextStyle(color: Color(0xFF3B82F6)),
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.025,
            left: MediaQuery.of(context).size.width * 0.82,
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.135,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ElevatedButton(
                  onPressed: compileAndUpload,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  child: _isUploading
                      ? Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: SizedBox(
                                height: constraints.maxHeight,
                                width: constraints.maxWidth * 0.2,
                                child: const Uploading(),
                              ),
                            ),
                            Positioned(
                              top: constraints.maxHeight * 0.2,
                              left: constraints.maxWidth * 0.3,
                              child: Text(
                                'Uploading',
                                style: TextStyle(
                                  color: const Color(0xFFF97316),
                                  fontSize: constraints.maxWidth * 0.09,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                'images/Logo1.png',
                                height: constraints.maxHeight,
                                width: constraints.maxWidth * 0.2,
                              ),
                            ),
                            Positioned(
                              top: constraints.maxHeight * 0.2,
                              left: constraints.maxWidth * 0.3,
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                  color: const Color(0xFFF97316),
                                  fontSize: constraints.maxWidth * 0.09,
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.025,
            left: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF97316)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownButton(
                    padding: EdgeInsets.only(left: constraints.maxWidth * 0.1),
                    value: _selectedBoard,
                    hint: Text(
                      'Select Board',
                      style: TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: constraints.maxWidth * 0.125,
                          fontWeight: FontWeight.w500),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: const Color(0xFFFFFFFF),
                      size: constraints.maxWidth * 0.125,
                    ),
                    underline: Container(),
                    dropdownColor: const Color(0xFFF97316),
                    style: TextStyle(
                        color: const Color(0xFFFFFFFF),
                        fontSize: constraints.maxWidth * 0.125,
                        fontWeight: FontWeight.w500),
                    borderRadius: BorderRadius.circular(8),
                    items: _boardOptions
                        .map((board) => DropdownMenuItem(
                              value: board,
                              child: Text(board),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBoard = newValue!;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.025,
            left: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF97316)),
              child: LayoutBuilder(builder: (context, constraints) {
                return DropdownButton(
                  padding: EdgeInsets.only(left: constraints.maxWidth * 0.15),
                  value: _selectedPort.isNotEmpty ? _selectedPort : null,
                  hint: Text(
                    'Select Port',
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: constraints.maxWidth * 0.128,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down,
                      color: const Color(0xFFFFFFFF),
                      size: constraints.maxWidth * 0.128),
                  underline: Container(),
                  dropdownColor: const Color(0xFFF97316),
                  style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: constraints.maxWidth * 0.128,
                      fontWeight: FontWeight.w500),
                  borderRadius: BorderRadius.circular(8),
                  items: _availablePorts
                      .map((port) => DropdownMenuItem(
                            value: port,
                            child: Text(port),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPort = newValue!;
                    });
                  },
                );
              }),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.125,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: ElevatedButton(
              onPressed: () {
                final int cursorPosition = _controller.selection.base.offset;
                const String ifStatement = 'if( ) {\n //add your code\n\n}\n';
                _controller.text =
                    _controller.text.substring(0, cursorPosition) +
                        ifStatement +
                        _controller.text.substring(cursorPosition);
                _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: cursorPosition + ifStatement.length));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: Text(
                'if',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: MediaQuery.of(context).size.width * 0.0125,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.225,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: ElevatedButton(
              onPressed: () {
                final int cursorPosition = _controller.selection.base.offset;
                const String elseIfStatement =
                    'else if( ) {\n //add your code\n\n}\n';
                _controller.text =
                    _controller.text.substring(0, cursorPosition) +
                        elseIfStatement +
                        _controller.text.substring(cursorPosition);
                _controller.selection = TextSelection.fromPosition(TextPosition(
                    offset: cursorPosition + elseIfStatement.length));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: Text(
                'else if',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: MediaQuery.of(context).size.width * 0.0125,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.325,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: ElevatedButton(
              onPressed: () {
                final int cursorPosition = _controller.selection.base.offset;
                const String elseStatement = 'else {\n //add your code\n\n}\n';
                _controller.text =
                    _controller.text.substring(0, cursorPosition) +
                        elseStatement +
                        _controller.text.substring(cursorPosition);
                _controller.selection = TextSelection.fromPosition(TextPosition(
                    offset: cursorPosition + elseStatement.length));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: Text(
                'else',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: MediaQuery.of(context).size.width * 0.0125,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.425,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: ElevatedButton(
              onPressed: () {
                final int cursorPosition = _controller.selection.base.offset;
                const String forStatement = 'for( ) {\n //add your code\n\n}\n';
                _controller.text =
                    _controller.text.substring(0, cursorPosition) +
                        forStatement +
                        _controller.text.substring(cursorPosition);
                _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: cursorPosition + forStatement.length));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: Text(
                'for',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: MediaQuery.of(context).size.width * 0.0125,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.525,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: ElevatedButton(
              onPressed: () {
                final int cursorPosition = _controller.selection.base.offset;
                const String whileStatement =
                    'while( ) {\n //add your code\n\n}\n';
                _controller.text =
                    _controller.text.substring(0, cursorPosition) +
                        whileStatement +
                        _controller.text.substring(cursorPosition);
                _controller.selection = TextSelection.fromPosition(TextPosition(
                    offset: cursorPosition + whileStatement.length));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: Text(
                'while',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: MediaQuery.of(context).size.width * 0.0125,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.625,
            left: MediaQuery.of(context).size.width * 0.025,
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.075,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF3B82F6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return PopupMenuButton(
                    tooltip: '',
                    color: const Color(0xFF3B82F6),
                    itemBuilder: (BuildContext context) {
                      return mainItems.map((item) {
                        return PopupMenuItem(
                          value: item,
                          child: PopupMenuButton(
                            tooltip: '',
                            color: const Color(0xFF3B82F6),
                            itemBuilder: (BuildContext context) {
                              return subItems[item]!.map((subItem) {
                                return PopupMenuItem(
                                  value: subItem,
                                  child: Text(
                                    subItem,
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            onSelected: (subItem) {
                              if (subItem == "sound()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String soundStatement =
                                    'c.sound() //int x';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    soundStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            soundStatement.length));
                              } else if (subItem == "greenmotor()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String greenmotorStatement =
                                    'c.greenmotor() //int x';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    greenmotorStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            greenmotorStatement.length));
                              } else if (subItem == "redmotor()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String redmotorStatement =
                                    'c.redmotor() //int x';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    redmotorStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            redmotorStatement.length));
                              } else if (subItem == "car()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String carStatement = 'c.car() //int x';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    carStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            carStatement.length));
                              } else if (subItem == "ultrasonic()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String ultrasonicStatement =
                                    'c.ultrasonic() //return the distance';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    ultrasonicStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            ultrasonicStatement.length));
                              } else if (subItem == "tvprint()") {
                                final int cursorPosition =
                                    _controller.selection.base.offset;
                                const String tvprintStatement =
                                    'c.tvprint() //int x';
                                _controller.text = _controller.text
                                        .substring(0, cursorPosition) +
                                    tvprintStatement +
                                    _controller.text.substring(cursorPosition);
                                _controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: cursorPosition +
                                            tvprintStatement.length));
                              }
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.113,
                              child: Row(
                                children: [
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: const Color(0xFFFFFFFF),
                                    size: constraints.maxWidth * 0.125,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    child: Row(
                      children: [
                        Text(
                          "CubeTrone",
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: constraints.maxWidth * 0.165,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: const Color(0xFFFFFFFF),
                          size: constraints.maxWidth * 0.125,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
