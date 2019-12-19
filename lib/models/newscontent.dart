class CoverImg {
  String url;
  String width;
  String height;
  String size;
  String caption;
  String href;
}

class CoverImgRatio {
  CoverImg quality_max;
  CoverImg quality_med;
  CoverImg quality_min;
}

class NewsCover {
  CoverImgRatio r_0_0;
  CoverImgRatio r_16_9;
  CoverImgRatio r_1_1;
  CoverImgRatio r_16_6;
  CoverImgRatio r_32_13;
  CoverImgRatio r_67_18;
}

class NewsContent {
  String id;
  String appUrl;
  String longHeadline;
  String shortHeadline;
  int coverType;
  NewsCover cover;
  String coverImages;
}