import 'dart:io';

void main(List<String> arguments) {
  
  var grade = Grade.preOne;
  for (var year = 2017; year < 2020; year++) {
    for (var time = 1; time < 4; time++) {

      var questionsUrl = UrlGenerator.questions(grade, year, time);
      download(questionsUrl, '問題/問題$year-$time.pdf');

      var answerUrl = UrlGenerator.answer(grade, year, time);
      download(answerUrl, '答え/答え$year-$time.pdf');

      var scriptUrl = UrlGenerator.script(grade, year, time);
      download(scriptUrl, 'スクリプト/スクリプト$year-$time.pdf');

      //動かん；；
      //for (var part = 1; part < 4; part++) {
      //  var cdUrl = UrlGenerator.cd(grade, year, time, part);
      //  Directory('$year-cd').create();
      //  download(cdUrl, '$year-cd/cd$year-$time-$part.pdf');
      //}
    }
  }
}

void download(String url, String fileName) {
  var parsedUrl = HttpClient().getUrl(Uri.parse(url));
  print(url);
  //parsedUrl.then((HttpClientRequest request) => request.close()).then(
  //    (HttpClientResponse response) =>
  //        response.pipe(File("D:/英検準1級/" + fileName).openWrite()));
}

class UrlGenerator {
  //preTwo Two は最後に-sun
  static String answer(Grade grade, int year, int time) =>
      'https://web.archive.org/web/${year + 1}0319020032if_/http://www.eiken.or.jp:80/eiken/exam/grade_${grade.value}/pdf/${year}0$time/${grade.value}kyu.pdf';

  static String questions(Grade grade, int year, int time) =>
      'https://web.archive.org/web/${year + 1}0419020032if_/http://www.eiken.or.jp:80/eiken/exam/grade_${grade.value}/pdf/${year}0$time/$year-$time-1ji-${grade.value}kyu.pdf';

  static String script(Grade grade, int year, int time) =>
      'https://web.archive.org/web/${year + 1}0419020032if_/https://www.eiken.or.jp/eiken/exam/grade_${grade.value}/pdf/${year}0$time/$year-$time-1ji-${grade.value}kyu-script.pdf';

  //static String cd(Grade grade, int year, int time, int part) =>
  //    'https://web.archive.org/web/20190302034608/http://media.eiken.or.jp/listening/grade_${grade.value}/${year}0$time/${grade.value}-part$part.mp3';
}

class Grade {
  final String value;
  Grade._(this.value);

  static final preTwo = Grade._('p2');
  static final two = Grade._('2');
  static final preOne = Grade._('p1');
  static final one = Grade._('1');
}
