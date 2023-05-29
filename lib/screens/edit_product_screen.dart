import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

enum ImportImage { Gallery, TakePhoto }

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    category: '',
    imageUrl: '',
  );
  String dropValue = '';
  String productTitle = 'Add New Product';
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
    'category': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    Provider.of<Products>(context, listen: false).fetchAllCategory();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final productId = ModalRoute.of(context)!.settings.arguments.toString();
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
          'category': _editedProduct.category,
        };
        dropValue = _editedProduct.category;
        _imageUrlController.text = _editedProduct.imageUrl;
        productTitle = 'Edit Product';
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      if (_editedProduct.id.isNotEmpty) {
        setState(() => _isLoading = true);
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
        showSnackBar("Success Update Product");
      } else {
        setState(() => _isLoading = true);
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_editedProduct);
          showSnackBar("Success Add new Product");
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('An error occured!'),
              content: const Text('Something went wrong.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Okay'),
                )
              ],
            ),
          );
        }
      }
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.greenAccent,
      content: Text(message),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _selectImage(ImportImage imageAction) async {
    final ImagePicker picker = ImagePicker();
    if (imageAction == ImportImage.Gallery)
// Pick an image.
    {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image!.path.isNotEmpty) _imageUrlController.text = image.path;
    } else
// Capture a photo.
    {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo!.path.isNotEmpty) _imageUrlController.text = photo.path;
    }

    if (_imageUrlController.text.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          category: _editedProduct.category,
                          title: value!,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a title.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          category: _editedProduct.category,
                          title: _editedProduct.title,
                          price: double.parse(value!),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than 0';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          category: _editedProduct.category,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value!,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description.';
                        }
                        if (value.length < 10) {
                          return 'Please enter a longer description.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    _categoryDropMenu(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => {
                            showBottomSheetForImage(context),
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text(
                                    'Click Here to Select Photo',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  )
                                : FittedBox(
                                    child: Image.file(
                                      File(_imageUrlController.text),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.network(
                                                  _editedProduct.imageUrl),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            enabled: false,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                category: _editedProduct.category,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value!,
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Choose photo';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Consumer<Products> _categoryDropMenu() {
    return Consumer<Products>(builder: (context, value, _) {
      final List<String> categories = Provider.of<Products>(context).category;
      if (categories.isEmpty)
        return Container(
          child: Text('Check Network and Try Again'),
        );
      return DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Choose Category';
          } else
            return null;
        },
        value: dropValue.isEmpty ? null : dropValue,
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        items: categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 20),
            ),
          );
        }).toList(),
        onSaved: (lastvalue) {
          _editedProduct = Product(
            id: _editedProduct.id,
            category: lastvalue.toString(),
            title: _editedProduct.title,
            price: _editedProduct.price,
            description: _editedProduct.description,
            imageUrl: _editedProduct.imageUrl,
          );
        },
        onChanged: (String? newValue) {
          setState(() {
            dropValue = newValue!;
          });
        },
      );
    });
  }

  Future<dynamic> showBottomSheetForImage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () => _selectImage(ImportImage.Gallery),
              child: Text('Pick image from Gallery'),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () => _selectImage(ImportImage.TakePhoto),
              child: Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
