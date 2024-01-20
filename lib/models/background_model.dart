class BackgroundModel {
  bool? isCustomBackground;
  int? defaultBackgroundIndex;
  double? blur;
  String? customBackgroundPath;

  BackgroundModel(
      {this.isCustomBackground,
      this.defaultBackgroundIndex,
      this.blur,
      this.customBackgroundPath});

  BackgroundModel.fromJson(Map<String, dynamic> json) {
    isCustomBackground = json['isCustomBackground'];
    defaultBackgroundIndex = json['defaultBackgroundIndex'];
    blur = json['blur'];
    customBackgroundPath = json['customBackgroundPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isCustomBackground'] = isCustomBackground;
    data['defaultBackgroundIndex'] = defaultBackgroundIndex;
    data['blur'] = blur;
    data['customBackgroundPath'] = customBackgroundPath;
    return data;
  }
}
