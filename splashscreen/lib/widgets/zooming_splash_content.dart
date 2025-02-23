import 'package:flutter/material.dart';

class ZoomingSplashContent extends StatefulWidget {
  const ZoomingSplashContent({super.key});

  @override
  State<ZoomingSplashContent> createState() => _ZoomingSplashContentState();
}

class _ZoomingSplashContentState extends State<ZoomingSplashContent>
    with TickerProviderStateMixin {
  late AnimationController _controllerCombine;
  late AnimationController _controllerBounce;
  late AnimationController _controllerZoom;
  late AnimationController _controllerText;
  late AnimationController _controllerFade;
  late AnimationController _controllerFadeTop;

  late Animation<double> _fadeTopImageAnimation;
  late Animation<Offset> _slideTopAnimation;
  late Animation<Offset> _slideLeftAnimation;
  late Animation<Offset> _slideRightAnimation;
  late Animation<double> _zoomLeftAnimation;
  late Animation<double> _zoomRightAnimation;
  late Animation<double> _fadeImagesAnimation;
  late Animation<double> _fadeTextAnimation;
  //late Animation<Offset> _bounceLeftAnimation;
  //late Animation<Offset> _bounceRightAnimation;
  late Animation<Offset> _bounceTopAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _controllerCombine = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controllerFadeTop = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _controllerBounce = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controllerZoom = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )
      ..addListener(() {
        if (_controllerCombine.isCompleted) {
          // Stop at the end value
          _controllerCombine.stop();
        }
      });

    _controllerFade = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _controllerText = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeTopImageAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controllerFadeTop,
      curve: Curves.easeOut,
    ));

    _slideTopAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: const Offset(0.0, -0.02),
    ).animate(CurvedAnimation(
      parent: _controllerCombine,
      curve: Curves.easeOut,
    ));

    _slideLeftAnimation = Tween<Offset>(
        begin: const Offset(-2.0, 0.0),
        end: const Offset(-0.075, 0.0)
    ).animate(CurvedAnimation(
      parent: _controllerCombine,
      curve: Curves.easeOut,
    ));

    _slideRightAnimation = Tween<Offset>(
        begin: const Offset(2.0, 0.0),
        end: const Offset(0.076, 0.0)
    ).animate(CurvedAnimation(
      parent: _controllerCombine,
      curve: Curves.easeOut,
    ));

    _bounceTopAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.04),
      end: const Offset(0.0, -0.049),
    ).animate(CurvedAnimation(
      parent: _controllerBounce,
      curve: Curves.easeOut,
    ));
/*    _bounceLeftAnimation = Tween<Offset>(
        begin: const Offset(-0.048, 0.0),
        end: const Offset(-0.07, 0.0)
    ).animate(CurvedAnimation(
      parent: _controllerBounce,
      curve: Curves.easeInOut,
    ));

    _bounceRightAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0.0),
        end: const Offset(0.07, 0.0)
    ).animate(CurvedAnimation(
      parent: _controllerBounce,
      curve: Curves.easeInOut,
    ));
*/
    _zoomLeftAnimation = Tween<double>(
      begin: 1.0,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _controllerZoom,
      curve: Curves.easeInOut,
    ));

    _zoomRightAnimation = Tween<double>(
      begin: 1.0,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _controllerZoom,
      curve: Curves.easeInOut,
    ));

    _fadeImagesAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controllerFade,
      curve: Curves.easeOut,
    ));

    _fadeTextAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controllerText,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimationSequence() async {
    await _controllerCombine.forward();
    await Future.delayed(const Duration(milliseconds: 1000));

    _controllerBounce.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    _controllerFadeTop.forward();

    // Start zoom and fade simultaneously
    _controllerZoom.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    await _controllerFade.forward();

    // Show text after images have disappeared
    await _controllerText.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controllerCombine.dispose();
    _controllerBounce.dispose();
    _controllerZoom.dispose();
    _controllerFade.dispose();
    _controllerText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeImagesAnimation,
          child: Stack(
            children: [
            // Top image
            SlideTransition(
            position: _slideTopAnimation,
              child: SlideTransition(
              position: _bounceTopAnimation,
                child: FadeTransition(
                  opacity: _fadeTopImageAnimation,
                child: Center(
                  child: Image.asset(
                    'assets/images/top_part.png',
                    width: 500,
                    height: 500,
                  ),
                ),
              ),
            ),
            ),

              // Left image
              SlideTransition(
                position: _slideLeftAnimation,
                child: ScaleTransition(
                  scale: _zoomLeftAnimation,
                  alignment: Alignment(0.2, 0.0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/left_part.png',
                      width: 200,
                      height: 400,
                    ),
                  ),
                ),
              ),

              // Right image
              SlideTransition(
                position: _slideRightAnimation,
                child: ScaleTransition(
                  scale: _zoomRightAnimation,
                  alignment: Alignment(-0.2, 0.0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/right_part.png',
                      width: 200,
                      height: 400,
                    ),
                  ),
                ),
              ),



            ],
    ),
    ),

    // Welcome text
    Center(
      child: FadeTransition(
        opacity: _fadeTextAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/text.png',
                width: 295,
                height: 88,
            ),
          ],
        ),
      ),
    ),
    ],
    );
  }
}

