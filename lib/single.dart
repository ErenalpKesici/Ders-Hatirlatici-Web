
class Single{
  late DateTime date;
  late String course;
  late String lecturer;
  late String topic;
  late String type;
  Single(this.date, this.course, this.lecturer, this.topic, this.type);
  @override
  String toString() {
    return this.course + " " + this.lecturer + " " + this.topic  + " " + this.type + " " + this.date.toString();
  }
}