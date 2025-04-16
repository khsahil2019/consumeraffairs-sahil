/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/bottom_img.png
  AssetGenImage get bottomImg =>
      const AssetGenImage('assets/images/bottom_img.png');

  /// File path: assets/images/city_bazar_logo.png
  AssetGenImage get cityBazarLogo =>
      const AssetGenImage('assets/images/city_bazar_logo.png');

  /// File path: assets/images/consumer affairs logo png.png
  AssetGenImage get consumerAffairsLogoPng =>
      const AssetGenImage('assets/images/consumer affairs logo png.png');

  /// File path: assets/images/profile_pic.png
  AssetGenImage get profilePic =>
      const AssetGenImage('assets/images/profile_pic.png');

  /// File path: assets/images/super_market_logo.png
  AssetGenImage get superMarketLogo =>
      const AssetGenImage('assets/images/super_market_logo.png');

  /// File path: assets/images/top_img.png
  AssetGenImage get topImg => const AssetGenImage('assets/images/top_img.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        bottomImg,
        cityBazarLogo,
        consumerAffairsLogoPng,
        profilePic,
        superMarketLogo,
        topImg
      ];
}

class $AssetsSvgsGen {
  const $AssetsSvgsGen();

  /// File path: assets/svgs/alert-circle.svg
  String get alertCircle => 'assets/svgs/alert-circle.svg';

  /// File path: assets/svgs/arrow-up-right.svg
  String get arrowUpRight => 'assets/svgs/arrow-up-right.svg';

  /// File path: assets/svgs/bell.svg
  String get bell => 'assets/svgs/bell.svg';

  /// File path: assets/svgs/dashboard.svg
  String get dashboard => 'assets/svgs/dashboard.svg';

  /// File path: assets/svgs/profile_pic.svg
  String get profilePic => 'assets/svgs/profile_pic.svg';

  /// File path: assets/svgs/survey.svg
  String get survey => 'assets/svgs/survey.svg';

  /// File path: assets/svgs/user.svg
  String get user => 'assets/svgs/user.svg';

  /// List of all assets
  List<String> get values =>
      [alertCircle, arrowUpRight, bell, dashboard, profilePic, survey, user];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSvgsGen svgs = $AssetsSvgsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
