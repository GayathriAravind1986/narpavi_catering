import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramanas_waiter/Alertbox/snackBarAlert.dart';
import 'package:ramanas_waiter/Bloc/Category/category_bloc.dart';
import 'package:ramanas_waiter/ModelClass/Order/Get_view_order_model.dart';
import 'package:ramanas_waiter/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:ramanas_waiter/Reusable/color.dart';
import 'package:ramanas_waiter/UI/Authentication/login_screen.dart';
import 'package:ramanas_waiter/UI/Landing/Home/home_screen.dart';
import 'package:ramanas_waiter/UI/Landing/Order/order_screen.dart';
import 'package:ramanas_waiter/UI/Landing/Products/product_Category.dart';
import 'package:ramanas_waiter/UI/Landing/Report/report_order.dart';
import 'package:ramanas_waiter/UI/Landing/StockIn/stock_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigator_item.dart';

class DashboardScreen extends StatelessWidget {
  final selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashboardScreen({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: DashboardScreenView(
        selectTab: selectTab,
        existingOrder: existingOrder,
        isEditingOrder: isEditingOrder,
      ),
    );
  }
}

class DashboardScreenView extends StatefulWidget {
  final selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashboardScreenView({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  DashboardScreenViewState createState() => DashboardScreenViewState();
}

class DashboardScreenViewState extends State<DashboardScreenView> {
  int currentIndex = 0;
  GetStockMaintanencesModel getStockMaintanencesModel =
      GetStockMaintanencesModel();
  bool stockLoad = false;
  GetViewOrderModel? currentOrder;
  bool? currentIsEditing;

  List<Widget> get screens {
    List<Widget> pages = [
      HomePage(existingOrder: currentOrder, isEditingOrder: currentIsEditing),
      OrderPage(),
      ReportView(),
    ];

    if (getStockMaintanencesModel.data?.stockMaintenance == true) {
      pages.add(StockView());
    }

    pages.add(ProductView());

    return pages;
  }

  Widget getCurrentScreen() {
    return screens[currentIndex];
  }

  List<NavigatorItem> get navigatorItems {
    List<NavigatorItem> items = [
      NavigatorItem(Icons.home_outlined, 0, Container()),
      NavigatorItem(Icons.shopping_cart_outlined, 1, Container()),
      NavigatorItem(Icons.note_alt_outlined, 2, Container()),
    ];
    if (getStockMaintanencesModel.data?.stockMaintenance == true) {
      items.add(NavigatorItem(Icons.inventory, 3, Container()));
    }
    items.add(NavigatorItem(Icons.shopping_bag_outlined, 4, Container()));
    return items;
  }

  Future<void> callApis() async {
    if (widget.selectTab == 1) {
      currentIndex = 1;
    }
    context.read<FoodCategoryBloc>().add(StockDetails());
    setState(() {
      stockLoad = true;
    });
  }

  @override
  void initState() {
    currentOrder = widget.existingOrder;
    currentIsEditing = widget.isEditingOrder;
    callApis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return getCurrentScreen();
    }

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (currentIndex == 0) {
            debugPrint("Pop action was Unblocked.");
            Navigator.pop(context);
          }
        } else {
          debugPrint("Pop action was blocked.");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<FoodCategoryBloc, dynamic>(
          buildWhen: ((previous, current) {
            if (current is GetStockMaintanencesModel) {
              getStockMaintanencesModel = current;
              if (getStockMaintanencesModel.errorResponse?.isUnauthorized ==
                  true) {
                _handle401Error();
                return true;
              }
              if (getStockMaintanencesModel.success == true) {
                setState(() {
                  stockLoad = false;
                });
              } else {
                setState(() {
                  stockLoad = false;
                });
                showToast("No Stock found", context, color: false);
              }
              return true;
            }
            return false;
          }),
          builder: (context, dynamic) {
            return mainContainer();
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: blackColor45,
                spreadRadius: 0,
                blurRadius: 37,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: appPrimaryColor,
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                  if (index == 1) {
                    currentOrder = null;
                    currentIsEditing = null;
                  }
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: appPrimaryColor,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              unselectedItemColor: whiteColor,
              items: navigatorItems.map((e) {
                return getNavigationBarItem(
                  index: e.index,
                  iconData: e.iconData,
                  size: size,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  BottomNavigationBarItem getNavigationBarItem({
    required int index,
    required IconData iconData,
    required Size size,
  }) {
    bool isSelected = index == currentIndex;
    Color itemIconColor = isSelected ? appPrimaryColor : whiteColor;
    Color itemBackgroundColor = isSelected ? whiteColor : Colors.transparent;

    return BottomNavigationBarItem(
      label: '',
      icon: SizedBox(
        height: 35,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: itemBackgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(iconData, size: 24, color: itemIconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
