import 'package:ders_hatirlatici_web/single.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
List<Single> s = List<Single>.empty(growable: true);
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseFirestore.instance.collection("courses").get().then((value) {
    for (var result in value.docs) {
      List<String> dateTime = result.get('date').toString().split(' ');
      int day = int.parse(dateTime[0].split('/').first);
      int month = int.parse(dateTime[0].split('/')[1]);
      int year = int.parse(dateTime[0].split('/').last);
      s.add(Single(DateTime(year, month, day, int.parse(dateTime[1])) , result.get('course'), result.get('lecturer'), result.get('topic'), result.get('type'),));
    }
  });
  s.sort((a, b) => a.date.compareTo(b.date));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Ders Hatırlatıcı'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDate1 = DateTime.now(), selectedDate2 = DateTime.now();
  bool dt2Checked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckboxListTile(
              contentPadding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
              title: const Text("Aralıklı tarih seçme"),
              onChanged: (bool? value) {
                setState(() {
                  dt2Checked = value!;
                });
              },
              value: dt2Checked,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(onPressed: () async{
              final DateTime? pickedDate = await showDatePicker(
                helpText: "Başlangıç Tarihini Seçin:",
                context: context,
                initialDate: selectedDate1,
                firstDate: DateTime(2000),
                lastDate: selectedDate2,
              );
              setState((){
                if(pickedDate!=null){
                  selectedDate1 = pickedDate;
                }
              });
            }, icon: const Icon(Icons.date_range_sharp), label: Text(DateFormat('dd/MM/yyyy').format(selectedDate1)), style: ElevatedButton.styleFrom(primary: Colors.orange[200])),
            const Text('  -  ',),
            ElevatedButton.icon(onPressed: () async{
              final DateTime? pickedDate = await showDatePicker(
                helpText: "Bitiş Tarihini Seçin:",
                context: context,
                initialDate: selectedDate2,
                firstDate: selectedDate1,
                lastDate: DateTime(2025),
              );
              setState((){
                if(pickedDate!=null){
                  selectedDate2 = pickedDate;
                }
              });
            }, icon: const Icon(Icons.date_range_sharp), label: Text(DateFormat('dd/MM/yyyy').format(selectedDate2)), style: ElevatedButton.styleFrom(primary: Colors.orange[200])),
              ],
            ),
            const SizedBox(height: 25,),
            ElevatedButton.icon(onPressed: (){
              List<Single> toSendS = List.empty(growable: true);
              if(dt2Checked){
                for(Single single in s){
                  DateTime singleDt = DateTime(single.date.year, single.date.month, single.date.day);
                  DateTime selectedDt1 = DateTime(selectedDate1.year, selectedDate1.month, selectedDate1.day);
                  DateTime selectedDt2 = DateTime(selectedDate2.year, selectedDate2.month, selectedDate2.day);
                  if((singleDt.compareTo(selectedDt1) > -1 && singleDt.compareTo(selectedDt2) < 1)) {
                    toSendS.add(single);
                  }
                }
              }
              else{
                for(Single single in s){
                  DateTime singleDt = DateTime(single.date.year, single.date.month, single.date.day);
                  DateTime selectedDt = DateTime(selectedDate1.year, selectedDate1.month, selectedDate1.day);
                  if((singleDt.compareTo(selectedDt) == 0)) {
                    toSendS.add(single);
                  }
                }
              }
              if(toSendS.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarihde Ders Bulunamadı', textAlign: TextAlign.center)));
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>ListPageSend(currentS: toSendS, title: DateFormat('dd/MM/yyyy').format(selectedDate1)+" - " + DateFormat('dd/MM/yyyy').format(selectedDate2))));
              }
            }, icon: const Icon(Icons.list_rounded), label: const Text('Dersleri Listele'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
class ListPageSend extends StatefulWidget {
  final List<Single>? currentS;
  final String? title;
  ListPageSend({@required this.currentS, @required this.title});
  @override
  State<StatefulWidget> createState() {
    return ListPage(this.currentS, this.title);
  }
}
class ListPage extends State<ListPageSend> {
  List<Single>? currentS;
  String? title;
  List<Icon>? icons;
  ListPage(this.currentS, this.title);
  DataRow getDataRow(index) {
    return DataRow(
      // color: !save.listColored!?MaterialStateColor.resolveWith((states) => Colors.transparent):MaterialStateColor.resolveWith((states) => s[index].type == "UE"?Colors.orange[700]!:Colors.lightBlue[700]!),
      cells: <DataCell>[ 
        DataCell(Text(currentS![index].date.day.toString() + "/" + currentS![index].date.month.toString() + "/" + currentS![index].date.year.toString() +" - " + currentS![index].date.hour.toString()+":00")),
        DataCell(Text(currentS![index].course)),
        DataCell(Text(currentS![index].type)),
        DataCell(Text(currentS![index].topic)),
        DataCell(Text(currentS![index].lecturer)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: DataTable(
            columns: const[
              DataColumn(label: Text('Tarih')),
              DataColumn(label: Text('Sınıf')),
              DataColumn(label: Text('Tip')),
              DataColumn(label: Text('Konu')),
              DataColumn(label: Text('Eğitici')),
            ],
            rows: List.generate(currentS!.length, (index) => getDataRow(index))
          ),
        ),
      ),
    );}
}
