import 'package:flutter/material.dart';
import '../models/product_card.dart';
import '../views/category/category_screen.dart';
import '../utils/size_config.dart';
import '../views/home/components/section_title.dart';
import 'package:provider/provider.dart';
import '../view_models/global_vars_view_model.dart';

class Category extends StatelessWidget {
  final String cat;

  const Category({Key? key, required this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalVars>(
      builder: (_, gv, __) {
        final products = gv.AllProds[cat] ?? [];

        // Don't show category if it has no products
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(height: getProportionateScreenWidth(20)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
              ),
              child: SectionTitle(
                title: cat,
                press: () {
                  Navigator.pushNamed(
                    context,
                    CategoryScreen.routeName,
                    arguments: CategoryDetailsArguments(category: cat),
                  );
                },
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(8)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(products.length < 5 ? products.length : 5, (
                    index,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ProductCard(product: products[index]),
                    );
                  }),
                  SizedBox(width: getProportionateScreenWidth(20)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
