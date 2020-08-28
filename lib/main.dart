import 'dart:convert';
import 'dart:html' show AnchorElement, html;

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:reporte_vehiculos/utils/GeometricClipper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporte del sistema',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pagina principal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _date1;
  DateTime _date2;



  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var titleStyle=TextStyle(
      color: Colors.white,
      fontSize: 30,
    );

    var subtitleStyle=TextStyle(
      color: const Color (0xff8d99ae),
      fontSize: 24,
      
    );

    var normalTextStyle=TextStyle(
      color: Colors.white,
      fontSize: 20,
    );

    return Scaffold(
      backgroundColor: const Color (0xfffca311),
      body: Stack(
        children: [
          //this is empty to screen
          Container(
            width: width,
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image(image: AssetImage('images/car.png'))
              ],
            ),
          ),
          ClipPath(
            clipper: GeometricClipper(),
            child: Container(
              width: width,
              height: height * 0.75,
              color: const Color(0xff14213d ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Software de reportes', style: titleStyle,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Permite descargar el reporte de tus vehiculos, para comenzar selecciona las fechas en las que se va a realizar el registro.',
                        style: subtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Desde', style: normalTextStyle,),
                            InkWell(
                              onTap: () {
                                showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now())
                                    .then((data) {
                                  setState(() {
                                    _date1 = data;
                                  });
                                });
                              },
                              child: _date1 == null
                                  ? Icon(Icons.calendar_today, size: 24, color: Colors.white,)
                                  : Text('${formatDate(_date1)}',style: normalTextStyle),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Hasta', style: normalTextStyle,),
                            InkWell(
                              onTap: () {
                                showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now())
                                    .then((data) {
                                  setState(() {
                                    _date2 = data;
                                  });
                                });
                              },
                              child: _date2 == null
                                  ? Icon(Icons.calendar_today, size: 24, color: Colors.white,)
                                  : Text('${formatDate(_date2)}', style: normalTextStyle,),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: SizedBox(
                        width: width * 0.2,
                        child: RaisedButton(
                            color: const Color(0xfffca311),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Descargar reporte',
                                style: normalTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onPressed: _date1 != null && _date2 != null
                                ? () {
                                    generateExcelFile();
                                  } //else
                                : null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void generateExcelFile() async {
    ByteData data =
        await rootBundle.load('xlsx/plantilla_reporte_carros_personas.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Hoja1'];

    CellStyle cellStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Left
        );

    //Hora Reporte

    var cell = sheetObject.cell(CellIndex.indexByString("B2"));
    cell.value = formatDate(DateTime.now()); // dynamic values support provided;
    cell.cellStyle = cellStyle;

    //Desde
    cell = sheetObject.cell(CellIndex.indexByString("D2"));
    cell.value = formatDate(_date1); // dynamic values support provided;
    cell.cellStyle = cellStyle;

    //Hasta
    cell = sheetObject.cell(CellIndex.indexByString("F2"));
    cell.value = formatDate(_date2); // dynamic values support provided;
    cell.cellStyle = cellStyle;

    //Consultar


    excel.encode().then((value){
      final content = base64Encode(value);
      downloadFile(content);
    });

    
  }

  void downloadFile(var content) async {
    //the base64 is needed to the download
    final anchor = AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "file.xlsx")
      ..click();
  }

  String formatDate(date){
    return  DateFormat('dd-MM-yyyy').format(date.toUtc());
  }
}
