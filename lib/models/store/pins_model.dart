import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/store_manager.dart';

List<StoreItemModel> pinModels = [
  StoreItemModel(
    title: 'Dollars',
    price: 200000,
    imageId: 1,
    color: Colors.green.shade300,
  ),
  StoreItemModel(
    title: 'Dislike',
    price: 1000000,
    imageId: 0,
    premium: true,
    color: Colors.red.shade300,
  ),
  StoreItemModel(
    title: 'Verified',
    price: 500000,
    imageId: 2,
    premium: true,
    color: Colors.blue.shade300,
  ),
];
