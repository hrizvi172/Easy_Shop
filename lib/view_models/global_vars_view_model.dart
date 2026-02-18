import 'dart:developer';
import 'package:easy_shop/models/Product.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/dummyjson_service.dart';

class GlobalVars with ChangeNotifier {
  GlobalVars._privateConstructor();
  static final GlobalVars _instance = GlobalVars._privateConstructor();
  factory GlobalVars() {
    return _instance;
  }

  final CollectionReference OrdersRef = FirebaseFirestore.instance.collection(
    'Orders',
  );

  final CollectionReference UsersInformation = FirebaseFirestore.instance
      .collection('UsersInfo');

  final DocumentReference ClothingInformation = FirebaseFirestore.instance
      .collection('Products')
      .doc('Clothing');

  final CollectionReference ProductsInformation = FirebaseFirestore.instance
      .collection('Products');

  final DocumentReference HomeImgsRef = FirebaseFirestore.instance
      .collection('HomeImages')
      .doc('Home_Images');

  late List<dynamic> _CartProds;

  List<Map<String, dynamic>> _Orders = [];

  late Map<String, dynamic> _UserInfo;

  List<String> _categories = [];

  Map<String, List<Product>> _AllProds = {'': []};

  bool _prodsLoaded = false;

  bool _cartLoaded = false;

  List<CartItem> _userCart = [];

  List<String> _FavsList = [];

  int selectedPage = 0;

  int _total = 0;

  int _shippingPrice = 40;

  String _paymentMethod = 'Select Method';

  List<String> _imgList = [];

  // Flag to determine data source (true = DummyJSON, false = Firebase)
  bool _useDummyJson = true;

  Future getHomeImages() async {
    try {
      // Try to get images from Firebase first
      DocumentSnapshot Himgs = await HomeImgsRef.get();
      if (Himgs.exists && Himgs.get('images') != null) {
        _imgList = List<String>.from(Himgs.get('images'));
      } else {
        // Use default high-quality images if Firebase is empty
        _imgList = [
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        ];
      }
    } catch (e) {
      log('Error loading home images: $e');
      // Use default images on error
      _imgList = [
        'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
      ];
    }
  }

  Future getAllCategories() async {
    if (_useDummyJson) {
      // Get categories from DummyJSON API
      _categories = await DummyJsonService.getAllCategories();
    } else {
      // Get categories from Firebase (original code)
      try {
        DocumentSnapshot doc = await ClothingInformation.get();
        if (doc.exists) {
          _categories = List<String>.from(doc.get('Categories'));
        }
      } catch (e) {
        log('Error loading categories from Firebase: $e');
        _categories = [];
      }
    }
  }

  Future getAllProds() async {
    _AllProds.clear();
    await getAllCategories();

    if (_useDummyJson) {
      // Get products from DummyJSON API
      try {
        for (int i = 0; i < _categories.length; i++) {
          List<Product> catProds = await DummyJsonService.getProductsByCategory(
            _categories[i],
          );
          _AllProds[_categories[i]] = catProds;
        }
      } catch (e) {
        log('Error loading products from DummyJSON: $e');
      }
    } else {
      // Get products from Firebase (original code)
      try {
        for (int i = 0; i < _categories.length; i++) {
          QuerySnapshot qSnapshot = await ClothingInformation.collection(
            _categories[i],
          ).get();
          List<Product> catProds = [];
          for (int j = 0; j < qSnapshot.docs.length; j++) {
            catProds.add(
              Product.fromFirebase(
                id: qSnapshot.docs[j].id,
                images: qSnapshot.docs[j]['images'],
                colors: qSnapshot.docs[j]['Colors'],
                title: qSnapshot.docs[j]['Title'],
                price: qSnapshot.docs[j]['Price'],
              ),
            );
          }
          _AllProds[_categories[i]] = catProds;
        }
      } catch (e) {
        log('Error loading products from Firebase: $e');
      }
    }
    prodsBool(true);
  }

  Product? getSpecificProd(String id) {
    if (_AllProds.isNotEmpty) {
      for (int i = 0; i < _categories.length; i++) {
        final list = _AllProds[_categories[i]];
        if (list == null) continue;
        for (int j = 0; j < list.length; j++) {
          if (list[j].id == id) {
            return list[j];
          }
        }
      }
    } else {
      log('No Products');
    }
    return null;
  }

  Future fillCartList(var CartProds) async {
    _userCart = [];
    await getAllProds();
    for (int i = 0; i < CartProds.length; i++) {
      Product? tempProd = getSpecificProd(CartProds[i]['id']);
      if (tempProd == null) continue;
      _userCart.add(
        CartItem(
          product: Product(
            id: tempProd.id,
            images: tempProd.images,
            colors: tempProd.colors,
            title: tempProd.title,
            price: tempProd.price,
            description: tempProd.description,
            category: tempProd.category,
            rating: tempProd.rating,
            stock: tempProd.stock,
            brand: tempProd.brand,
            discountPercentage: tempProd.discountPercentage,
          ),
          quantity: CartProds[i]['quantity'],
          option1: CartProds[i]['option1'],
          uid: tempProd.id + CartProds[i]['option1'],
        ),
      );
    }
  }

  Future getUserCart(User? u) async {
    if (u == null) return;
    try {
      DocumentSnapshot documentSnapshot = await UsersInformation.doc(
        // ignore: invalid_null_aware_operator
        u?.uid ?? '',
      ).get();
      if (documentSnapshot.exists) {
        _CartProds = documentSnapshot.get('cart') ?? [];
        await fillCartList(_CartProds);
        TotalPrice();
      }
    } catch (e) {
      log('Error loading user cart: $e');
    }
  }

  Future getUserInfo(User? u) async {
    if (u == null) return;
    try {
      DocumentSnapshot documentSnapshot = await UsersInformation.doc(
        // ignore: invalid_null_aware_operator
        u?.uid ?? '',
      ).get();
      _UserInfo = documentSnapshot.data() as Map<String, dynamic>? ?? {};
    } catch (e) {
      log('Error loading user info: $e');
      _UserInfo = {};
    }
  }

  Future DeleteItemFromCart(User? u, int index) async {
    if (u == null) return;
    try {
      // ignore: invalid_null_aware_operator
      DocumentReference docRef = UsersInformation.doc(u?.uid ?? '');
      DocumentSnapshot documentSnapshot = await docRef.get();
      _CartProds = documentSnapshot.get('cart');
      await docRef.update({
        'cart': FieldValue.arrayRemove([_CartProds[index]]),
      });
    } catch (e) {
      log('Error deleting item from cart: $e');
    }
  }

  Future getUserOrders(List<dynamic> ordersID) async {
    _Orders.clear();
    if (ordersID.isNotEmpty) {
      for (int i = 0; i < ordersID.length; i++) {
        try {
          DocumentSnapshot oSnapshot = await OrdersRef.doc(ordersID[i]).get();
          if (oSnapshot.exists) {
            Map<String, dynamic> temp =
                oSnapshot.data() as Map<String, dynamic>? ?? {};
            temp['ID'] = oSnapshot.id;
            _Orders.add(temp);
          }
        } catch (e) {
          log('Error loading order ${ordersID[i]}: $e');
        }
      }
    } else {
      log('No Orders');
    }
    _Orders.sort((a, b) => b['Date&Time'].compareTo(a['Date&Time']));
  }

  void addToUserCart(Product p, int quantity, String option1) {
    _userCart.add(
      CartItem(
        product: p,
        quantity: quantity,
        option1: option1,
        uid: p.id + option1,
      ),
    );
    notifyListeners();
    TotalPrice();
  }

  void removeFromUserCart(int index) {
    _userCart.removeAt(index);
    notifyListeners();
    TotalPrice();
  }

  void incrementQ(String uid) {
    for (int i = 0; i < _userCart.length; i++) {
      if (uid == _userCart[i].uid) {
        _userCart[i].quantity += 1;
      }
    }
    notifyListeners();
    TotalPrice();
  }

  void decrementQ(String uid) {
    for (int i = 0; i < _userCart.length; i++) {
      if (uid == _userCart[i].uid) {
        if (_userCart[i].quantity > 1) {
          _userCart[i].quantity -= 1;
        } else {
          _userCart[i].quantity = 1;
        }
      }
    }
    notifyListeners();
    TotalPrice();
  }

  void resetCart() {
    _userCart = [];
    notifyListeners();
    TotalPrice();
  }

  void resetPmethod() {
    _paymentMethod = 'Select Method';
    notifyListeners();
  }

  void TotalPrice() {
    if (_userCart.isEmpty) {
      _total = 0;
    } else {
      _total = _shippingPrice;
    }
    for (int i = 0; i < _userCart.length; i++) {
      _total += (_userCart[i].product.price * _userCart[i].quantity);
    }
    notifyListeners();
  }

  Future addCartItems(User u, List<CartItem> c) async {
    for (int i = 0; i < c.length;) {
      // ignore: unused_local_variable
      Map map = new Map<String, dynamic>();
      // ignore: invalid_null_aware_operator
      return await UsersInformation.doc(u?.uid ?? '').set({
        'cart': FieldValue.arrayUnion([
          map = {
            'id': c[i].product.id,
            'option1': c[i].option1,
            'quantity': c[i].quantity,
          },
        ]),
      }, SetOptions(merge: true));
    }
  }

  void changePaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void prodsBool(bool b) {
    _prodsLoaded = b;
    notifyListeners();
  }

  void addToFavs(String id) {
    // ignore: unnecessary_null_comparison
    _UserInfo != null && _UserInfo.containsKey('Favorites')
        ? _UserInfo['Favorites'].add(id)
        : _UserInfo = {
            'Favorites': [id],
          };
    notifyListeners();
  }

  void removeFromFavs(String id) {
    _UserInfo['Favorites'].remove(id);
    notifyListeners();
  }

  // Method to toggle between DummyJSON and Firebase
  void toggleDataSource(bool useDummyJson) {
    _useDummyJson = useDummyJson;
    notifyListeners();
  }

  int get total => _total;

  List<CartItem> get userCart => _userCart;

  get CartProds => _CartProds;

  get prodsLoaded => _prodsLoaded;

  List<Map<String, dynamic>> get Orders => _Orders;

  Map<String, dynamic> get UserInfo => _UserInfo;

  List<String> get categories => _categories;

  Map<String, List<Product>> get AllProds => _AllProds;

  int get shippingPrice => _shippingPrice;

  List<String> get FavsList => _FavsList;

  String get paymentMethod => _paymentMethod;

  List<String> get imgList => _imgList;

  bool get cartLoaded => _cartLoaded;

  bool get useDummyJson => _useDummyJson;
}
