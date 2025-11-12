import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ramanas_waiter/Alertbox/AlertDialogBox.dart';
import 'package:ramanas_waiter/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramanas_waiter/Alertbox/snackBarAlert.dart';
import 'package:ramanas_waiter/Bloc/Products/product_category_bloc.dart';
import 'package:ramanas_waiter/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:ramanas_waiter/ModelClass/Products/get_products_cat_model.dart';
import 'package:ramanas_waiter/Reusable/color.dart';
import 'package:ramanas_waiter/Reusable/space.dart';
import 'package:ramanas_waiter/Reusable/text_styles.dart';
import 'package:ramanas_waiter/UI/Authentication/login_screen.dart';

class ProductView extends StatelessWidget {
  final from;
  const ProductView({super.key, this.from});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCategoryBloc(),
      child: ProductViewView(from: from),
    );
  }
}

class ProductViewView extends StatefulWidget {
  final from;
  const ProductViewView({super.key, this.from});

  @override
  ProductViewViewState createState() => ProductViewViewState();
}

class ProductViewViewState extends State<ProductViewView> {
  GetCategoryModel getCategoryModel = GetCategoryModel();
  GetProductsCatModel getProductsCatModel = GetProductsCatModel();
  GetStockMaintanencesModel getStockMaintanencesModel =
      GetStockMaintanencesModel();
  dynamic selectedValue;
  dynamic categoryId;

  bool categoryLoad = false;
  bool productLoad = false;
  String? errorMessage;

  void refreshProduct() {
    if (!mounted || !context.mounted) return;
    context.read<ProductCategoryBloc>().add(ProductItem(categoryId ?? ""));
    setState(() {
      categoryLoad = true;
      productLoad = true;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductCategoryBloc>().add(ProductCategory());
    context.read<ProductCategoryBloc>().add(StockDetails());
    context.read<ProductCategoryBloc>().add(ProductItem(categoryId ?? ""));
    setState(() {
      categoryLoad = true;
      productLoad = true;
    });
  }

  void _refreshData() {
    setState(() {
      selectedValue = null;
      categoryId = null;
    });
    context.read<ProductCategoryBloc>().add(StockDetails());
    context.read<ProductCategoryBloc>().add(ProductItem(categoryId ?? ""));
    context.read<ProductCategoryBloc>().add(ProductCategory());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: size.width * 0.5,
                    child: DropdownButtonFormField<String>(
                      value:
                          (getCategoryModel.data?.any(
                                (item) => item.name == selectedValue,
                              ) ??
                              false)
                          ? selectedValue
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey, // normal state
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor, // your custom color
                            width: 1.8,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                            width: 1.8,
                          ),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      items: getCategoryModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedValue = newValue;
                            final selectedItem = getCategoryModel.data
                                ?.firstWhere((item) => item.name == newValue);
                            categoryId = selectedItem?.id.toString();
                            context.read<ProductCategoryBloc>().add(
                              ProductItem(categoryId ?? ""),
                            );
                          });
                        }
                      },
                      hint: Text(
                        '-- Select Category --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _refreshData();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: appPrimaryColor,
                      size: 28,
                    ),
                    tooltip: 'Refresh Products',
                  ),
                ],
              ),
              SizedBox(height: 24),
              productLoad
                  ? Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.3,
                      ),
                      alignment: Alignment.center,
                      child: const SpinKitChasingDots(
                        color: appPrimaryColor,
                        size: 30,
                      ),
                    )
                  : getProductsCatModel.data == null
                  ? Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.3,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No Products found !!!",
                        style: MyTextStyle.f16(
                          greyColor,
                          weight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      children: getProductsCatModel.data!.categories!.map((e) {
                        if (e.products!.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.categoryName ?? "",
                              style: MyTextStyle.f16(
                                blackColor,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth:
                                      800, // ensures table layout looks good on small screens
                                ),
                                child: Table(
                                  border: TableBorder.all(),
                                  columnWidths: const {
                                    0: FixedColumnWidth(60),
                                    1: FlexColumnWidth(),
                                    2: FlexColumnWidth(),
                                    3: FixedColumnWidth(100),
                                    4: FixedColumnWidth(100),
                                    5: FixedColumnWidth(100),
                                    6: FixedColumnWidth(100),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: appPrimaryColor,
                                      ),
                                      children: [
                                        _tableHeader("S.No"),
                                        _tableHeader("Product Name"),
                                        _tableHeader("Product Code"),
                                        _tableHeader("Base Price"),
                                        _tableHeader("Parcel"),
                                        _tableHeader("AC"),
                                        // _tableHeader("HD"),
                                      ],
                                    ),
                                    ...List.generate(e.products!.length, (
                                      index,
                                    ) {
                                      final item = e.products![index];
                                      return TableRow(
                                        children: [
                                          _tableCell("${index + 1}"),
                                          _tableCell(item.name ?? ""),
                                          _tableCell(item.shortCode ?? ""),
                                          _tableCell(
                                            item.basePrice?.toStringAsFixed(
                                                  2,
                                                ) ??
                                                "",
                                          ),
                                          _tableCell(
                                            item.parcelPrice?.toStringAsFixed(
                                                  2,
                                                ) ??
                                                "",
                                          ),
                                          _tableCell(
                                            item.acPrice?.toStringAsFixed(2) ??
                                                "",
                                          ),
                                          // _tableCell(
                                          //   item.hdPrice?.toStringAsFixed(2) ??
                                          //       "",
                                          // ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Total Count: ${e.products!.length}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
              // if (getProductsCatModel.data != null)
              //   Center(
              //     child: ElevatedButton.icon(
              //       onPressed: () async {
              //         showDialog(
              //           context: context,
              //           builder: (context) =>
              //               ThermalProductsReceiptDialog(getProductsCatModel),
              //         );
              //       },
              //       icon: const Icon(Icons.print),
              //       label: const Text("Print"),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: greenColor,
              //         foregroundColor: whiteColor,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: size.width < 650
            ? const Size.fromHeight(40)
            : const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: whiteColor,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            width: double.infinity,
            color: whiteColor,
            padding: const EdgeInsets.only(top: 28, left: 20, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getStockMaintanencesModel.data?.name != null
                    ? Expanded(
                        child: Text(
                          getStockMaintanencesModel.data!.name.toString(),
                          style: size.width < 650
                              ? MyTextStyle.f18(
                                  appPrimaryColor,
                                  weight: FontWeight.bold,
                                )
                              : MyTextStyle.f28(
                                  appPrimaryColor,
                                  weight: FontWeight.bold,
                                ),
                        ),
                      )
                    : Text(""),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: size.width < 650 ? 25 : 35,
                        color: appPrimaryColor,
                      ),
                      onPressed: () {
                        showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductCategoryBloc, dynamic>(
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
                categoryLoad = false;
              });
            } else {
              setState(() {
                categoryLoad = false;
              });
              showToast("No Stock found", context, color: false);
            }
            return true;
          }
          if (current is GetCategoryModel) {
            getCategoryModel = current;
            if (getCategoryModel.success == true) {
              setState(() {
                categoryLoad = false;
              });
            }
            if (getCategoryModel.errorResponse?.isUnauthorized == true) {
              _handle401Error();
              return true;
            }
            return true;
          }
          if (current is GetProductsCatModel) {
            getProductsCatModel = current;
            if (getProductsCatModel.errorResponse?.isUnauthorized == true) {
              _handle401Error();
              return true;
            }
            if (getProductsCatModel.success == true) {
              setState(() {
                productLoad = false;
              });
            }
            return true;
          }
          return false;
        }),
        builder: (context, dynamic) {
          return mainContainer();
        },
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

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );

  Widget _tableCell(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
