import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_circular_slider/multi_circular_slider.dart';

import '../../core/core.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          //body
          Positioned.fill(
            child: _buildBody(screenSize, textTheme),
          ),
          //navBar
          Positioned(
            bottom: 12.0,
            left: 12.0,
            right: 12.0,
            child: _buildNavBar(screenSize, textTheme),
          ),
        ],
      ),
    );
  }

  ///[returns AppBar for HomeScreen]
  Widget _buildAppBar(TextTheme textTheme) {
    return AppBar(
      key: ValueKey('app_bar'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Smart File Manager',
        style: textTheme.headline1,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: SmartFileManagerTheme.FONT_DARK_COLOR,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  ///[returns Body for HomeScreen]
  Widget _buildBody(Size screenSize, TextTheme textTheme) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //appbar
          _buildAppBar(textTheme),
          //storage details
          _buildStorageDetails(screenSize, textTheme),
          Transform.translate(
            offset: Offset(0.0, -screenSize.height * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //installed apps details
                _buildSectionDetails(
                  'Apps',
                  'Uninstall rarely used apps',
                  '23.04 GB',
                  SmartFileManagerTheme.SECONDARY_COLOR_01,
                  screenSize,
                  textTheme,
                ),
                //images details
                _buildSectionDetails(
                  'Images',
                  'Erase images you no longer need',
                  '23.04 GB',
                  SmartFileManagerTheme.SECONDARY_COLOR_02,
                  screenSize,
                  textTheme,
                ),
                //videos details
                _buildSectionDetails(
                  'Videos',
                  'Erase videos you no longer need',
                  '6.24 GB',
                  SmartFileManagerTheme.SECONDARY_COLOR_03,
                  screenSize,
                  textTheme,
                ),
                //documents details
                _buildSectionDetails(
                  'Documents & Others',
                  'Erase documents you no longer need',
                  '1.37 GB',
                  SmartFileManagerTheme.SECONDARY_COLOR_04,
                  screenSize,
                  textTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///[returns BottomNavigationBar for HomeScreen]
  Widget _buildNavBar(Size screenSize, TextTheme textTheme) {
    return Container(
      width: screenSize.width,
      height: screenSize.height * 0.15,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //indicator
          Container(
            width: screenSize.width * 0.1,
            height: 6.0,
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: SmartFileManagerTheme.FONT_LIGHT_COLOR,
            ),
          ),
          //nav bar items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //duplicate images finder
              _buildNavBarButton(
                'Duplicate\nImages',
                Assets.DUPLICATE_IMAGES,
                screenSize,
                textTheme,
              ),
              //meme finder
              _buildNavBarButton(
                'Meme\nFinder',
                Assets.MEMES_FINDER,
                screenSize,
                textTheme,
              ),
              //share files
              _buildNavBarButton(
                'Share\nFiles',
                Assets.SHARE_FILES,
                screenSize,
                textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //body widget
  ///[returns storage details of available space and progress bar]
  Widget _buildStorageDetails(Size screenSize, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22.0),
      child: Center(
        child: MultiCircularSlider(
          size: screenSize.width * 0.6,
          values: [0.2, 0.1, 0.3, 0.25],
          colors: [
            SmartFileManagerTheme.SECONDARY_COLOR_01,
            SmartFileManagerTheme.SECONDARY_COLOR_02,
            SmartFileManagerTheme.SECONDARY_COLOR_03,
            SmartFileManagerTheme.SECONDARY_COLOR_04,
          ],
          showTotalPercentage: true,
          trackColor: SmartFileManagerTheme.FONT_LIGHT_COLOR,
          progressBarWidth: 8.0,
          trackWidth: 8.0,
        ),
      ),
    );
  }

  //body widget
  ///[returns widget showing total space used by a section]
  Widget _buildSectionDetails(
    String title,
    String subtitle,
    String data,
    Color sectionColor,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title row
        Row(
          children: [
            //marker
            Container(
              height: screenSize.height * 0.03,
              width: screenSize.width * 0.05,
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
            ),
            //spacing
            SizedBox(width: 22.0),
            //title
            Text(title, style: textTheme.headline3),
            //spacing
            Spacer(),
            //space used
            Text(
              data,
              style: textTheme.headline3.copyWith(color: sectionColor),
            ),
            //spacing
            SizedBox(width: 22.0),
          ],
        ),
        //subtitle
        Padding(
          padding: EdgeInsets.only(top: 2.0, left: screenSize.width * 0.105),
          child: Text(
            subtitle,
            style: textTheme.headline6,
          ),
        ),
        //list of items
        ///[TODO: SHOW LIST OF ITEMS HERE]
        //divider
        Divider(
          color: SmartFileManagerTheme.FONT_LIGHT_COLOR,
          indent: screenSize.width * 0.15,
        ),
        //spacing
        SizedBox(
          height: screenSize.height * 0.03,
        ),
      ],
    );
  }

  //navbar widget
  ///[returns nav bar button]
  Widget _buildNavBarButton(
    String title,
    String icon,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: screenSize.width / 3 - 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //icon
          SvgPicture.asset(icon),
          //spacing
          SizedBox(height: 12.0),
          //title
          FittedBox(
            child: Text(
              title,
              style: textTheme.headline3.copyWith(height: 1.0),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
