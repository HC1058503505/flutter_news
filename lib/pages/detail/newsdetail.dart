import 'dart:async';

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
  WebViewController _webViewController;
  bool startLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String newsTitle =
        widget.content["shortHeadline"] ?? widget.content["longHeadline"] ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text(newsTitle),
      ),
      body: Stack(
        children: <Widget>[newsDetailWebView(), loading(context)],
      ),
    );
  }

  WebView newsDetailWebView() {
    return WebView(
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onPageStarted: (url) {
        setState(() {
          startLoading = true;
        });
        hideHeaderFooter();
      },
      onPageFinished: (url) {
        Future.delayed(Duration(milliseconds: 1000), () {
          setState(() {
            startLoading = false;
          });
        });
      },
      initialUrl: widget.content["appUrl"] ?? "",
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  Widget loading(BuildContext context) {
    return Offstage(
      offstage: !startLoading,
      child: Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  void injectJS() {
    String jsStr = '''
          function hideElements() {
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

            let relatedStories = document.getElementsByClassName('relatedStories')
            for (let i = 0; i < relatedStories.length; i++) {
              let element = relatedStories[i];
              if (element) {
                element.style.display = "none"
              }
            }

            let moreFrom = document.getElementsByClassName('moreFrom')
            for (let i = 0; i < moreFrom.length; i++) {
              let element = moreFrom[i];
              if (element) {
                element.style.display = "none"
              }
            }

            let topNews = document.getElementsByClassName('topNews')
            for (let i = 0; i < topNews.length; i++) {
              let element = topNews[i];
              if (element) {
                element.style.display = "none"
              }
            }
          }
          ''';
    // Future.delayed(Duration(milliseconds: 500), () {
    // });
    _webViewController.evaluateJavascript(jsStr);
  }

  void hideHeaderFooter() {
    injectJS();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      _webViewController.evaluateJavascript("hideElements()");
      if (startLoading == false) {
        timer.cancel();
      }
    });
  }
}
