import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class NewsDetail extends StatefulWidget {
  final Map<String, dynamic> content;
  NewsDetail({this.content});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewsDetailState();
  }
}

class _NewsDetailState extends State<NewsDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: WebView(
        userAgent: "CGTN/iOS",
        initialUrl: widget.content["appUrl"] ?? "",
      ),
    );
  }
}