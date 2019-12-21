import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cgtn/pages/detail/newsdetail.dart';
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
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if(_scrollController.offset > _scrollController.position.maxScrollExtent + 10.0) {
        // 刷新
        getNews();
      }
    });
    getNews();
  }

  void getNews() async {
    if (isLoading) return;
    isLoading = true;
    HttpClient httpClient = HttpClient();
    Map<String, String> params = {
      "appChannelId": "1000",
      "appVersion": "5.6.5_1909240955",
      "deviceModel": "x86_64",
      "deviceOsType": "0",
      "offset": offset.toString()
    };
    Uri newsUri = Uri.https('api.cgtn.com', '/app/api/news/home/list', params);
    var newsRequest = await httpClient.getUrl(newsUri);
    var newsResponse = await newsRequest.close();
    var result = await newsResponse.transform(utf8.decoder).join();
    Map<String, dynamic> resultJSON = jsonDecode(result);

    if (resultJSON["status"] != 200) {
      return;
    }
    if (offset == 0) {
      newsList = List();
    }
    newsList.addAll(resultJSON["data"]);
    print(offset);
    offset ++;
    isLoading = false;
    setState(() {

    });
  }

  Future<Void> _refresh() async {
    offset = 0;
    getNews();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator (
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: newsList?.length ?? 0,
            itemBuilder: (context, index) {
              var section = newsList[index] as Map<String, dynamic>;
              int styleType = int.parse(section["styleType"]);
              List contents = section["contents"] as List;
              switch (styleType) {
                case 1:
                  Map<String, dynamic> item = contents.first;
                  return bigPictureCell(item);
                  break;
                case 2:
                  return swiperNews(context, contents);
                  break;
                case 4:
                  Map<String, dynamic> item = contents.first;
                  return GestureDetector(
                    child: bannerCell(context, item),
                    onTap: () {

                    },
                  );
                  break;
                case 5:
                  Map<String, dynamic> item = contents.first;
                  return GestureDetector(
                    child: normalCell(context, item),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewsDetail(content: item)));
                    },
                  );
                  break;
                case 8:
                  return videosAndPicturesCell(contents, "Videos");
                  break;
                case 9:
                  return videosAndPicturesCell(contents, "Pictures");
                  break;
                case 13:
                  Map<String, dynamic> item = contents.first;
                  return spicialBannerCell(item);
                  break;
                default:
                  return Container(
                    color: Colors.red,
                    height: 10,
                  );
              }
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black38,
              );
            },
        ),
    );
  }
  // 轮播图
  Widget swiperNews(BuildContext context, List contents) {
    return Container(
      child: Swiper(
        autoplay: true,
        loop: true,
        itemCount: contents.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = contents[index] as Map<String, dynamic>;
          return swiperItem(item);
        },
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey
          ),
          alignment: Alignment.bottomRight
        ),
        onTap: (index) {
          print(index);
          // MaterialPageRoute(builder: (BuildContext context) => MyPage())
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewsDetail(content: contents[index])));
        },
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9.0 / 16.0 + 130.0,
    );
  }
  // 轮播图item
  Widget swiperItem(Map<String, dynamic> item) {
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_JSON =
        coverJSON["r_16_9"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_quality_max_JSON =
        cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
    String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      margin: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: 'lib/images/placeholderimg.png',
                image: cover_16_9_quality_max_url,
              ),
              Offstage(
                offstage: isPicture,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 6.0),//阴影在X轴和Y轴上的偏移
                        color: Colors.grey,//阴影颜色
                        blurRadius: 25.0 ,//阴影程度
                        spreadRadius: -9.0, //阴影扩散的程度 取值可以正数,也可以是负数
                      )
                    ]
                  ),
                  child: Icon(Icons.play_circle_outline, 
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              newsTitle,
              maxLines: 2,
              style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: publishDate(dateTimeStr, property),
          )
        ],
      ),
    );
  }

  Widget videosAndPicturesCell (List<dynamic> items, String title) {
    Map<String, dynamic> item = items.first ?? Map<String, dynamic>();
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_JSON =
        coverJSON["r_16_9"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_quality_max_JSON = cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
    String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"] ?? "";
    return GestureDetector(
      child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: <Widget>[
                FadeInImage.assetNetwork(
                  placeholder: "lib/images/placeholderimg.png",
                  image: cover_16_9_quality_max_url,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Trendings ${title} >> ",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              fontSize: 20
                            ),
                          ),
                )
              ],
            ),
      onTap: () {
        // Trendings
      },
    );
  }

  Widget spicialBannerCell(Map<String, dynamic> item) {
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_0_0_JSON =
        coverJSON["r_0_0"] as Map<String, dynamic>;
    Map<String, dynamic> cover_0_0_quality_max_JSON =
        cover_0_0_JSON["quality_max"] as Map<String, dynamic>;
    String cover_0_0_quality_max_url = cover_0_0_quality_max_JSON["url"];
    return FadeInImage.assetNetwork(
            placeholder: 'lib/images/bannerplaceholder.png',
            image: cover_0_0_quality_max_url,
          );
}

  Widget normalCell(BuildContext context, Map<String, dynamic> item) {
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_JSON =
        coverJSON["r_16_9"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_quality_max_JSON =
        cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
    String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"];
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: 'lib/images/placeholderimg.png',
                image: cover_16_9_quality_max_url,
              ),
              Offstage(
                offstage: isPicture,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 6.0),//阴影在X轴和Y轴上的偏移
                        color: Colors.grey,//阴影颜色
                        blurRadius: 25.0 ,//阴影程度
                        spreadRadius: -9.0, //阴影扩散的程度 取值可以正数,也可以是负数
                      )
                    ]
                  ),
                  child: Icon(Icons.play_circle_outline, 
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    newsTitle,
                    maxLines: 3,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0 * MediaQuery.of(context).textScaleFactor,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: publishDate(dateTimeStr, property),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget publishDate(String dateTimeStr, String property) {
      return RichText(
              text: TextSpan(
                text: dateTimeStr + ".",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: property,
                    style: TextStyle(
                      color: Color.fromRGBO(191, 174, 98, 1),
                      fontSize: 15.0,
                      decoration: TextDecoration.none
                    )
                  )
                ].toList()
              ),
            );
  }

  Widget bigPictureCell(Map<String, dynamic> item) {
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_JSON =
        coverJSON["r_16_9"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_quality_max_JSON =
        cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
    String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FadeInImage.assetNetwork(
            placeholder: "lib/images/placeholderimg.png",
            image: cover_16_9_quality_max_url,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(newsTitle,
              style: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
                fontSize: 20
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: publishDate(dateTimeStr, property),
          )
        ],
      ),
    );
  }

  Widget bannerCell(BuildContext context, Map<String, dynamic> item) {
    bool isPicture = (item["coverType"] ?? 0) == 1;
    String newsTitle = item["shortHeadline"] ?? item["longHeadline"] ?? "";
    String timeStr = item["updateTime"] ?? item["publishTime"] ?? "";
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timeStr) ?? 0);
    String dateTimeStr = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String property = item["property"] ?? "";
    Map<String, dynamic> coverJSON = item["cover"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_JSON =
        coverJSON["r_32_13"] as Map<String, dynamic>;
    Map<String, dynamic> cover_16_9_quality_max_JSON =
        cover_16_9_JSON["quality_max"] as Map<String, dynamic>;
    String cover_16_9_quality_max_url = cover_16_9_quality_max_JSON["url"];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: FadeInImage.assetNetwork(
                    placeholder: 'lib/images/bannerplaceholder.png',
                    image: cover_16_9_quality_max_url,
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
            child: Text(
              newsTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0 * MediaQuery.of(context).textScaleFactor,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none
              ),
            ),
          )
        ],
      ),
    );
  }
}
