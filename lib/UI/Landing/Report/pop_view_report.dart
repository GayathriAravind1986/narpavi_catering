import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ramanas_waiter/ModelClass/Report/Get_report_with_ordertype_model.dart';
import 'package:ramanas_waiter/Reusable/color.dart';
import 'package:ramanas_waiter/Reusable/space.dart';
import 'package:ramanas_waiter/Reusable/text_styles.dart';
import 'package:ramanas_waiter/UI/IminHelper/printer_helper.dart';
import 'package:ramanas_waiter/UI/Landing/Report/Report_helper.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class ThermalReportReceiptDialog extends StatefulWidget {
  final GetReportModel getReportModel;
  final bool showItems;
  const ThermalReportReceiptDialog(
    this.getReportModel, {
    super.key,
    required this.showItems,
  });

  @override
  State<ThermalReportReceiptDialog> createState() =>
      _ThermalReportReceiptDialogState();
}

class _ThermalReportReceiptDialogState
    extends State<ThermalReportReceiptDialog> {
  late SunmiPrinter sunmiPrinter;
  final GlobalKey reportKey = GlobalKey();
  bool _isSunmiDevice = false;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Mock service for web
    } else if (Platform.isAndroid) {
      _checkIfSunmiDevice();
    }
  }

  Future<void> _checkIfSunmiDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Check if manufacturer is SUNMI
      final isSunmi = androidInfo.manufacturer.toUpperCase().contains('SUNMI');

      setState(() => _isSunmiDevice = isSunmi);

      if (isSunmi) {
        debugPrint('✅ Running on Sunmi device: ${androidInfo.model}');
      } else {
        debugPrint(
          'ℹ️ Not a Sunmi device: ${androidInfo.manufacturer} ${androidInfo.model}',
        );
      }
    } catch (e) {
      setState(() => _isSunmiDevice = false);
      debugPrint('❌ Error checking device: $e');
    }
  }

  /// Sunmi printer
  Future<void> _printBillToSunmi(BuildContext context) async {
    if (!_isSunmiDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This device is not a Sunmi printer device"),
          backgroundColor: redColor,
        ),
      );
      return;
    }
    try {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: appPrimaryColor),
              SizedBox(height: 16),
              Text(
                "Printing to Sunmi device...",
                style: TextStyle(color: whiteColor),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;

      Uint8List? imageBytes = await captureMonochromeReceipt(reportKey);

      if (imageBytes == null) {
        throw Exception("Image capture failed: normalReceiptKey returned null");
      }

      await SunmiPrinter.printImage(imageBytes);
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.cutPaper();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bill printed successfully on Sunmi device!"),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sunmi print failed: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final reportLine = widget.getReportModel.orderTypes!.line!.data!;
    final reportParcel = widget.getReportModel.orderTypes!.parcel!.data!;
    final reportAc = widget.getReportModel.orderTypes!.ac!.data!;
    final reportHd = widget.getReportModel.orderTypes!.hd!.data!;
    final reportSwiggy = widget.getReportModel.orderTypes!.swiggy!.data!;

    List<Map<String, dynamic>> itemsLine = reportLine
        .map(
          (e) => {
            'name': e.productName,
            'qty': e.totalQty,
            'price': (e.unitPrice ?? 0).toDouble(),
            'total': (e.totalAmount ?? 0).toDouble(),
          },
        )
        .toList();
    List<Map<String, dynamic>> itemsParcel = reportParcel
        .map(
          (e) => {
            'name': e.productName,
            'qty': e.totalQty,
            'price': (e.unitPrice ?? 0).toDouble(),
            'total': (e.totalAmount ?? 0).toDouble(),
          },
        )
        .toList();
    List<Map<String, dynamic>> itemsAc = reportAc
        .map(
          (e) => {
            'name': e.productName,
            'qty': e.totalQty,
            'price': (e.unitPrice ?? 0).toDouble(),
            'total': (e.totalAmount ?? 0).toDouble(),
          },
        )
        .toList();
    List<Map<String, dynamic>> itemsHd = reportHd
        .map(
          (e) => {
            'name': e.productName,
            'qty': e.totalQty,
            'price': (e.unitPrice ?? 0).toDouble(),
            'total': (e.totalAmount ?? 0).toDouble(),
          },
        )
        .toList();
    List<Map<String, dynamic>> itemsSwiggy = reportSwiggy
        .map(
          (e) => {
            'name': e.productName,
            'qty': e.totalQty,
            'price': (e.unitPrice ?? 0).toDouble(),
            'total': (e.totalAmount ?? 0).toDouble(),
          },
        )
        .toList();
    String businessName = widget.getReportModel.businessName ?? '';
    String userName = widget.getReportModel.userName ?? '';
    String address = widget.getReportModel.address ?? '';
    String location = widget.getReportModel.location ?? '';
    String tableName = widget.getReportModel.tableName ?? '';
    String waiterName = widget.getReportModel.waiterName ?? '';
    String fromDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(widget.getReportModel.fromDate.toString()));

    String toDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(widget.getReportModel.toDate.toString()));
    String phone = widget.getReportModel.phone ?? '';
    double lineAmount =
        (widget.getReportModel.orderTypes!.line!.totalAmount ?? 0.0).toDouble();
    int lineQty = (widget.getReportModel.orderTypes!.line!.totalQty ?? 0.0)
        .toInt();
    double parcelAmount =
        (widget.getReportModel.orderTypes!.parcel!.totalAmount ?? 0.0)
            .toDouble();
    int parcelQty = (widget.getReportModel.orderTypes!.parcel!.totalQty ?? 0.0)
        .toInt();
    double acAmount = (widget.getReportModel.orderTypes!.ac!.totalAmount ?? 0.0)
        .toDouble();
    int acQty = (widget.getReportModel.orderTypes!.ac!.totalQty ?? 0.0).toInt();
    double hdAmount = (widget.getReportModel.orderTypes!.hd!.totalAmount ?? 0.0)
        .toDouble();
    int hdQty = (widget.getReportModel.orderTypes!.hd!.totalQty ?? 0.0).toInt();
    double swiggyAmount =
        (widget.getReportModel.orderTypes!.swiggy!.totalAmount ?? 0.0)
            .toDouble();
    int swiggyQty = (widget.getReportModel.orderTypes!.swiggy!.totalQty ?? 0.0)
        .toInt();
    double totalAmount = (widget.getReportModel.finalAmount ?? 0.0).toDouble();
    int totalQty = (widget.getReportModel.finalQty ?? 0.0).toInt();
    String date = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    return widget.getReportModel.orderTypes!.line!.data == null ||
            widget.getReportModel.orderTypes!.parcel!.data == null ||
            widget.getReportModel.orderTypes!.ac!.data == null ||
            widget.getReportModel.orderTypes!.hd!.data == null ||
            widget.getReportModel.orderTypes!.swiggy!.data == null
        ? Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            alignment: Alignment.center,
            child: Text(
              "No Report found",
              style: MyTextStyle.f16(greyColor, weight: FontWeight.w500),
            ),
          )
        : Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.2),
                  child: SingleChildScrollView(
                    child: Container(
                      width: size.width > 650
                          ? size.width * 0.4
                          : size.width * 0.95,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: const Text(
                                  "Report",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Thermal Receipt Widget
                          RepaintBoundary(
                            key: reportKey,
                            child: getReportReceiptWidget(
                              businessName: businessName,
                              tamilTagline: "",
                              address: address,
                              phone: phone,
                              itemsLine: itemsLine,
                              itemsParcel: itemsParcel,
                              itemsAc: itemsAc,
                              itemsHd: itemsHd,
                              itemsSwiggy: itemsSwiggy,
                              reportDate: date,
                              takenBy: userName,
                              tableName: tableName,
                              waiterName: waiterName,
                              lineAmount: lineAmount,
                              lineQty: lineQty,
                              parcelAmount: parcelAmount,
                              parcelQty: parcelQty,
                              acAmount: acAmount,
                              acQty: acQty,
                              hdAmount: hdAmount,
                              hdQty: hdQty,
                              swiggyAmount: swiggyAmount,
                              swiggyQty: swiggyQty,
                              totalQuantity: totalQty,
                              totalAmount: totalAmount,
                              fromDate: fromDate,
                              toDate: toDate,
                              location: location,
                              showItems: widget.showItems,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Close Button
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              WidgetsBinding.instance.addPostFrameCallback((
                                _,
                              ) async {
                                await _printBillToSunmi(context);
                              });
                            },
                            icon: const Icon(Icons.print),
                            label: const Text("Print(Sunmi)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: whiteColor,
                            ),
                          ),
                          horizontalSpace(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            label: const Text("CLOSE"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              foregroundColor: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
