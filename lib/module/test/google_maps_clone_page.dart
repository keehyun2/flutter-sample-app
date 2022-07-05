import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_app/module/map/map_controller.dart';

class GoogleMapsClonePage extends StatefulWidget {
  const GoogleMapsClonePage({Key? key}) : super(key: key);

  @override
  State<GoogleMapsClonePage> createState() => _GoogleMapsClonePageState();
}

class _GoogleMapsClonePageState extends State<GoogleMapsClonePage> {
  MapController mapController = MapController.to;

  var opacity = 1.0;

  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  late ScrollController _scrollController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: <Widget>[
          // CustomGoogleMap(),
          Opacity(
            opacity: opacity,
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.42796133580664, -122.085749655962),
                zoom: 14.4746,
              ),
            ),
          ),
          // const CustomBottomSheet(min: 0, max:0.7),
          _bottomSheet(context),
          CustomSearchContainer(),
        ],
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double top = MediaQuery.of(context).padding.top;
    // print('h $h, top $top');

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification dsNotification) {
        /// DraggableScrollableSheet scroll event 처리
        setState(() {
          double ll = (dsNotification.extent >= 0.7)
              ? min((dsNotification.extent - 0.7) * 10.0, 1.0)
              : 0.0;
          opacity = 1.0 - ll;
          mapController.spreadFlag.value = (opacity == 0);
          // print('${dsNotification.extent}, ${mapController.spreadFlag.value}');
        });
        return true;
      },
      child: DraggableScrollableSheet(
        controller: _draggableScrollableController,

        // snap: true, // 시뮬레이터에서 이상하게 작동함. 기기에서 테스트해봐야함.
        // snapSizes: const [0.5, 0.8],
        maxChildSize: 1 - (98 / (h-56)), // 바텀 네비 높이 차감
        initialChildSize: 0.1,
        minChildSize: 0.0,
        // expand: false,
        builder: (context, scrollController) {
          _scrollController = scrollController;
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Scrollbar(
              trackVisibility: false,
              // isAlwaysShown: true,
              controller: _scrollController,
              // hoverThickness: 10.0,
              // thickness: 20.0,
              child: Container(
                // color: Colors.white,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, //New
                        blurRadius: 3.0,
                        offset: Offset(0, 1))
                  ],
                ),
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap:true,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        height: 5,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomExploreBerlin(),
                    const SizedBox(height: 16),
                    CustomHorizontallyScrollingRestaurants(),
                    const SizedBox(height: 24),
                    CustomFeaturedListsText(),
                    const SizedBox(height: 16),
                    CustomFeaturedItemsGrid(),
                    const SizedBox(height: 24),
                    CustomRecentPhotosText(),
                    const SizedBox(height: 16),
                    CustomRecentPhotoLarge(),
                    const SizedBox(height: 12),
                    CustomRecentPhotosSmall(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 하단 네비게이션 바
  Widget _buildBottomNavigationBar(context) {
    return BottomNavigationBar(

      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(.60),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      currentIndex: _selectedIndex,
      //현재 선택된 Index
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
        // if(_draggableScrollableController.size > 0.3){
        //   _draggableScrollableController.jumpTo(0.5);

        _scrollController.jumpTo(0);
        _draggableScrollableController.jumpTo(0.1);
      },
      items: const [
        BottomNavigationBarItem(
          label: 'Favorites',
          icon: Icon(Icons.favorite),
        ),
        BottomNavigationBarItem(
          label: 'Favorites',
          icon: Icon(Icons.favorite),
        ),
        BottomNavigationBarItem(
          label: 'Favorites',
          icon: Icon(Icons.favorite),
        ),
      ],
    );
  }
}

class CustomSearchContainer extends StatelessWidget {
  MapController mapController = MapController.to;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      decoration: mapController.spreadFlag.value
      // decoration: false
          ? const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, //New
                    blurRadius: 3.0,
                    offset: Offset(0, 2))
              ],
            )
          : null,
      child: Container(
        // margin: const EdgeInsets.fromLTRB(16, 40, 16, 8),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          // border: BoxBorder().,
          boxShadow: const [
            BoxShadow(
                color: Colors.grey, //New
                blurRadius: 3.0,
                offset: Offset(0, 1))
          ],
        ),
        child: Row(
          children: <Widget>[
            CustomTextField(),
            const Icon(Icons.mic),
            const SizedBox(width: 16),
            CustomUserAvatar(),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        maxLines: 1,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          hintText: 'Search here',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class CustomUserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
          color: Colors.grey[500], borderRadius: BorderRadius.circular(16)),
    );
  }
}

class CustomCategoryChip extends StatelessWidget {
  final IconData iconData;
  final String title;

  CustomCategoryChip(this.iconData, this.title);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        children: <Widget>[
          Icon(iconData, size: 16),
          const SizedBox(width: 8),
          Text(title)
        ],
      ),
      backgroundColor: Colors.grey[50],
    );
  }
}

class CustomExploreBerlin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Explore Berlin',
            style: TextStyle(fontSize: 22, color: Colors.black45)),
        const SizedBox(width: 8),
        Container(
          height: 24,
          width: 24,
          child: const Icon(Icons.arrow_forward_ios,
              size: 12, color: Colors.black54),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        ),
      ],
    );
  }
}

class CustomHorizontallyScrollingRestaurants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomRestaurantCategory(),
            const SizedBox(width: 12),
            CustomRestaurantCategory(),
            const SizedBox(width: 12),
            CustomRestaurantCategory(),
            const SizedBox(width: 12),
            CustomRestaurantCategory(),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class CustomFeaturedListsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      //only to left align the text
      child: Row(
        children: const <Widget>[
          Text('Featured Lists', style: TextStyle(fontSize: 14))
        ],
      ),
    );
  }
}

class CustomFeaturedItemsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        //to avoid scrolling conflict with the dragging sheet
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        children: <Widget>[
          CustomFeaturedItem(),
          CustomFeaturedItem(),
          CustomFeaturedItem(),
          CustomFeaturedItem(),
        ],
      ),
    );
  }
}

class CustomRecentPhotosText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: const <Widget>[
          Text('Recent Photos', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class CustomRecentPhotoLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomFeaturedItem(),
    );
  }
}

class CustomRecentPhotosSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomFeaturedItemsGrid();
  }
}

class CustomRestaurantCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class CustomFeaturedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
