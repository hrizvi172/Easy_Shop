import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants.dart';
import '../../category/category_screen.dart';
import '../../../utils/size_config.dart';
import 'package:provider/provider.dart';
import '../../../view_models/global_vars_view_model.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map DummyJSON categories to icons
    Map<String, String> categoryIcons = {
      'Beauty': 'assets/icons/tshirt.svg',
      'Fragrances': 'assets/icons/hoodie.svg',
      'Furniture': 'assets/icons/jacket_1.svg',
      'Groceries': 'assets/icons/jeans.svg',
      'Home Decoration': 'assets/icons/sneaker.svg',
      'Kitchen Accessories': 'assets/icons/tshirt.svg',
      'Laptops': 'assets/icons/hoodie.svg',
      'Mens Shirts': 'assets/icons/tshirt.svg',
      'Mens Shoes': 'assets/icons/sneaker.svg',
      'Mens Watches': 'assets/icons/jacket_1.svg',
      'Mobile Accessories': 'assets/icons/hoodie.svg',
      'Motorcycle': 'assets/icons/jeans.svg',
      'Skin Care': 'assets/icons/tshirt.svg',
      'Smartphones': 'assets/icons/hoodie.svg',
      'Sports Accessories': 'assets/icons/sneaker.svg',
      'Sunglasses': 'assets/icons/jacket_1.svg',
      'Tablets': 'assets/icons/hoodie.svg',
      'Tops': 'assets/icons/tshirt.svg',
      'Vehicle': 'assets/icons/jeans.svg',
      'Womens Bags': 'assets/icons/hoodie.svg',
      'Womens Dresses': 'assets/icons/tshirt.svg',
      'Womens Jewellery': 'assets/icons/jacket_1.svg',
      'Womens Shoes': 'assets/icons/sneaker.svg',
      'Womens Watches': 'assets/icons/jacket_1.svg',
    };

    return Consumer<GlobalVars>(
      builder: (_, gv, __) {
        // Get first 5 categories from API
        List<String> displayCategories = gv.categories.take(5).toList();

        if (displayCategories.isEmpty) {
          // Fallback to default categories if API hasn't loaded yet
          displayCategories = [
            'Beauty',
            'Fragrances',
            'Furniture',
            'Groceries',
            'Laptops',
          ];
        }

        return Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(displayCategories.length, (index) {
              String category = displayCategories[index];
              String icon =
                  categoryIcons[category] ?? 'assets/icons/tshirt.svg';

              return CategoryCard(
                icon: icon,
                text: category,
                press: () {
                  Navigator.pushNamed(
                    context,
                    CategoryScreen.routeName,
                    arguments: CategoryDetailsArguments(category: category),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: SizedBox(
        width: getProportionateScreenWidth(55),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(13)),
              height: getProportionateScreenWidth(55),
              width: getProportionateScreenWidth(55),
              decoration: BoxDecoration(
                color: PrimaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(icon, color: PrimaryColor),
            ),
            SizedBox(height: getProportionateScreenWidth(7)),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PantonBold',
                fontSize: getProportionateScreenWidth(9),
                color: SecondaryColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
