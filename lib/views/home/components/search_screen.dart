import 'package:easy_shop/models/Product.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';
import '../../../models/product_card.dart';
import 'package:provider/provider.dart';
import '../../../view_models/global_vars_view_model.dart';

class SearchScreen extends StatefulWidget {
  static String routeName = '/search';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> _searchList = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _performSearch();
  }

  void _performSearch() {
    final SearchKeyword args =
        ModalRoute.of(context)!.settings.arguments as SearchKeyword;
    final gv = Provider.of<GlobalVars>(context, listen: false);

    setState(() {
      _isLoading = true;
      _searchList = [];
    });

    // Search through all loaded products
    gv.AllProds.forEach((key, value) {
      for (var element in value) {
        if (element.title.toUpperCase().contains(args.keyword.toUpperCase()) ||
            (element.description?.toUpperCase().contains(
                  args.keyword.toUpperCase(),
                ) ??
                false) ||
            (element.category?.toUpperCase().contains(
                  args.keyword.toUpperCase(),
                ) ??
                false) ||
            (element.brand?.toUpperCase().contains(
                  args.keyword.toUpperCase(),
                ) ??
                false)) {
          if (!_searchList.contains(element)) {
            _searchList.add(element);
          }
        }
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchKeyword args =
        ModalRoute.of(context)!.settings.arguments as SearchKeyword;

    return Scaffold(
      backgroundColor: PrimaryLightColor,
      appBar: AppBar(
        elevation: 5,
        shadowColor: SecondaryColorDark.withValues(alpha: 0.2),
        iconTheme: const IconThemeData(color: SecondaryColorDark),
        title: Text(
          args.keyword,
          style: TextStyle(
            color: SecondaryColorDark,
            fontSize: getProportionateScreenWidth(20),
            fontWeight: FontWeight.w900,
            fontFamily: 'Panton',
          ),
        ),
        backgroundColor: CardBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PrimaryColor))
          : _searchList.isNotEmpty
          ? GridView.count(
              padding: EdgeInsets.all(getProportionateScreenWidth(25)),
              childAspectRatio: Theme.of(context).platform == TargetPlatform.iOS
                  ? MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.5)
                  : MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.35),
              crossAxisSpacing: getProportionateScreenWidth(25),
              crossAxisCount: 2,
              children: List.generate(_searchList.length, (index) {
                return ProductCard(product: _searchList[index]);
              }),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 90,
                    color: PrimaryColor,
                  ),
                  SizedBox(height: getProportionateScreenHeight(10)),
                  const Text(
                    'No Products Found',
                    style: TextStyle(
                      fontFamily: 'Panton',
                      color: SecondaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    'Try searching for "${args.keyword}" with different keywords',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Panton',
                      color: SecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SearchKeyword {
  final String keyword;
  SearchKeyword({required this.keyword});
}
