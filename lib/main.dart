import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:routine/model.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  List<String> daysname = [];
  List<CourseCard> filteredCourseCardList = [];
  String selectedDay = '';


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
    List<String> days = html
        .querySelectorAll('.day-btns .day-btn .day-name')
        .map((element) => element.text.trim())
        .toList();

    // Sort the list of days
    days.sort((a, b) {
      // Define the order of days
      List<String> order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      // Compare the indices of the days in the order list
      return order.indexOf(a) - order.indexOf(b);
    });
    print(days);
    return days;
  }
  List<CourseCard> parseCourseCards(dom.Document html) {
    List<CourseCard> parsedCards = [];

    html.querySelectorAll('.custom-col.card-container').forEach((dom.Element element) {
      final startingTime = element.querySelector('.starting-time')?.text.trim() ?? '';
      final endingTime = element.querySelector('.ending-time')?.text.trim() ?? '';
      final courseTitle = element.querySelector('.Course-Title-text strong')?.text.trim() ?? '';
      final courseCode = element.querySelector('.Course-code-text .code')?.text.trim() ?? '';
      final room = element.querySelector('.Room-text .room')?.text.trim() ?? '';
      final teacher = element.querySelector('.clickable-teacher .teacher')?.text.trim() ?? '';

      dom.Element? parent = element.parent;
      String? dayName;

      while (parent != null) {
        if (parent.classes.contains('day-card')) {
          dayName = parent.id;
          break;
        }
        parent = parent.parent;
      }

      final courseCard = CourseCard(
        startingTime: startingTime,
        endingTime: endingTime,
        courseTitle: courseTitle,
        courseCode: courseCode,
        room: room,
        teacher: teacher,
        day: dayName ?? '',
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

      daysname = extractDayNames(html);

      // Filter the routines based on the selected day
      filteredCourseCardList = courseCards
          .where((card) => daysname.contains(card.day))
          .toList();

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

  List<DateTime> getDatesForDays(List<String> days) {
    DateTime now = DateTime.now();
    List<DateTime> result = [];

    for (String day in days) {
      switch (day) {
        case 'Mon':
          result.add(now.add(Duration(days: DateTime.monday - now.weekday + 7)));
          break;
        case 'Tue':
          result.add(now.add(Duration(days: DateTime.tuesday - now.weekday + 7)));
          break;
        case 'Wed':
          result.add(now.add(Duration(days: DateTime.wednesday - now.weekday + 7)));
          break;
        case 'Thu':
          result.add(now.add(Duration(days: DateTime.thursday - now.weekday + 7)));
          break;
        case 'Fri':
          result.add(now.add(Duration(days: DateTime.friday - now.weekday + 7)));
          break;
        case 'Sat':
          result.add(now.add(Duration(days: DateTime.saturday - now.weekday + 7)));
          break;
        case 'Sun':
          result.add(now.add(Duration(days: DateTime.sunday - now.weekday + 7)));
          break;
      }
    }

    //result.sort((a, b) => a.compareTo(b));

    return result;
  }

  @override
  void initState() {
    super.initState();
    this.getDeptList();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = getDatesForDays(daysname);
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: Text('DIU Routine'),centerTitle: true,elevation: 1,),
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
            SizedBox(height: 15,),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: a,
                  decoration: InputDecoration(
                      labelText: 'Section Name',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        await getwebsiteData();
                      }
                    },
                    child: Text('Get Routine')),
              ),
            ),
            SizedBox(height: 15,),
            Container(
              alignment: Alignment.center,
              height: 120,
              width: double.infinity,
              child: Center(
                child: ListView.builder(
                scrollDirection: Axis.horizontal, // scroll horizontally if there are many days
                itemCount: daysname.length,
                itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: (){
                      setState(() {
                        // Update the selected day
                        selectedDay = daysname[index];
                        filteredCourseCardList = courseCardList
                            .where((card) => card.day == selectedDay)
                            .toList();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration:BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: selectedDay == daysname[index] ? [
                              BoxShadow(
                                color: Colors.grey[500]!,
                                offset: Offset(4,4),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4,-4),
                                blurRadius: 5,
                                spreadRadius: 1,
                              )
                            ] : null
                        ),
                        height: 10,
                        width: (MediaQuery.of(context).size.width / daysname.length) - 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('MMM').format(DateTime.now())),
                            SizedBox(height: 5,),
                            Text(DateFormat('dd').format(dates[index]),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22),),
                            SizedBox(height: 5,),
                            Text(daysname[index]),
                          ],
                        ),
                      ),
                    ),
                  );
                },),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCourseCardList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(filteredCourseCardList[index].startingTime,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      height: 60,
                                      width: 1.0,
                                      color: Colors.black!.withOpacity(0.7),
                                    ),
                                    Text(filteredCourseCardList[index].endingTime,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15,),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(filteredCourseCardList[index].courseTitle,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Divider(height: 1),
                                  SizedBox(height: 5,),
                                  Text(filteredCourseCardList[index].courseCode,style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: Text('Room : ${filteredCourseCardList[index].room}')),
                                      Expanded(child: Text('Teacher : ${filteredCourseCardList[index].teacher}')),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text('Day : ${filteredCourseCardList[index].day}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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