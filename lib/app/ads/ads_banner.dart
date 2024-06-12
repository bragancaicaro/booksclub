import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Widget getBanner(context) {
  
 
  return Builder(
    builder: (context) {
      BannerAd? anchoredAdaptiveAd;
      BannerAdListener bannerAdListener = BannerAdListener(
        onAdWillDismissScreen: (ad) => ad.dispose(),
        onAdClosed: (ad) => debugPrint('Anúncio fechado'),
      );

      anchoredAdaptiveAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-5630239568507479/8011558551'
            : 'ca-app-pub-5630239568507479/3693039595',
        listener: bannerAdListener,
        request: const AdRequest(),
      );

      anchoredAdaptiveAd.load().then((_) {
        debugPrint('Anúncio carregado!');
      }).catchError((error) {
        debugPrint('Falha ao carregar anúncio: $error');
      });

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          color: Colors.grey.shade100,
          width: MediaQuery.of(context).size.width.truncate().toDouble(),
          height: 110,
          child: AdWidget(ad: anchoredAdaptiveAd),
        ),
      );
    },
  );
}
  