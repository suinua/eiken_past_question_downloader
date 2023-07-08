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

  await Future.forEach(grades, (grade) async {
    var gradePath = '$path/${grade.jp}';
    await Directory(gradePath).create();

    var client = http.Client();
    var url = 'https://www.eiken.or.jp/eiken/exam/grade_${grade.value}/';

    await client.get(Uri.parse(url)).then((value) async {
      var urls = getPdfUrls(grade, gradePath, utf8.decode(value.bodyBytes));
      //PDF
      for (var i = 0; i < urls.pdfUrls.length; i++){
        var name = urls.pdfUrls.keys.toList()[i];
        var url = urls.pdfUrls.values.toList()[i];
        download(url, name);
        await Future.delayed(Duration(seconds: 1));
      }

      //cd
      for (var i = 0; i < urls.cdUrls.length; i++){
        var name = urls.cdUrls.keys.toList()[i];
        var url = urls.cdUrls.values.toList()[i];
        download(url, name);
        await Future.delayed(Duration(seconds: 1));
      }
      //script
      for (var i = 0; i < urls.scriptUrls.length; i++){
        var name = urls.scriptUrls.keys.toList()[i];
        var url = urls.scriptUrls.values.toList()[i];
        download(url, name);
        await Future.delayed(Duration(seconds: 1));
      }
      //answer
      for (var i = 0; i < urls.answerUrls.length; i++) {
        var name = urls.answerUrls.keys.toList()[i];
        var url = urls.answerUrls.values.toList()[i];
        download(url, name);
        await Future.delayed(Duration(seconds: 1));
      }
    });
    await Future.delayed(Duration(seconds: 1));
  });
}

UrlBinder getPdfUrls(Grade grade, String gradePath, String html) {
  var pdfUrls = <String, String>{};
  var cdUrls = <String, String>{};
  var scriptUrls = <String, String>{};
  var answerUrls = <String, String>{};

  var year = '1';
  var time = '1';
  var name = '1';
  var yearEn = '';
  var timeEn = '';

  var document = parse(html);
  var links = document.querySelectorAll('a.c-btn.-red.-variable.-s_mini');
  links.forEach((aElement) {
      var split = aElement.text.split(' ');
      if (!aElement.className.contains('arrow')) {

        //book, answer, script
        if (split.length == 3) {
          year = split[0];
          time = split[1];
          name = split[2];

          yearEn = year.replaceAll('年度', '');
          timeEn = time.replaceAll('第', '').replaceAll('回', '');

          Directory('$gradePath/$year-$time').create();
          if (name == '問題冊子') {
            pdfUrls['$gradePath/$year-$time/$name.pdf'] =
            'https://www.eiken.or.jp/eiken/exam/kakomon/$yearEn-$timeEn-1ji-${grade.shortenJp}.pdf';
          } else if (name == '解答') {
            answerUrls['$gradePath/$year-$time/$name.pdf'] =
            'https://www.eiken.or.jp/eiken/exam/kakomon/$yearEn-$timeEn-${grade.shortenJp}.pdf';
          } else if(name == 'リスニング原稿'){
            scriptUrls['$gradePath/$year-$time/$name.pdf'] =
            'https://www.eiken.or.jp/eiken/exam/kakomon/$yearEn-$timeEn-1ji-${grade.shortenJp}-script.pdf';
          }
        } else if(split.length == 1) {
          //リスニング音源（Part1）
          if (split[0].contains('リスニング')) {
            var name = split[0].replaceFirst('）', '').replaceFirst('音源（', '');
            var lisTime = name.replaceFirst(RegExp('(.*)Part'), '');
            if (yearEn == '2023') {
              cdUrls['$gradePath/$year-$time/$name.mp3'] = 'http://media.eiken.or.jp/listening/grade_${grade.value}/${yearEn}0$timeEn/${grade.value}Qpart$lisTime.mp3';
            } else {
              cdUrls['$gradePath/$year-$time/$name.mp3'] = 'http://media.eiken.or.jp/listening/grade_${grade.value}/${yearEn}0$timeEn/${grade.value}Q-part$lisTime.mp3';
            }
          }
        }
      }
  });

  return UrlBinder(pdfUrls: pdfUrls, cdUrls: cdUrls, answerUrls: answerUrls, scriptUrls: scriptUrls);
}

void download(String url, String fileName) {
  var parsedUrl = HttpClient().getUrl(Uri.parse(url));
  parsedUrl.then((HttpClientRequest request) => request.close()).then(
      (HttpClientResponse response){
        if (response.statusCode != 200) {
          print(url);
          print(response.statusCode);
        }
        response.pipe(File(fileName).openWrite());
      });
}

class UrlBinder {
  final Map<String, String> pdfUrls;
  final Map<String, String> cdUrls;
  final Map<String, String> answerUrls;
  final Map<String, String> scriptUrls;

  UrlBinder({this.pdfUrls, this.cdUrls, this.answerUrls, this.scriptUrls});
}

class Grade {
  final String value;
  final String jp;
  final String shortenJp;

  Grade._(this.value, this.jp, this.shortenJp);

  static final five = Grade._('5', '5級','5kyu');
  static final four = Grade._('4', '4級','4kyu');
  static final three = Grade._('3', '3級','3kyu');
  static final preTwo = Grade._('p2', '準2級','p2kyu');
  static final two = Grade._('2', '2級','2kyu');
  static final preOne = Grade._('p1', '準1級','p1kyu');
  static final one = Grade._('1', '1級','1kyu');
}
