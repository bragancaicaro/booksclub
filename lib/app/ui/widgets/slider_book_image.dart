import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../repositories/images.dart';

class SliderImageBook extends StatefulWidget {
  
  ImagesManager imagesManager;
  int initialIndex;
  SliderImageBook({super.key, required this.imagesManager, required this.initialIndex});
  @override
  _SliderImageBook createState() => _SliderImageBook();
}
class _SliderImageBook extends State<SliderImageBook> {
  
  late PageController _pageController;
  int currentPage = 0; // Initialize currentPage for background image
  final BannerAd banner = BannerAd(
    size: AdSize.banner, 
    adUnitId: 'ca-app-pub-3940256099942544/6300978111', 
    request: const AdRequest(),
    listener: const BannerAdListener(), 
    );
  
  @override
  void initState(){
    super.initState();
    banner.load();
    currentPage = widget.initialIndex;
    _pageController = PageController(
      viewportFraction: 0.90,
      initialPage: widget.initialIndex,
    );
    print(widget.imagesManager.items[currentPage].imageUrl);
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 80),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      widget.imagesManager.items[currentPage].imageUrl
                    
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.45),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter, colors: [Colors.black38.withOpacity(0.25), Colors.black54.withOpacity(0.3)],
               
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.75,
                child: PageView.builder(
                  controller: _pageController,
                 
                  onPageChanged: (value) => {
                    setState(
                      () {
                        currentPage = value;
                      },
                    )
                  },
                  itemCount: widget.imagesManager.items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: index == currentPage ? 15 : 35,
                            top: index == currentPage ? 15 : 35),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(23),
                          color: index == currentPage
                              ? Colors.white
                              : Colors.grey.shade300,
                          image: DecorationImage(
                            image: NetworkImage(widget.imagesManager.items[index].imageUrl),
                            fit: BoxFit.cover
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
              top: 0.0,
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ),
            const SizedBox(height: 15,),
              getBanner(context)
            ],
          )
        ],
      ),
    );
  }
}
