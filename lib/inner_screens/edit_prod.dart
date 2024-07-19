import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/MenuControllerr.dart';
import '../responsive.dart';
import '../screens/loading_manager.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widget.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen(
      {Key? key,
      required this.id,
      required this.title,
      required this.salePrice,
      required this.productCat,
      required this.imageUrl,
      required this.isOnSale,
      required this.description,
      required this.ratings,
      required this.price,
      required this.size,
      })
      : super(key: key);

  final String id, title, price, productCat, imageUrl, description, ratings, size;
  final bool isOnSale;
  final double salePrice;
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  // Title and price controllers
  late final TextEditingController _titleController, _sizeController, _priceController, _decController, _ratingsController;
  // Category
  late String _catValue;
  // Sale
  String? _salePercent;
  late String percToShow;
  late double _salePrice;
  late bool _isOnSale;
  // Image
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;
  // kg or Piece,
  late int val;
  // while loading
  bool _isLoading = false;
  String? imageUri;
  @override
  void initState() {
    // set the price and title initial values and initialize the controllers
    _decController = TextEditingController(text: widget.description);
    _ratingsController = TextEditingController(text: widget.ratings);
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _sizeController = TextEditingController(text: widget.size);
    // Set the variables
    _salePrice = widget.salePrice;
    _catValue = widget.productCat;
    _isOnSale = widget.isOnSale;
    _imageUrl = widget.imageUrl;
    // Calculate the percentage
    percToShow = '${(100 -
                (_salePrice * 100) /
                    double.parse(
                        widget.price)) // WIll be the price instead of 1.88
            .round()
            .toStringAsFixed(1)}%';
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controllers
    _decController.dispose();
    _priceController.dispose();
    _titleController.dispose();
    _ratingsController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _updateProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
        final ref = FirebaseStorage.instance
        .ref()
        .child('userImage')
        .child('${widget.id}jpg');
        if(kIsWeb){
          await ref.putData(webImage);
        }else{
          await ref.putFile(_pickedImage!);
        }
        imageUri = await ref.getDownloadURL();

        }
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.id)
            .update({
          'title': _titleController.text,
          'price': _priceController.text,
          'imageUrl':
          _pickedImage == null ? widget.imageUrl : imageUri,
          'productCategoryName': _catValue,
          'isOnSale': false,
          'salePrice': 0.1,
          'createdAt': Timestamp.now(),
          'ratings': _ratingsController.text,
          'description': _decController.text,
          'size': _sizeController.text
        });
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = theme == true ? Colors.white : Colors.black;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: _scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return Scaffold(
      key: context.read<MenuControllerr>().getEditProductscaffoldKey,
      drawer: const SideMenu(),
      body: Row(
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(
              child: SideMenu(),
            ),
          Expanded(
            flex: 5,
            child: LoadingManager(
              isLoading: _isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Header(
                        showTexField: false,
                        fct: () {
                          context
                              .read<MenuControllerr>()
                              .controlEditProductsMenu();
                        },
                        title: 'Edit Product',
                      ),
                    ),
                    Container(
                      width: size.width > 1000 ? 1000 : size.width,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    TextWidget(
                                      text: 'Product title*',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: TextFormField(
                                        controller: _titleController,
                                        key: const ValueKey('Title'),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter a Title';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: _scaffoldColor,
                                          border: InputBorder.none,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: color,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),

                                Column(
                                  children: [
                                    TextWidget(
                                      text: 'Product description*',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: TextFormField(
                                        controller: _decController,
                                        key: const ValueKey('Description'),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter a Description';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: _scaffoldColor,
                                          border: InputBorder.none,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: color,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),

                                Column(
                                  children: [
                                    TextWidget(
                                      text: 'Product ratings*',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: TextFormField(
                                        controller: _ratingsController,
                                        key: const ValueKey('Ratings'),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter a Ratings';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: _scaffoldColor,
                                          border: InputBorder.none,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: color,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Price*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: _priceController,
                                                key: const ValueKey(
                                                    'Price \$'),
                                                keyboardType:
                                                TextInputType.number,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Price is missed';
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.]')),
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: 'S',
                                                  filled: true,
                                                  fillColor: _scaffoldColor,
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: color,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Size*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: _sizeController,
                                                key: const ValueKey(
                                                    'size'),
                                                keyboardType:
                                                TextInputType.number,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Price is missed';
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.]')),
                                                ],
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: _scaffoldColor,
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: color,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Porduct category*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        // Drop down menu code here
                                        _categoryDropDown(),
                                      ],
                                    ),
                                  ),
                                ),
                                // Image to be picked code is here
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: size.width > 650
                                            ? 350
                                            : size.width * 0.45,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                          BorderRadius.circular(12.0),
                                        ),
                                        child: _pickedImage == null
                                            ? dottedBorder(color: color)
                                            : ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          child: kIsWeb
                                              ? Image.memory(webImage,
                                              fit: BoxFit.fill)
                                              : Image.file(_pickedImage!,
                                              fit: BoxFit.fill),
                                        )),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FittedBox(
                                      child: Column(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _pickedImage = null;
                                                webImage = Uint8List(8);
                                              });
                                            },
                                            child: TextWidget(
                                              text: 'Clear',
                                              color: Colors.red,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: TextWidget(
                                              text: 'Update image',
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ButtonsWidget(
                                    onPressed: () async {
                                      GlobalMethods.warningDialog(
                                          title: 'Delete?',
                                          subtitle: 'Press okay to confirm',
                                          fct: () async {
                                            await FirebaseFirestore.instance
                                                .collection('products')
                                                .doc(widget.id)
                                                .delete();
                                            await Fluttertoast.showToast(
                                              msg: "Product has been deleted",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                            );
                                            while (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          context: context);
                                    },
                                    text: 'Delete',
                                    icon: IconlyBold.danger,
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                  ButtonsWidget(
                                    onPressed: () {
                                      _updateProduct();
                                    },
                                    text: 'Update',
                                    icon: IconlyBold.setting,
                                    backgroundColor: Colors.blue,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dottedBorder({
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: const [6.7],
          borderType: BorderType.RRect,
          color: color,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _pickedImage == null
                    ? Image.network(_imageUrl, width: 200, height: 200,)
                    : (kIsWeb)
                    ? Image.memory(
                  webImage,
                  fit: BoxFit.fill,
                  width: 200, height: 200,
                )
                    : Image.file(
                  _pickedImage!,
                  fit: BoxFit.fill,
                  width: 200, height: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: (() {
                      _pickImage();
                    }),
                    child: TextWidget(
                      text: 'Choose an image',
                      color: Colors.blue,
                    ))
              ],
            ),
          )),
    );
  }

  Widget _categoryDropDown() {
    final color = Utils(context).color;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              value: _catValue,
              onChanged: (value) {
                setState(() {
                  _catValue = value!;
                });
                print(_catValue);
              },
              hint: const Text('Select a category'),
              items: const [
                DropdownMenuItem(
                  value: 'Jackets',
                  child: Text(
                    'Jackets',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Tops',
                  child: Text(
                    'Tops',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Bags',
                  child: Text(
                    'Bags',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Jumpsuits & Dungarees',
                  child: Text(
                    'Jumpsuits & Dungarees',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Skirts',
                  child: Text(
                    'Skirts',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Dresses',
                  child: Text(
                    'Dresses',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Jeans',
                  child: Text(
                    'Jeans',
                  ),
                )
              ],
            )),
      ),
    );
  }

  DropdownButtonHideUnderline salePourcentageDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem<String>(
            value: '10',
            child: Text('10%'),
          ),
          DropdownMenuItem<String>(
            value: '15',
            child: Text('15%'),
          ),
          DropdownMenuItem<String>(
            value: '25',
            child: Text('25%'),
          ),
          DropdownMenuItem<String>(
            value: '50',
            child: Text('50%'),
          ),
          DropdownMenuItem<String>(
            value: '75',
            child: Text('75%'),
          ),
          DropdownMenuItem<String>(
            value: '0',
            child: Text('0%'),
          ),
        ],
        onChanged: (value) {
          if (value == '0') {
            return;
          } else {
            setState(() {
              _salePercent = value;
              _salePrice = double.parse(widget.price) -
                  (double.parse(value!) * double.parse(widget.price) / 100);
            });
          }
        },
        hint: Text(_salePercent ?? percToShow),
        value: _salePercent,
      ),
    );
  }

  DropdownButtonHideUnderline catDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem<String>(
            value: 'Jackets',
            child: Text('Jackets'),
          ),
          DropdownMenuItem<String>(
            value: 'Tops',
            child: Text('Tops'),
          ),
          DropdownMenuItem<String>(
            value: 'Bags',
            child: Text('Bags'),
          ),
          DropdownMenuItem<String>(
            value: 'Jumpsuits & Dungarees',
            child: Text('Jumpsuits & Dungarees'),
          ),
          DropdownMenuItem<String>(
            value: 'Skirts',
            child: Text('Skirts'),
          ),
          DropdownMenuItem<String>(
            value: 'Dresses',
            child: Text('Dresses'),
          ),
          DropdownMenuItem<String>(
            value: 'Jeans',
            child: Text('Jeans'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _catValue = value!;
          });
        },
        hint: const Text('Select a Category'),
        value: _catValue,
      ),
    );
  }

  Future<void> _pickImage() async {
    // MOBILE
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var selected = File(image.path);

        setState(() {
          _pickedImage = selected;
        });
      } else {
        log('No file selected');
        // showToast("No file selected");
      }
    }
    // WEB
    else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _pickedImage = File("a");
          webImage = f;
        });
      } else {
        log('No file selected');
      }
    } else {
      log('Perm not granted');
    }
  }
}
