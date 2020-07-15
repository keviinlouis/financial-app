import 'package:carousel_slider/carousel_slider.dart';
import 'package:financialapp/locale/locale_keys.dart';
import 'package:financialapp/models/user_model.dart';
import 'package:financialapp/pages/settings/settings_second_step_page.dart';
import 'package:financialapp/shared/base_button.dart';
import 'package:financialapp/shared/layout/base_back_button_page.dart';
import 'package:financialapp/shared/typography/display2_text.dart';
import 'package:financialapp/shared/typography/subtitle_text.dart';
import 'package:financialapp/states/auth_state.dart';
import 'package:financialapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController controller;
  UserConfig userConfig = UserConfig.empty();

  @override
  void initState() {
    controller = TextEditingController();

    controller.addListener(validateInput);

    var authState = Provider.of<AuthState>(context, listen: false);

    print(authState.logged);

    if (authState.user?.config != null) {
      userConfig = authState.user.config;
      controller.text = userConfig.day.toString();
    }
    super.initState();
  }

  void selectDayTypeOption(int value) {
    userConfig.dayType = value == 0 ? DayType.workDay : DayType.allDays;
    setState(() {});
    validateInput();
  }

  void validateInput() {
    int value = int.tryParse(controller.text);

    if (value == null) return;

    if (value < 1) {
      controller.clear();
    } else if (userConfig.dayType == DayType.workDay && value > 20) {
      controller.clear();
    } else if (userConfig.dayType == DayType.allDays && value > 31) {
      controller.clear();
    } else {
      userConfig.day = value;
    }

    setState(() {});
  }

  void nextPage() {
    int day = int.tryParse(controller.text);
    if (day == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsSecondStepPage(userConfig: userConfig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseBackButtonPage(
      titleKey: SettingsPageTextKeys.firstTitle,
      content: <Widget>[
        SubtitleText.key(
          SettingsPageTextKeys.firstSubtitle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: buildDayField(),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: buildDayTypeSelector(),
            ),
          ],
        ),
      ],
      bottom: BaseButton(
        textKey: SettingsPageTextKeys.btnNext,
        onPressed: nextPage,
      ),
    );
  }

  Widget buildDayField() {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.display2,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        suffixText: 'ᵒ',
        suffixStyle: Theme.of(context).textTheme.display2,
        fillColor: DefaultColors.backgroundColor,
      ),
    );
  }

  Widget buildDayTypeSelector() {
    return CarouselSlider(
      items: [
        buildDayTypeOption(
            SettingsPageTextKeys.selectionWorkDay, DayType.workDay),
        buildDayTypeOption(
            SettingsPageTextKeys.selectionAllDays, DayType.allDays),
      ],
      options: CarouselOptions(
        viewportFraction: 0.2,
        height: 200,
        aspectRatio: 16 / 7,
        initialPage: 0,
        enableInfiniteScroll: false,
        onPageChanged: (value, _) => selectDayTypeOption(value),
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget buildDayTypeOption(String titleKey, DayType value) {
    Color color = value == userConfig.dayType
        ? Colors.white
        : DefaultColors.subtitleColor;
    return Display2Text.key(
      titleKey,
      textColor: color,
    );
  }
}