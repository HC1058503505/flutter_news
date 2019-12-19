import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
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
  WebViewController _webViewController;
  Rect currentPlayerRect;
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
        body: Stack(
          children: <Widget>[
            newsDetailWebView(),
            standbyPlayer()
          ],
        ),
    );
  }

  WebView newsDetailWebView () {
    return WebView(
              userAgent: "CGTN/iOS",
              onWebViewCreated: (controller){
                _webViewController = controller;
              },
              javascriptChannels: <JavascriptChannel>[
                webStateChangeJavascriptChannel(),
                standbyPlayerJavascriptChannel()
              ].toSet(),
              onPageStarted: (url) {
                print("onPageStarted: $url");
                
              },
              onPageFinished: (url) {
                print("onPageFinished: $url");
                // hideHeaderFooter();
              },
              initialUrl: widget.content["appUrl"] ?? "",
              javascriptMode: JavascriptMode.unrestricted
            );
  }

  JavascriptChannel webStateChangeJavascriptChannel () {
    // webViewReadyStateDidChange
    return JavascriptChannel(
      name: "webViewReadyStateDidChange",
      onMessageReceived: (javascriptMsg) {
          print(javascriptMsg.message);
      }
    );
  }

  Widget standbyPlayer () {
    return Positioned.fromRect(
            rect: currentPlayerRect ?? Rect.zero,
            child: Container(
              color: Colors.red,
            ),
          );
  }

  JavascriptChannel standbyPlayerJavascriptChannel () {
    return JavascriptChannel(
      name: "StandByPlayer",
      onMessageReceived: (javascriptMsg) {
          String jsonStr = javascriptMsg.message.replaceAll("=", ":").replaceAll(";", ",");
          print(jsonStr);
          dynamic msgJSON = jsonDecode(jsonStr);
          print(msgJSON);
          double x = double.tryParse(msgJSON["x"]) ?? 0;
          double y = double.tryParse(msgJSON["y"]) ?? 0;
          double width = double.tryParse(msgJSON["width"]) ?? 0;
          double height = double.tryParse(msgJSON["height"]) ?? 0;
          
          currentPlayerRect = Rect.fromLTWH(x, y, width, height);
          print(msgJSON);
          setState(() {});
      }
    );
  }

  void hideHeaderFooter () {
    String jsStr = '''
          let headeritemList = document.getElementsByClassName('cg-m-header') 
          for(let i = 0; i<headeritemList.length; i++){
            let element = headeritemList[i]
          　if (element) {
              element.style.display="none"
           }　
          }

          let footeritemList = document.getElementsByClassName('cg-footer')
          for(let i = 0; i<footeritemList.length; i++){
            let element = footeritemList[i]
          　if (element) {
              element.style.display="none"
           }　
          }
          ''';
    _webViewController.evaluateJavascript(jsStr);
  }
}