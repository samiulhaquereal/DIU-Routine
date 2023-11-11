class CourseCard {
  final String startingTime;
  final String endingTime;
  final String courseTitle;
  final String courseCode;
  final String room;
  final String teacher;
  final String? day;

  CourseCard({
    required this.startingTime,
    required this.endingTime,
    required this.courseTitle,
    required this.courseCode,
    required this.room,
    required this.teacher,
    required this.day,
  });
}