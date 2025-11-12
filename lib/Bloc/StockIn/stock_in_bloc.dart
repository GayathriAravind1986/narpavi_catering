import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramanas_waiter/Api/apiProvider.dart';

abstract class StockInEvent {}

class StockInLocation extends StockInEvent {}

class StockInSupplier extends StockInEvent {
  String locationId;
  StockInSupplier(this.locationId);
}

class StockInAddProduct extends StockInEvent {
  String locationId;
  StockInAddProduct(this.locationId);
}

class SaveStockIn extends StockInEvent {
  final String orderPayloadJson;
  SaveStockIn(this.orderPayloadJson);
}

class StockDetails extends StockInEvent {}

class StockInBloc extends Bloc<StockInEvent, dynamic> {
  StockInBloc() : super(dynamic) {
    on<StockInLocation>((event, emit) async {
      await ApiProvider()
          .getLocationAPI()
          .then((value) {
            emit(value);
          })
          .catchError((error) {
            emit(error);
          });
    });
    on<StockInSupplier>((event, emit) async {
      await ApiProvider()
          .getSupplierAPI(event.locationId)
          .then((value) {
            emit(value);
          })
          .catchError((error) {
            emit(error);
          });
    });
    on<StockInAddProduct>((event, emit) async {
      await ApiProvider()
          .getAddProductAPI(event.locationId)
          .then((value) {
            emit(value);
          })
          .catchError((error) {
            emit(error);
          });
    });
    on<SaveStockIn>((event, emit) async {
      await ApiProvider()
          .postSaveStockInAPI(event.orderPayloadJson)
          .then((value) {
            emit(value);
          })
          .catchError((error) {
            emit(error);
          });
    });
    on<StockDetails>((event, emit) async {
      await ApiProvider()
          .getStockDetailsAPI()
          .then((value) {
            emit(value);
          })
          .catchError((error) {
            emit(error);
          });
    });
  }
}
