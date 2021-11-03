import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

void main() async {
  var path = '';
  await Directory(path).create();
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
    var gradePath = '$path/${grade.jp}';
    Directory(gradePath).create();

    var client = http.Client();
    var url =
        'https://www.eiken.or.jp/eiken/exam/grade_${grade.value}/solutions.html';

    client.get(Uri.parse(url)).then((value) {
      //PDF
      var urls = getPdfUrls(grade, gradePath, utf8.decode(value.bodyBytes));
      urls.forEach((name, url) => download(url, '$name.pdf'));
    });
  });
}

Map<String, String> getPdfUrls(Grade grade, String gradePath, String html) {
  var urls = <String, String>{};
  var document = parse(html);
  var links = document.querySelectorAll('li.pdf');
  links.forEach((element) {
    element.firstChild.attributes.forEach((key, value) {
      if (key == 'href') {
        if (element.text != '問題と解答のサンプル') {
          var split = element.text.split(' ');
          if (split.length == 3) {
            var year = split[0];
            var time = split[1];
            var name = split[2];

            Directory('$gradePath/$year-$time').create();
            urls['$gradePath/$year-$time/$name'] = 'http://www.eiken.or.jp:80/' + value;
            if (name == '解答') {
              var yearEn = year.replaceAll('年度', '');
              var timeEn = time.replaceAll('第', '').replaceAll('回', '');
              for (var lisTime = 1; lisTime < 4; lisTime++) {
                var cdUrl = 'http://media.eiken.or.jp/listening/grade_${grade.value}/${yearEn}0$timeEn/${grade.value}Q-part$lisTime.mp3';
                download(cdUrl, '$gradePath/$year-$time/リスニングPart$lisTime.mp3');
              }
            }
          }
        }
      }
    });
  });

  return urls;
}

void download(String url, String fileName) {
  var parsedUrl = HttpClient().getUrl(Uri.parse(url));
  print(url);
  parsedUrl.then((HttpClientRequest request) => request.close()).then(
      (HttpClientResponse response) =>
          response.pipe(File(fileName).openWrite()));
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
