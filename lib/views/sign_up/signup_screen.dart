import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../utils/form_error.dart';
import '../../../views/home/home_screen.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/keyboard.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = '/sign_up';

  const SignUpScreen({Key? key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _selectedGov = 'Islamabad';
  String _address = '';
  final List<String> _errors = [];
  ButtonState _stateTextWithIcon = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    AuthViewModel(FirebaseAuth.instance).AnonymousOrCurrent();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sign Up',
            style: TextStyle(
              color: SecondaryColor,
              fontSize: getProportionateScreenWidth(20),
              fontFamily: 'Panton',
            ),
          ),
          backgroundColor: SecondaryColorDark,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(22),
              ),
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenWidth(45)),
                  Text(
                    'Register Account',
                    style: TextStyle(
                      color: SecondaryColorDark,
                      fontSize: getProportionateScreenWidth(25),
                      fontFamily: 'PantonBoldItalic',
                    ),
                  ),
                  SizedBox(height: getProportionateScreenWidth(5)),
                  const Text(
                    'Fill all details to create your account',
                    style: TextStyle(fontFamily: 'Panton'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getProportionateScreenWidth(45)),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildEmailFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildPasswordFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildConfirmPassFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildFullNameFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildPhoneNumberFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Governorate:',
                              style: TextStyle(
                                fontFamily: 'PantonBoldItalic',
                                color: SecondaryColorDark,
                                fontSize: SizeConfig.screenWidth * 0.046,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0),
                                border: Border.all(
                                  color: SecondaryColorDark,
                                  width: 2.8,
                                ),
                              ),
                              child: buildGovDropdown(),
                            ),
                          ],
                        ),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildAddressFormField(),
                        SizedBox(height: getProportionateScreenHeight(20)),
                        FormError(errors: _errors),
                        SizedBox(height: getProportionateScreenHeight(20)),
                        buildTextWithIcon(),
                        SizedBox(height: getProportionateScreenHeight(35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onPressedIconWithText() async {
    setState(() {
      _stateTextWithIcon = ButtonState.loading;
    });

    bool connection =
        await InternetConnectionChecker.createInstance().hasConnection;

    if (connection == true) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        if (_formKey.currentState?.validate() ?? false) {
          _formKey.currentState?.save();
          try {
            await context.read<AuthViewModel>().signUp(
              email: _email,
              password: _password,
              fullName: _fullName,
              phoneNumber: _phoneNumber,
              governorate: _selectedGov,
              address: _address,
            );

            User? user = context.read<AuthViewModel>().CurrentUser();

            if (user != null) {
              KeyboardUtil.hideKeyboard(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            } else {
              setState(() {
                _stateTextWithIcon = ButtonState.fail;
              });
              Future.delayed(const Duration(milliseconds: 1600), () {
                if (mounted) {
                  setState(() {
                    _stateTextWithIcon = ButtonState.idle;
                  });
                }
              });
            }
          } catch (e) {
            log(e.toString());
            setState(() {
              _stateTextWithIcon = ButtonState.fail;
            });
            Future.delayed(const Duration(milliseconds: 1600), () {
              if (mounted) {
                setState(() {
                  _stateTextWithIcon = ButtonState.idle;
                });
              }
            });
          }
        } else {
          setState(() {
            _stateTextWithIcon = ButtonState.success;
          });
          Future.delayed(const Duration(milliseconds: 1600), () {
            if (mounted) {
              setState(() {
                _stateTextWithIcon = ButtonState.idle;
              });
            }
          });
        }
      });
    } else {
      setState(() {
        _stateTextWithIcon = ButtonState.fail;
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) {
          setState(() {
            _stateTextWithIcon = ButtonState.idle;
          });
        }
      });
    }
  }

  Widget buildTextWithIcon() {
    return ProgressButton.icon(
      height: getProportionateScreenWidth(58),
      maxWidth: getProportionateScreenWidth(400),
      radius: 20.0,
      textStyle: const TextStyle(
        color: Color(0xffeeecec),
        fontSize: 18,
        fontFamily: 'PantonBoldItalic',
      ),
      iconedButtons: const {
        ButtonState.idle: IconedButton(
          text: 'Continue',
          icon: Icon(Icons.add_rounded, size: 0.01, color: PrimaryColor),
          color: PrimaryColor,
        ),
        ButtonState.loading: IconedButton(text: 'Loading', color: PrimaryColor),
        ButtonState.fail: IconedButton(
          text: 'Connection Lost',
          icon: Icon(Icons.cancel, color: Colors.white),
          color: PrimaryColor,
        ),
        ButtonState.success: IconedButton(
          text: 'Invalid Input',
          icon: Icon(Icons.cancel, color: Colors.white),
          color: PrimaryColor,
        ),
      },
      onPressed: () => onPressedIconWithText(),
      state: _stateTextWithIcon,
    );
  }

  void addError({required String error}) {
    if (!_errors.contains(error)) {
      setState(() => _errors.add(error));
    }
  }

  void removeError({required String error}) {
    if (_errors.contains(error)) {
      setState(() => _errors.remove(error));
    }
  }

  // ✅ Fixed: Improved dropdown items generation
  List<DropdownMenuItem<String>> getDropdownItems() {
    return governorates.map((String gov) {
      return DropdownMenuItem<String>(value: gov, child: Text(gov));
    }).toList();
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      obscureText: true,
      onSaved: (newValue) => _password = newValue ?? '',
      onChanged: (value) {
        _password = value;
        if (value.length >= 8 || value.isEmpty) {
          removeError(error: ShortPassError);
        }
        if (passwordValidatorRegExp.hasMatch(value)) {
          removeError(error: InvalidPassError);
        }
        if (value.isNotEmpty) {
          removeError(error: PassNullError);
        }
        if (_password == _confirmPassword && _confirmPassword.isNotEmpty) {
          removeError(error: MatchPassError);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: PassNullError);
          return '';
        } else if (!passwordValidatorRegExp.hasMatch(value ?? '')) {
          addError(error: InvalidPassError);
          return '';
        } else if ((value?.length ?? 0) < 8) {
          addError(error: ShortPassError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'Password',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.lock_outline_rounded,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      obscureText: true,
      onSaved: (newValue) => _confirmPassword = newValue ?? '',
      onChanged: (value) {
        _confirmPassword = value;
        if (_password == _confirmPassword) {
          removeError(error: MatchPassError);
        }
      },
      validator: (value) {
        if (_password != value) {
          addError(error: MatchPassError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'CONFIRM Password',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.lock_outline_rounded,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => _email = newValue ?? '',
      onChanged: (value) {
        if (value.isEmpty || emailValidatorRegExp.hasMatch(value)) {
          removeError(error: InvalidEmailError);
        }
        if (value.isNotEmpty) {
          removeError(error: EmailNullError);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: EmailNullError);
          return '';
        } else if (!emailValidatorRegExp.hasMatch(value ?? '')) {
          addError(error: InvalidEmailError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'E-mail',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.email_outlined,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  TextFormField buildAddressFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      onSaved: (newValue) => _address = newValue ?? '',
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: AddressNullError);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: AddressNullError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'Address',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.location_on_outlined,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => _phoneNumber = newValue ?? '',
      onChanged: (value) {
        if (value.isEmpty || phoneNumValidatorRegExp.hasMatch(value)) {
          removeError(error: InvalidPhoneNumError);
        }
        if (value.isNotEmpty) {
          removeError(error: PhoneNumberNullError);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: PhoneNumberNullError);
          return '';
        } else if (!phoneNumValidatorRegExp.hasMatch(value ?? '')) {
          addError(error: InvalidPhoneNumError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'Phone Number',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.phone_android_outlined,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  TextFormField buildFullNameFormField() {
    return TextFormField(
      style: const TextStyle(fontWeight: FontWeight.w800),
      onSaved: (newValue) => _fullName = newValue ?? '',
      onChanged: (value) {
        if (value.isEmpty || nameValidatorRegExp.hasMatch(value)) {
          removeError(error: InvalidNameError);
        }
        if (value.isNotEmpty) {
          removeError(error: NameNullError);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: NameNullError);
          return '';
        } else if (!nameValidatorRegExp.hasMatch(value ?? '')) {
          addError(error: InvalidNameError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'PantonBold',
          color: SecondaryColorDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w100,
        ),
        labelText: 'Full Name',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
          horizontal: getProportionateScreenWidth(30),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(26)),
          child: Icon(
            Icons.person_outline_rounded,
            size: getProportionateScreenWidth(28),
            color: PrimaryColor,
          ),
        ),
      ),
    );
  }

  DropdownButton<String> buildGovDropdown() {
    return DropdownButton<String>(
      value: _selectedGov,
      items: getDropdownItems(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGov = value;
          });
        }
      },
      dropdownColor: PrimaryLightColor,
      style: const TextStyle(
        color: SecondaryColorDark,
        fontFamily: 'PantonBoldItalic',
      ),
    );
  }
}
