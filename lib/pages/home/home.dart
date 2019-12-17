import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_swiper/flutter_swiper.dart';
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int offset = 0;
  List newsList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNews();
  }

  getNews() async {
    HttpClient httpClient = HttpClient();
    Map<String , String> params = {
      "appChannelId" : "1000",
      "appVersion" : "5.6.5_1909240955",
      "deviceModel" : "x86_64",
      "deviceOsType" : "0",
      "offset" : offset.toString()
    };
    Uri newsUri = Uri.https('api.cgtn.com', '/app/api/news/home/list', params);
    var newsRequest = await httpClient.getUrl(newsUri);
    var newsResponse = await newsRequest.close();
    var result = await newsResponse.transform(utf8.decoder).join();
    Map<String, dynamic> resultJSON = jsonDecode(result);

    if(resultJSON["status"] != 200) {
      return;
    }

    newsList = resultJSON["data"];
    setState(() {
    });

  }

  @override
  Widget build(BuildContext context) {

    // return CustomScrollView(
    //     slivers: newsList?.map((el) {
    //       var section = el as Map<String, dynamic>;
    //       int styleType = int.parse(section["styleType"]);
    //       List contents = section["contents"] as List;
    //       switch (styleType) {
    //         case 2:
    //           return SliverToBoxAdapter(
    //             child: swiperNews(contents),
    //           );
    //           break;
    //         default:
    //           return SliverToBoxAdapter();
    //       }
    //     })?.toList() ?? List<Widget>(),
    // );
    // TODO: implement build
    return ListView.separated(
      itemCount: newsList?.length ?? 0,
      itemBuilder: (context, index) {
        var section = newsList[index] as Map<String, dynamic>;
        int styleType = int.parse(section["styleType"]);
        List contents = section["contents"] as List;
        switch (styleType) {
          case 2:
            return swiperNews(context, contents);
            break;
          default:
            return Container();
        }
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.white30,
        );
      },
    );
  }

  Widget swiperNews(BuildContext context, List contents) {
    return Container(
              child: Swiper(
                      autoplay: true,
                      loop: true,
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> item = contents[index] as Map<String, dynamic>;
                        Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
                        Map<String, dynamic> cover_16_9_JSON = coverJSON["r_16_9"] as Map<String, dynamic>;
                        Map<String, dynamic> cover_16_9_quality_max_JSON = cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
                        String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"];
                        return new Image.network(cover_16_9_quality_max_url,fit: BoxFit.fill,);
                      },
                      onTap: (index) {
                        print(index);
                      },
                    ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9.0 / 16.0,
            );
  }
}