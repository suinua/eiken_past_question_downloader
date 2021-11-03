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
  static String cd(Grade grade, int year, int time, int no) =>
      'https://s3-ap-northeast-1.amazonaws.com/eiken.obunsha.co.jp/audio/${grade.value}/${grade.value}_${year}_${time}_no$no.mp3';
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
