import 'package:flutter/material.dart';
import 'package:pixelfree/pixelfree.dart';
import 'package:pixelfree/pixelfree_platform_interface.dart';

class PixeBeautyDialog extends StatefulWidget {
  final Pixelfree pixelFree;

  const PixeBeautyDialog({
    Key? key,
    required this.pixelFree,
  }) : super(key: key);

  @override
  State<PixeBeautyDialog> createState() => _PixeBeautyDialogState();
}

class _PixeBeautyDialogState extends State<PixeBeautyDialog> {
  int _currentPage = 0;
  late PageController _pageController;
  final List<BeautyPage> _pages = [
    BeautyPage(
      title: '一键美颜',
      items: [
        BeautyItem.oneKey(0, '原图', 'assets/icons/yuantu.png'),
        BeautyItem.oneKey(1, '自然', 'assets/icons/face_ziran.png'),
        BeautyItem.oneKey(2, '可爱', 'assets/icons/face_keai.png'),
        BeautyItem.oneKey(3, '女神', 'assets/icons/face_nvsheng.png'),
        BeautyItem.oneKey(4, '白净', 'assets/icons/face_baijin.png'),
      ],
    ),
    BeautyPage(
      title: '美肤',
      items: [
        BeautyItem.beauty(PFBeautyFiterType.faceWhitenStrength, 0.2, '美白', 'assets/icons/f_meibai1.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceRuddyStrength, 0.6, '红润', 'assets/icons/hongrun.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceBlurStrength, 0.7, '磨皮', 'assets/icons/mopi.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceEyeBrighten, 0.0, '亮眼', 'assets/icons/liangyan.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceSharpenStrength, 0.0, '锐化', 'assets/icons/ruihua.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceQualityStrength, 0.2, '增强画质', 'assets/icons/huazhizengqiang.png'),
      ],
    ),
    BeautyPage(
      title: '美形',
      items: [
        BeautyItem.beauty(PFBeautyFiterType.eyeStrength, 0.2, '大眼', 'assets/icons/dayan.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceThinning, 0.2, '瘦脸', 'assets/icons/shoulian.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceNarrow, 0.2, '瘦颧骨', 'assets/icons/zhailian.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceChin, 0.5, '下巴', 'assets/icons/xiaba.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceV, 0.2, '瘦下颔', 'assets/icons/vlian.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceSmall, 0.2, '小脸', 'assets/icons/xianlian.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceNose, 0.2, '鼻子', 'assets/icons/bizhi.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceForehead, 0.5, '额头', 'assets/icons/etou.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceMouth, 0.5, '嘴巴', 'assets/icons/zuiba.png'),
        BeautyItem.beauty(PFBeautyFiterType.facePhiltrum, 0.5, '人中', 'assets/icons/renzhong.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceLongNose, 0.5, '长鼻', 'assets/icons/changbi.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceEyeSpace, 0.5, '眼距', 'assets/icons/yanju.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceSmile, 0.0, '微笑嘴角', 'assets/icons/weixiaozuijiao.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceEyeRotate, 0.5, '旋转眼睛', 'assets/icons/yanjingjiaodu.png'),
        BeautyItem.beauty(PFBeautyFiterType.faceCanthus, 0.0, '开眼角', 'assets/icons/kaiyanjiao.png'),
      ],
    ),
    BeautyPage(
      title: '滤镜',
      items: [
        BeautyItem.filter('origin', 0.5, '原图', 'assets/icons/yuantu.png'),
        BeautyItem.filter('chulian', 0.8, '初恋', 'assets/icons/chulian.png'),
        BeautyItem.filter('chuxin', 0.8, '初心', 'assets/icons/chuxin.png'),
        BeautyItem.filter('fennen', 0.8, '粉嫩', 'assets/icons/f_fennen1.png'),
        BeautyItem.filter('lengku', 0.8, '冷酷', 'assets/icons/lengku.png'),
        BeautyItem.filter('meiwei', 0.8, '美味', 'assets/icons/meiwei.png'),
        BeautyItem.filter('naicha', 0.8, '奶茶', 'assets/icons/naicha.png'),
        BeautyItem.filter('pailide', 0.8, '派丽德', 'assets/icons/pailide.png'),
        BeautyItem.filter('qingxin', 0.8, '清新', 'assets/icons/qingxin.png'),
        BeautyItem.filter('rixi', 0.8, '日系', 'assets/icons/rixi.png'),
        BeautyItem.filter('riza', 0.8, '日杂', 'assets/icons/riza.png'),
        BeautyItem.filter('weimei', 0.8, '唯美', 'assets/icons/weimei.png'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages.map((page) => _buildPage(page)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _pages.asMap().entries.map((entry) {
          final index = entry.key;
          final page = entry.value;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _currentPage == index ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                page.title,
                style: TextStyle(
                  color: _currentPage == index ? Colors.blue : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPage(BeautyPage page) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: page.items.length,
      itemBuilder: (context, index) {
        return _buildBeautyItem(page.items[index]);
      },
    );
  }

  Widget _buildBeautyItem(BeautyItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              item.iconPath,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: ${item.iconPath}');
                print('Error: $error');
                return Icon(
                  Icons.image_not_supported,
                  color: Colors.white.withOpacity(0.5),
                  size: 30,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class BeautyPage {
  final String title;
  final List<BeautyItem> items;

  BeautyPage({
    required this.title,
    required this.items,
  });
}

enum BeautyType {
  oneKey,
  beauty,
  filter,
  sticker,
}

class BeautyItem {
  final BeautyType type;
  final dynamic value;
  final String title;
  final String iconPath;
  final PFBeautyFiterType? beautyType;
  final String? filterName;

  BeautyItem({
    required this.type,
    required this.value,
    required this.title,
    required this.iconPath,
    this.beautyType,
    this.filterName,
  });

  factory BeautyItem.oneKey(int value, String title, String iconPath) {
    return BeautyItem(
      type: BeautyType.oneKey,
      value: value,
      title: title,
      iconPath: iconPath,
    );
  }

  factory BeautyItem.beauty(PFBeautyFiterType beautyType, double value, String title, String iconPath) {
    return BeautyItem(
      type: BeautyType.beauty,
      value: value,
      title: title,
      iconPath: iconPath,
      beautyType: beautyType,
    );
  }

  factory BeautyItem.filter(String filterName, double value, String title, String iconPath) {
    return BeautyItem(
      type: BeautyType.filter,
      value: value,
      title: title,
      iconPath: iconPath,
      filterName: filterName,
    );
  }

  factory BeautyItem.sticker(String filterName, String title, String iconPath) {
    return BeautyItem(
      type: BeautyType.sticker,
      value: 1.0,
      title: title,
      iconPath: iconPath,
      filterName: filterName,
    );
  }
} 