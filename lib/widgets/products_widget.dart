import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../inner_screens/edit_prod.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import 'text_widget.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;
  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _isLoading = false;
  String title = '';
  String sizes = '';
  String description = '';
  String ratings = '';
  String productCat = '';
  String imageUrl = '';
  String price = '0.0';
  double salePrice = 0.0;
  bool isOnSale = false;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void _deleteProduct() async {
    FocusScope.of(context).unfocus();
    try {

      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .delete();

      await Fluttertoast.showToast(
        msg: "Product has been updated",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );

    } on FirebaseException catch (error) {
      GlobalMethods.errorDialog(
          subtitle: '${error.message}', context: context);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot productsDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .get();
      description = productsDoc.get('description');
      ratings = productsDoc.get('ratings');
      sizes = productsDoc.get('size');
      title = productsDoc.get('title');
      productCat = productsDoc.get('productCategoryName');
      imageUrl = productsDoc.get('imageUrl');
      price = productsDoc.get('price') ?? '0';
      salePrice = productsDoc.get('salePrice');
      isOnSale = productsDoc.get('isOnSale');
        } catch (error) {
      setState(() {
        _isLoading = false;
      });
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;

    final color = Utils(context).color;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor.withOpacity(0.6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProductScreen(
                  id: widget.id,
                  title: title,
                  salePrice: salePrice,
                  productCat: productCat,
                  imageUrl: imageUrl.isEmpty
                      ? 'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png'
                      : imageUrl,
                  isOnSale: isOnSale,
                  description: description,
                  ratings: ratings,
                  price: price,
                  size: sizes,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.network(
                        imageUrl.isEmpty
                            ? 'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png'
                            : imageUrl,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const CircularProgressIndicator();
                        },
                        fit: BoxFit.fill,
                        width: 200,
                        height: 150,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: const Text('Edit'),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditProductScreen(
                                        id: widget.id,
                                        title: title,
                                        salePrice: salePrice,
                                        productCat: productCat,
                                        imageUrl: imageUrl.isEmpty
                                            ? 'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png'
                                            : imageUrl,
                                        isOnSale: isOnSale,
                                        description: description,
                                        ratings: ratings,
                                        price: price,
                                        size: sizes,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  _deleteProduct();
                                },
                              ),
                            ])
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    TextWidget(
                      text: isOnSale
                          ? '\$${salePrice.toStringAsFixed(2)}'
                          : '\$$price',
                      color: color,
                      textSize: 18,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Visibility(
                        visible: isOnSale,
                        child: Text(
                          '\$$price',
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: color),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text: title,
                  color: color,
                  textSize: 24,
                  isTitle: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}