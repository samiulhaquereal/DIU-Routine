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
  List<CourseCard> courseCardList = [];
  List<String> deptList = [];
  List<String> routineVersion = [];
  String selectedDepartment = '';
  final url = Uri.parse('http://routine.zohirrayhan.me/');

  Future getDeptList() async {
    final url = Uri.parse('http://routine.zohirrayhan.me/');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    deptList = html
        .querySelector('#department')!
        .querySelectorAll('option')
        .map((element) => element.text.trim())
        .toList();

    selectedDepartment = deptList.first;
    setState(() {
    });
  }
  List<String> extractDayNames(dom.Document html) {
    return html
        .querySelectorAll('.day-btns .day-btn .day-name')
        .map((element) => element.text.trim())
        .toList();
  }

  List<CourseCard> parseCourseCards(dom.Document html) {
    List<CourseCard> parsedCards = [];

    html.querySelectorAll('.custom-col.card-container').forEach((element) {
      final startingTime = element.querySelector('.starting-time')?.text.trim() ?? '';
      final endingTime = element.querySelector('.ending-time')?.text.trim() ?? '';
      final courseTitle = element.querySelector('.Course-Title-text strong')?.text.trim() ?? '';
      final courseCode = element.querySelector('.Course-code-text .code')?.text.trim() ?? '';
      final room = element.querySelector('.Room-text .room')?.text.trim() ?? '';
      final teacher = element.querySelector('.clickable-teacher .teacher')?.text.trim() ?? '';
      final dayButtons = html.querySelectorAll('.day-btns .day-btn.active-button');
      final day = dayButtons.isNotEmpty ? dayButtons.first.attributes['data-day'] : '';
      final dayName = dayButtons.isNotEmpty ? dayButtons.first.querySelector('.day-name')?.text.trim() : '';




      final courseCard = CourseCard(
        startingTime: startingTime,
        endingTime: endingTime,
        courseTitle: courseTitle,
        courseCode: courseCode,
        room: room,
        teacher: teacher,
        day: dayName
      );

      parsedCards.add(courseCard);
    });

    return parsedCards;
  }

  Future getwebsiteData() async {
    // Simulate form submission
    final response2 = await http.post(
      url,
      body: {
        'view_mode': 'student', // Set to 'student' for the Student option
        'department': selectedDepartment, // Set the department value
        'batch': a.text,
      },
    );

    final response3 = await http.get(url);
    dom.Document html = dom.Document.html(response3.body);
    routineVersion = html
        .querySelectorAll('#version')
        .map((element) => element.text.trim())
        .toList();

    print(routineVersion);


    if (response2.statusCode == 200) {
      final html = dom.Document.html(response2.body);
      final courseCards = parseCourseCards(html);

      final dayNames = extractDayNames(html);

      // Display the list of day names
      print(dayNames);

      setState(() {
        courseCardList.clear();
        courseCardList.addAll(courseCards);
        print(courseCardList.length);
      });

      print('Done');
    } else {
      print('Failed to submit form. Status code: ${response2.statusCode}');
    }

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
            Expanded(
              child: ListView.builder(
                itemCount: courseCardList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(courseCardList[index].courseTitle,style: TextStyle(color: Colors.black),),
                    subtitle: Text('${courseCardList[index].courseCode}\nRoom : ${courseCardList[index].room}\nTeacher : ${courseCardList[index].teacher}\nStart : ${courseCardList[index].startingTime}\nEnd : ${courseCardList[index].endingTime}\nDay : ${courseCardList[index].day}'),
                    // Add more details if needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
