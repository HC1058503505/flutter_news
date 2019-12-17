import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
class HomeDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeDrawerState();
  }
}

class _HomeDrawerState extends State<HomeDrawer> {
  List sections;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSectionsArray();
  }

  getSectionsArray () async {
    // https://api.cgtn.com/app/api/news/sections?appChannelId=1000&appVersion=5.6.5_1909240955&deviceModel=x86_64_Simulator&deviceOsType=0
    Map<String , String> params = {
      "appChannelId" : "1000",
      "appVersion" : "5.6.5_1909240955",
      "deviceModel" : "x86_64",
      "deviceOsType" : "0"
    };
    Uri sectionsUri = Uri.https("api.cgtn.com", "/app/api/news/sections", params);
    var httpClient = HttpClient();
    var httpClientRequest = await httpClient.getUrl(sectionsUri);
    var httpClientResponse = await httpClientRequest.close();
    var result = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> resultJSON = jsonDecode(result);

    if(!resultJSON.containsKey("data")) {
      return;
    }
    List<dynamic> trendings = [
      { 
        "id" : 20,
        "name" : "Trending Videos"
      },
      { 
        "id" : 20,
        "name" : "Trending Pictures"
      },
      { 
        "id" : 20,
        "name" : "Transcript"
      }
    ];
    sections = resultJSON["data"];
    sections.addAll(trendings);
    setState(() {
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: TextField(),
          ),
          ListTile(
            title: Text("Home"),
            onTap: () {},
          ),
          ListTile(
            title: Text("Most Read"),
            onTap: () {},
          ),
          ListTile(
            title: Text("Most Shared"),
            onTap: () {},
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: Text("News"),
            children: sections?.map((section) {
              Map<String, dynamic> sectionMap = section as Map<String, dynamic>;
              if (sectionMap?.containsKey("name") ?? false) {
                return ListTile(
                        contentPadding: EdgeInsets.only(left: 40),
                        title: Text(section["name"]),
                        onTap: () {
                          // 点击sectioncell
                        },
                      );
              }

              return Container();
            })?.toList() ?? List<Widget>(),
          )
        ],
      ),
    );
  }
}
