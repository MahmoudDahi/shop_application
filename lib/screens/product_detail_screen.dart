import 'package:flutter/material.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.greenAccent,
      content: Text(message),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  selectActionInMenu(String value, BuildContext context, String productId) {
    if (int.parse(value) == 0) {
      Navigator.of(context).pushNamed(
        EditProductScreen.routeName,
        arguments: productId,
      );
    } else {
      Provider.of<Products>(context, listen: false)
          .deleteProduct(productId)
          .then(
        (value) {
          Navigator.of(context).pop();
          showSnackBar('Success Delete Porduct', context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments;
    final loadedProduct = Provider.of<Products>(context, listen: false)
        .findById(productId.toString());
    List<String> menuOption = ['Edit Product', 'Delete Product'];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            expandedHeight: 300,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  underline: SizedBox(),
                  onChanged: (value) => selectActionInMenu(
                      value.toString(), context, productId.toString()),
                  items: menuOption.map((String items) {
                    return DropdownMenuItem(
                      value: menuOption.indexOf(items),
                      child: Text(items),
                    );
                  }).toList(),
                  icon: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loadedProduct.title,
                ),
              ),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 10,
              ),
              Text(
                '\$${loadedProduct.price}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 800),
            ]),
          ),
        ],
      ),
    );
  }
}
