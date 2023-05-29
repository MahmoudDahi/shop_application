import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/badge.dart';
import '../widgets/main_drawer.dart';
import '../widgets/products_grid.dart';
import 'cart_screen.dart';

enum Ordering { Desc, Asc }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isLoading = true;

  String _filterValue = "All Categories";
  var _isLoadingFilter = false;
  var _sort = Ordering.Asc;
  var _enableLimit = false;
  var _limit = 0;
  final _formKey = GlobalKey<FormState>();
  List<String> _filterList = [];

  @override
  void initState() {
    Provider.of<Products>(context, listen: false).fetchAllCategory();
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((_) {
      // self solution
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  void _validation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    Navigator.of(context).pop();
    _sort = Ordering.Asc;
    _filterProduct();
  }

  Future<void> _showDialogFilter() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter'),
          content: StatefulBuilder(
            builder: (context, setState) => Container(
              height: 200,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _filterValue.isEmpty
                            ? _filterList[0]
                            : _filterValue,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Category';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _filterValue = value.toString();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _filterList
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: _enableLimit,
                              onChanged: (value) {
                                setState(() {
                                  _enableLimit = !_enableLimit;
                                });
                              }),
                          Text('Limit'),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _limit.toString(),
                              keyboardType: TextInputType.number,
                              enabled: _enableLimit,
                              validator: (value) {
                                if (_enableLimit &&
                                    (value == null || value.isEmpty))
                                  return 'Please enter Limit';
                                return null;
                              },
                              onSaved: (newValue) {
                                if (newValue == null || newValue.isEmpty)
                                  _limit = 0;
                                else
                                  _limit = int.tryParse(newValue.toString())!
                                      .toInt();
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Filter'),
              onPressed: () {
                _validation();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchByProduct(String searchitem) async {
    setState(() {
      _isLoadingFilter = true;
    });
    await Provider.of<Products>(context, listen: false)
        .searchProduct(searchitem)
        .then((value) => null)
        .catchError((error) => null);
    setState(() {
      _isLoadingFilter = false;
    });
  }

  void _filterProduct() async {
    setState(() {
      _isLoadingFilter = true;
    });
    if (_filterValue.contains('All')) {
      _filterValue = '';
    }
    String sort = 'asc';
    if (_sort == Ordering.Desc) {
      sort = 'desc';
    }

    if (!_enableLimit) _limit = 0;

    await Provider.of<Products>(context, listen: false)
        .filterProduct(_filterValue, sort, _limit)
        .then((value) => null)
        .catchError((error) => null);
    setState(() {
      _isLoadingFilter = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text(
          'Fake Store',
        ),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, ch) => BadgeDot(
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Consumer<Products>(builder: (context, product, _) {
                  if (product.category.isEmpty) return SizedBox();
                  _filterList = [];
                  _filterList.add('All Categories');
                  _filterList.addAll(product.category);
                  return Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              if (value.isNotEmpty) _searchByProduct(value);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              label: Text('Search'),
                              suffixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton.icon(
                          onPressed: () {
                            _showDialogFilter();
                          },
                          icon: Icon(
                            Icons.sort,
                          ),
                          label: Text('Filter')),
                      SizedBox(
                        width: 8,
                      ),
                      IconButton(
                        onPressed: () {
                          if (_sort == Ordering.Asc) {
                            _sort = Ordering.Desc;
                          } else {
                            _sort = Ordering.Asc;
                          }
                          _filterProduct();
                        },
                        icon: Icon(Icons.sort_by_alpha),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  );
                }),
                _isLoadingFilter
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Expanded(child: ProductsGrid()),
              ],
            ),
    );
  }
}
