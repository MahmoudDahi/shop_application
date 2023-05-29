import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: Provider.of<Auth>(context).getProfileUser(),
        builder: (context, snapshot) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
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
                    'Profile',
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                snapshot.connectionState == ConnectionState.waiting
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      ]
                    : snapshot.hasError
                        ? [
                            Container(
                              child: Text(snapshot.error.toString()),
                            )
                          ]
                        : [
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Form(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          label: Text('User Name'),
                                          prefixIcon: Icon(Icons.person)),
                                      initialValue: snapshot.data!.username,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                        label: Text('E-mail'),
                                        prefixIcon: Icon(Icons.email),
                                      ),
                                      initialValue: snapshot.data!.email,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          label: Text('Phone'),
                                          prefixIcon: Icon(Icons.phone)),
                                      initialValue: snapshot.data!.phonenumber,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          label: Text('Location'),
                                          prefixIcon:
                                              Icon(Icons.location_city)),
                                      initialValue: snapshot.data!.address,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
