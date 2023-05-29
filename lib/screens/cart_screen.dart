import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = true;

  @override
  void initState() {
    Provider.of<Cart>(context, listen: false)
        .fetchAndSetCartForUser()
        .then(
          (value) => setState(() {
            _isLoading = false;
          }),
        )
        .catchError((error) {
      print(error);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<Cart>(
              builder: (context, cart, _) => Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(15),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(
                              '\$${cart.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          OrderButton(cart: cart),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) => CartItem(
                        id: cart.items[i].id,
                        price: cart.items[i].price,
                        quantity: cart.items[i].quantity,
                        title: cart.items[i].title,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    required this.cart,
  });

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              setState(() {
                _isLoading = false;
              });
            },
      style: TextButton.styleFrom(
        
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('ORDER NOW'),
    );
  }
}
