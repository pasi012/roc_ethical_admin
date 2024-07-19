import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/MenuControllerr.dart';
import '../responsive.dart';
import '../screens/loading_manager.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widget.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({Key? key}) : super(key: key);

  @override
  _UploadProductFormState createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = 'Jackets';
  late final TextEditingController _titleController,
      _priceController,
      _ratingsController,
      _decController, _sizeController;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);
  String? imageUrl;
  @override
  void initState() {
    _priceController = TextEditingController();
    _titleController = TextEditingController();
    _decController = TextEditingController();
    _ratingsController = TextEditingController();
    _sizeController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    _decController.dispose();
    _ratingsController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
            subtitle: 'Please pick up an image', context: context);
        return;
      }

      final _uuid = const Uuid().v4();

      try {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('products')
            .child('$_uuid.jpg');
        if (kIsWeb) {
          await ref.putData(webImage);
        } else {
          await ref.putFile(_pickedImage!);
        }
        imageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
          'id': _uuid,
          'title': _titleController.text,
          'price': _priceController.text,
          'imageUrl': imageUrl,
          'productCategoryName': _catValue,
          'isOnSale': false,
          'salePrice': 0.1,
          'createdAt': Timestamp.now(),
          'ratings': _ratingsController.text,
          'description': _decController.text,
          'size': _sizeController.text
        });
        _clearForm();
        Fluttertoast.showToast(
          msg: "Product uploaded Successfully",
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

  void _clearForm() {
    _priceController.clear();
    _titleController.clear();
    _decController.clear();
    _ratingsController.clear();
    _sizeController.clear();
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    return Scaffold(
      key: context.read<MenuControllerr>().getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Header(
                          fct: () {
                            context
                                .read<MenuControllerr>()
                                .controlAddProductsMenu();
                          },
                          title: 'Add product',
                          showTexField: false),
                    ),
                    const SizedBox(
                      height: 25,
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
                                    onPressed: _clearForm,
                                    text: 'Clear form',
                                    icon: IconlyBold.danger,
                                    backgroundColor: Colors.red.shade300,
                                  ),
                                  ButtonsWidget(
                                    onPressed: () {
                                      _uploadForm();
                                    },
                                    text: 'Upload',
                                    icon: IconlyBold.upload,
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
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('Something went wrong');
    }
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
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
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
}
