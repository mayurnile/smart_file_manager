import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_file_manager/presentation/screens/folder/folder.dart';
import 'package:multi_circular_slider/multi_circular_slider.dart';
import 'package:smart_file_manager/presentation/screens/memes_finder.dart';
import 'package:smart_file_manager/presentation/screens/near_duplicate_home.dart';

import '../../providers/core_provider.dart';
import '../../core/core.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _getUserPermissions() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage] == PermissionStatus.granted) {
      return;
    } else if (statuses[Permission.storage] == PermissionStatus.denied) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FutureBuilder(
          future: _getUserPermissions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => refresh(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //body
                  Positioned.fill(
                    child: _buildBody(screenSize, textTheme, context),
                  ),
                  //navBar
                  Positioned(
                    bottom: 12.0,
                    left: 12.0,
                    right: 12.0,
                    child: _buildNavBar(screenSize, textTheme, context),
                  ),
                ],
              ),
            );
          }),
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
  Widget _buildBody(
      Size screenSize, TextTheme textTheme, BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: GetBuilder<CoreProvider>(builder: (CoreProvider _coreProvider) {
        if (_coreProvider.loading) {
          return SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        String appSize = _coreProvider.formatBytes(
          _coreProvider.totalAppSize,
          2,
        );

        String imageSize = _coreProvider.formatBytes(
          _coreProvider.totalImageSize,
          2,
        );

        String videoSize = _coreProvider.formatBytes(
          _coreProvider.totalVideoSize,
          2,
        );

        String otherSize = _coreProvider.formatBytes(
          _coreProvider.usedSpace -
              _coreProvider.totalAppSize -
              _coreProvider.totalImageSize -
              _coreProvider.totalVideoSize,
          2,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //appbar
            _buildAppBar(textTheme),
            //storage details
            _buildStorageDetails(_coreProvider, screenSize, textTheme, context),
            //other details
            Transform.translate(
              offset: Offset(0.0, -screenSize.height * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //installed apps details
                  _buildSectionDetails(
                    'Apps',
                    'Uninstall rarely used apps',
                    '$appSize',
                    SmartFileManagerTheme.SECONDARY_COLOR_01,
                    screenSize,
                    textTheme,
                  ),
                  //images details
                  _buildSectionDetails(
                    'Images',
                    'Erase images you no longer need',
                    '$imageSize',
                    SmartFileManagerTheme.SECONDARY_COLOR_02,
                    screenSize,
                    textTheme,
                  ),
                  //videos details
                  _buildSectionDetails(
                    'Videos',
                    'Erase videos you no longer need',
                    '$videoSize',
                    SmartFileManagerTheme.SECONDARY_COLOR_03,
                    screenSize,
                    textTheme,
                  ),
                  //documents details
                  _buildSectionDetails(
                    'Documents & Others',
                    'Erase documents you no longer need',
                    '$otherSize',
                    SmartFileManagerTheme.SECONDARY_COLOR_04,
                    screenSize,
                    textTheme,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  ///[returns BottomNavigationBar for HomeScreen]
  Widget _buildNavBar(
    Size screenSize,
    TextTheme textTheme,
    BuildContext context,
  ) {
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
                context,
              ),
              //meme finder
              _buildNavBarButton(
                'Meme\nFinder',
                Assets.MEMES_FINDER,
                screenSize,
                textTheme,
                context,
              ),
              //share files
              _buildNavBarButton(
                'Share\nFiles',
                Assets.SHARE_FILES,
                screenSize,
                textTheme,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //body widget
  ///[returns storage details of available space and progress bar]
  Widget _buildStorageDetails(
    CoreProvider _coreController,
    Size screenSize,
    TextTheme textTheme,
    BuildContext context,
  ) {
    double appPercent = calculatePercent(
      _coreController.totalAppSize,
       _coreController.totalSpace,
    );
    double imagePercent = calculatePercent(
      _coreController.totalImageSize,
      _coreController.totalSpace,
    );
    double videoPercent = calculatePercent(
      _coreController.totalVideoSize,
      _coreController.totalSpace,
    );
    double otherPercent = calculatePercent(
      _coreController.usedSpace -
          _coreController.totalAppSize -
          _coreController.totalImageSize -
          _coreController.totalVideoSize,
      _coreController.totalSpace,
    );

    return InkWell(
      onTap: () {
        FileSystemEntity item = _coreController.availableStorage[0];
        Navigate.pushPage(
          context,
          Folder(title: 'Device', path: item.path.split("Android")[0]),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22.0),
        child: Center(
          child: MultiCircularSlider(
            size: screenSize.width * 0.6,
            values: [appPercent, imagePercent, videoPercent, otherPercent],
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
            innerIcon: SvgPicture.asset(
              Assets.STORAGE,
              height: 32.0,
            ),
            label:
                '${_coreController.formatBytes(_coreController.usedSpace, 2)} / ${_coreController.formatBytes(_coreController.totalSpace, 2)} Used',
          ),
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
                  topRight: Radius.circular(52.0),
                  bottomRight: Radius.circular(52.0),
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
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Duplicate\nImage':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NearDuplicateFinder(),
              ),
            );
            break;
          case 'Meme\nFinder':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MemeFinder(),
              ),
            );
            break;
          case 'Share\nFiles':
            break;
          default:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NearDuplicateFinder(),
              ),
            );
        }
      },
      child: SizedBox(
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
      ),
    );
  }

  refresh() async {
    final CoreProvider _coreController = Get.find();
    await _coreController.checkSpace();
  }

  calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(0)) /
        100;
  }
}
