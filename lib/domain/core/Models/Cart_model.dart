import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/ShopMenu_model.dart'; // Make sure this path is correct for your Product model

class CartItem {
  final Product product;
  RxInt quantity; // Make quantity reactive so UI updates when it changes

  CartItem({required this.product, int quantity = 1})
    : quantity = quantity.obs; // Initialize quantity as an RxInt
}
