import 'dart:io';

void main() {
  var path = '';
  var grades = [
    Grade.five,
    Grade.four,
    Grade.three,
    Grade.preTwo,
    Grade.two,
    Grade.preOne,
    Grade.one
  ];

  grades.forEach((grade) {
    Directory('$path').create();
    Directory('$path/${grade.jp}').create();

    var year = 2021;

    var yearPath = '$path/${grade.jp}/$year';
    Directory(yearPath).create();

    for (var time = 1; time < 4; time++) {
      var timePath = '$yearPath/$time';
      Directory(timePath).create();

      var questionsUrl = UrlGenerator.questions(grade, year, time);
      download(questionsUrl, timePath, '問題.pdf');

      var answerUrl = UrlGenerator.answer(grade, year, time);
      download(answerUrl, timePath, '答え.pdf');

      var scriptUrl = UrlGenerator.script(grade, year, time);
      download(scriptUrl, timePath, '解答.pdf');

      for (var part = 1; part < 4; part++) {
        var cdUrl = UrlGenerator.cd(grade, year, time, part);
        download(cdUrl, timePath, '音源$part.mp4');
      }
    }
  });
}

void download(String url, String path, String fileName) {
  var parsedUrl = HttpClient().getUrl(Uri.parse(url));
  print(url);
  parsedUrl.then((HttpClientRequest request) => request.close()).then(
      (HttpClientResponse response) =>
          response.pipe(File('$path/$fileName').openWrite()));
}

class UrlGenerator {
  static const String mega = 'https://megalodon.jp/2020-0215-2006-26/';

  static String answer(Grade grade, int year, int time) =>
      mega + 'http://www.eiken.or.jp:80/eiken/exam/grade_${grade.value}/pdf/${year}0$time/${grade.value}kyu.pdf';

  static String questions(Grade grade, int year, int time) =>
      mega +'http://www.eiken.or.jp:80/eiken/exam/grade_${grade.value}/pdf/${year}0$time/$year-$time-1ji-${grade.value}kyu.pdf';

  static String script(Grade grade, int year, int time) =>
      mega +'https://www.eiken.or.jp/eiken/exam/grade_${grade.value}/pdf/${year}0$time/$year-$time-1ji-${grade.value}kyu-script.pdf';

  static String cd(Grade grade, int year, int time, int part) =>
      mega +'http://media.eiken.or.jp/listening/grade_${grade.value}/${year}0$time/${grade.value}-part$part.mp3';
}

class Grade {
  final String value;
  final String jp;

  Grade._(this.value, this.jp);

  static final five = Grade._('5', '5級');
  static final four = Grade._('4', '4級');
  static final three = Grade._('3', '3級');
  static final preTwo = Grade._('p2', '準2級');
  static final two = Grade._('2', '2級');
  static final preOne = Grade._('p1', '準1級');
  static final one = Grade._('1', '1級');
}
