import 'package:PiliPlus/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:PiliPlus/common/widgets/pendant_avatar.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/dynamics/up.dart';
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/pages/dynamics/controller.dart';
import 'package:PiliPlus/pages/dynamics/widgets/up_panel.dart';
import 'package:PiliPlus/pages/dynamics_tab/view.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' hide DraggableScrollableSheet;

class DynamicsPage extends StatefulWidget {
  const DynamicsPage({super.key});

  @override
  State<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends CommonPageState<DynamicsPage>
    with AutomaticKeepAliveClientMixin {
  final _dynamicsController = Get.putOrFind(DynamicsController.new);
  UpPanelPosition get upPanelPosition => _dynamicsController.upPanelPosition;
  late final MainController _mainController = Get.find<MainController>();

  bool _hideAppBar = false;

  @override
  bool get wantKeepAlive => true;

  Widget _createAvatarBtn({bool isRight = true}) =>
      Container(
        width: 34,
        height: 34,
        margin: isRight ? const .only(right: 16) : const .only(left: 16),
        child: InkWell(
          onTap: () {
            final idx = _mainController.navigationBars.indexOf(NavigationBarType.mine);
            if (idx != -1) {
              _mainController.selectedIndex.value = idx;
              // ⚠️ 注意：如果你在 main/view.dart 里找到了切换页面的代码，请填在这里：
              // 比如：_mainController.changePage(idx); 或者类似的方法
            }
          },
          customBorder: const CircleBorder(),
          child: PendantAvatar(
            Pref.userInfoCache?.face ?? 'https://i0.hdslb.com/bfs/face/member/noface.jpg',
            size: 34,
          ),
        ),
      );

  Widget upPanelPart(ColorScheme colorScheme) {
    final isTop = upPanelPosition == .top;
    final needBg = upPanelPosition.index > 2;
    return Material(
      type: needBg ? .canvas : .transparency,
      color: needBg ? colorScheme.surface : null,
      child: SizedBox(
        width: isTop ? null : 64,
        height: isTop ? 76 : null,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 300) {
              _dynamicsController.onLoadMore();
            }
            return false;
          },
          child: Obx(
            () => _buildUpPanel(_dynamicsController.loadingState.value),
          ),
        ),
      ),
    );
  }

  Widget _buildUpPanel(LoadingState<FollowUpModel> upState) {
    return switch (upState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) => UpPanel(
        upData: response,
        dynamicsController: _dynamicsController,
      ),
      Error() => Center(
        child: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _dynamicsController.onReload,
        ),
      ),
    };
  }

  bool get checkPage =>
      _mainController.navigationBars[0] != .dynamics &&
      _mainController.selectedIndex.value == 0;

  @override
  bool onNotificationType1(UserScrollNotification notification) {
    if (checkPage) return false;
    return super.onNotificationType1(notification);
  }

  @override
  bool onNotificationType2(ScrollNotification notification) {
    if (checkPage) return false;
    return super.onNotificationType2(notification);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = ColorScheme.of(context);

    Widget? drawer;
    Widget? endDrawer;

    Widget? leading;
    Widget actions;

    final tabTypes = Pref.dynamicsTabs;

    Widget child = tabBarView(
      controller: _dynamicsController.tabController,
      children: tabTypes
          .map((e) => DynamicsTabPage(dynamicsType: e))
          .toList(),
    );

    switch (upPanelPosition) {
      case .top:
        child = Column(
          children: [upPanelPart(colorScheme), Expanded(child: child)],
        );
        actions = _createAvatarBtn();
      case .leftFixed:
        child = Row(
          children: [upPanelPart(colorScheme), Expanded(child: child)],
        );
        actions = _createAvatarBtn();
      case .rightFixed:
        child = Row(
          children: [Expanded(child: child), upPanelPart(colorScheme)],
        );
        actions = _createAvatarBtn();
      case .leftDrawer:
        drawer = upPanelPart(colorScheme);
        actions = _createAvatarBtn();
        leading = const DrawerButton();
      case .rightDrawer:
        endDrawer = upPanelPart(colorScheme);
        leading = _createAvatarBtn(isRight: false);
        actions = const EndDrawerButton();
    }

    return Scaffold(
      primary: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      drawer: drawer,
      endDrawer: endDrawer,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_hideAppBar ? 0 : 50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: _hideAppBar ? 0 : 50,
          child: ClipRect(
            child: OverflowBox(
              minHeight: 50,
              maxHeight: 50,
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  ?leading,
                  Expanded(
                    child: TabBar(
                      dividerHeight: 0,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center, // 居中排列标签
                      dividerColor: Colors.transparent,
                      labelColor: colorScheme.primary,
                      indicatorColor: colorScheme.primary,
                      controller: _dynamicsController.tabController,
                      unselectedLabelColor: colorScheme.onSurface,
                      labelStyle:
                          TabBarTheme.of(context).labelStyle
                              ?.copyWith(fontSize: 13) ??
                          const TextStyle(fontSize: 13),
                      tabs: tabTypes.map((e) => Tab(text: e.label)).toList(),
                      onTap: (index) {
                        if (!_dynamicsController.tabController.indexIsChanging) {
                          _dynamicsController.animateToTop();
                        }
                      },
                    ),
                  ),
                  actions,
                ],
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (checkPage) return false;
          if (notification is ScrollUpdateNotification) {
            final delta = notification.scrollDelta ?? 0;
            // 向下滑动（看新内容），隐藏顶栏
            if (delta > 0 && !_hideAppBar && notification.metrics.pixels > 0) {
              setState(() => _hideAppBar = true);
            } 
            // 向上滑动（看历史），显示顶栏
            else if (delta < 0 && _hideAppBar) {
              setState(() => _hideAppBar = false);
            }
          }
          return false;
        },
        child: onBuild(child),
      ),
    );
  }
}
