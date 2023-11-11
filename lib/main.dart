import 'package:flutter/material.dart';
import 'package:routine/model.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var a = TextEditingController();
  List<Routine> routineList = [];
  List<String> deptList = [];
  String selectedDepartment = '';
  final url = Uri.parse('http://routine.zohirrayhan.me/');

  Future getDeptList() async {
    final url = Uri.parse('http://routine.zohirrayhan.me/');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);
    print(html);

    deptList = html
        .querySelector('#department')!
        .querySelectorAll('option')
        .map((element) => element.text.trim())
        .toList();

    selectedDepartment = deptList.first;
    print('Count: ${deptList}');
  }

  Future getwebsiteData() async {
    print(a.text);
    // Simulate form submission
    final response2 = await http.post(
      url,
      body: {
        'view_mode': 'student', // Set to 'student' for the Student option
        'department': selectedDepartment, // Set the department value
        'batch': a.text,
      },
    );

    if (response2.statusCode == 200) {
      // Parse the HTML response
      //dom.Document html = dom.Document.html(response.body);
      print('Done');
      // Now you can extract data from the response HTML
      // Add your parsing logic here
    } else {
      print('Failed to submit form. Status code: ${response2.statusCode}');
    }

    //print('Count: ${urls.length}');
    //print('Count: ${pic.length}');

    /*for (final title1 in titles) {
      debugPrint(title1);
    }
    for (final title in urls) {
      debugPrint(title);
    }*/
    /*for (final title in pic) {
      debugPrint(title);
    }*/
/*
    setState(() {
      routineList = List.generate(titles.length, (index) =>
          Routine(
              courseTitle: '',
              courseCode: '',
              roomId: '',
              teacherIn: '',
              Stime: '',
              Etime: ''

          )
      );
    });*/
  }

  @override
  void initState() {
    super.initState();
    this.getDeptList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedDepartment, // Default value
              onChanged: (String? newValue) {
                setState(() {
                  selectedDepartment = newValue!;
                });
              },
              items: deptList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: TextField(
                controller: a,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  print(a.text);
                  await getwebsiteData();
                },
                child: Text('Find')),
          ],
        ),
      ),
    ));
  }
}
