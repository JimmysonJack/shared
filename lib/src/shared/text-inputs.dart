// ignore_for_file: constant_identifier_names

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import '../../shared_component.dart';

part 'text-inputs.g.dart';

ValueNotifier valueNotifier = ValueNotifier('');

class TextInput extends _TextInputBase with _$TextInput {
  TextInput({super.updateFields});
}

abstract class _TextInputBase with Store {
  _TextInputBase({this.updateFields});

  static const _locale = 'sw';
  static const _customKey = CustomDisplayKey();

  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  // List<Map<String, dynamic>> _values = [];

  @observable
  List<Map<String, dynamic>>? updateFields;

  @action
  setUpdateFields(List<Map<String, dynamic>>? value) {
    var list = updateFields;
    list = value;
    updateFields = list;
  }

  @observable
  List<Map<String, dynamic>> items = [];
  // @observable
  // dynamic initialValue;
  @observable
  bool _showPassword = false;

  @observable
  bool updateState = false;

  @observable
  bool _checkBoxState = false;

  @action
  setCheckBoxState(bool? value) => _checkBoxState = value ?? false;

  @observable
  bool _switchState = false;

  final Map<String, bool> _validationMap = {};
  // List<Map<String, dynamic>> _validationList = [];

  @observable
  bool hasErrors = false;

  @action
  setSwitchState(bool? value) => _switchState = value ?? false;

  Widget input(
      {required BuildContext context,
      required String label,
      WidthSize? widthSize,
      required String key,
      bool isPassword = false,
      bool isTextArea = false,
      int maxLines = 1,
      bool fixed = false,
      int minLines = 1,
      String? inputType = 'String',
      bool readOnly = false,
      bool? validate = false,
      bool show = false,
      FieldInputType? fieldInputType}) {
    checkForUpdate(key, label, fieldInputType, validate);

    return Observer(builder: (context) {
      return SizedBox(
        width: sizeSet(widthSize, context, fixed: fixed),
        child: TextFormField(
          inputFormatters: inputFormatter(fieldInputType),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (value) {},
          onChanged: (value) {
            if (fieldInputType == FieldInputType.Currency) {
              _onUpdate(key, value.replaceAll(",", ""), inputType);
            } else {
              _onUpdate(key, value, inputType);
            }
          },
          validator: (value) {
            validateErrors(key, label, fieldInputType, validate, value);
            return generalValidator(value, label, fieldInputType, validate);
          },
          obscureText: _showPassword,
          maxLines: isTextArea
              ? maxLines == 1
                  ? maxLines = 5
                  : maxLines
              : maxLines,
          minLines: isTextArea
              ? minLines == 1
                  ? 1
                  : minLines > maxLines
                      ? maxLines
                      : minLines
              : minLines > maxLines
                  ? maxLines
                  : minLines,
          readOnly: readOnly,
          initialValue: onInitialValue(updateFields, key),
          autovalidateMode: onInitialValue(updateFields, key) == null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.always,
          // contextMenuBuilder: (context,editableState){
          //   return editableState.widget.
          // },
          decoration: InputDecoration(
            border: isTextArea
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(0))
                : null,
            suffixIcon: isPassword
                ? InkWell(
                    onTap: () {
                      show = !show;
                      _showPassword = show;
                    },
                    child: Icon(!_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  )
                : null,
            prefixText: fieldInputType == FieldInputType.Currency
                ? "$_currency "
                : null,
            labelText: label,
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
        ),
      );
    });
  }

  Widget select(
      {required BuildContext context,
      required String label,
      WidthSize? widthSize,
      required String key,
      bool readOnly = false,
      bool? validate = false,
      List<Map<String, dynamic>>? items,
      bool isPageable = false,
      String Function(Map<String, dynamic>)? inFieldString,
      CustomDisplayKey customDisplayKey = _customKey,
      String? queryFields,
      String? endPointName,
      String? inputType = 'String',
      bool fixed = false,
      String? optionalResponseField,
      List<OtherParameters>? otherParameters,
      FieldInputType? fieldInputType}) {
    checkForUpdate(key, label, fieldInputType, validate);

    final size = MediaQuery.of(context).size;
    return Observer(builder: (context) {
      return SizedBox(
        width: sizeSet(widthSize, context, fixed: fixed),
        child: DropdownSearch<Map<String, dynamic>>(
          enabled: !readOnly,
          clearButtonProps: const ClearButtonProps(
            icon: Icon(Icons.close),
            isVisible: true,
            tooltip: 'Clear Field',
          ),
          autoValidateMode: onInitialValue(updateFields, key) == null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.always,
          validator: (value) {
            validateErrors(key, label, fieldInputType, validate,
                value?[customDisplayKey.titleDisplayLabelKey]);
            return generalValidator(
                value?[customDisplayKey.titleDisplayLabelKey],
                label,
                fieldInputType,
                validate);
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
              textAlignVertical: TextAlignVertical.center,
              baseStyle: const TextStyle(fontSize: 16),
              dropdownSearchDecoration: InputDecoration(
                  // contentPadding: const EdgeInsets.symmetric(
                  //     vertical: 13.5, horizontal: 10),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: null,
                  labelText: label,
                  // labelStyle: const TextStyle(locale: Locale('sw')),
                  isDense: false)),
          compareFn: (item1, item2) {
            return item1 == item2;
          },
          popupProps: PopupProps.menu(
              fit: FlexFit.loose,
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintMaxLines: 1,
                      isDense: true,
                      labelText: 'Search',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Theme.of(context).dividerColor)),
              containerBuilder: (cxt, widget) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: size.height * 0.35,
                        minHeight: size.height * 0.0,
                      ),
                      child: widget,
                    ),
                    // const Center(
                    //   child: Padding(
                    //     padding: EdgeInsets.all(8.0),
                    //     child: Text('Loading More...'),
                    //   ),
                    // )
                  ],
                );
              },
              isFilterOnline: endPointName?.isNotEmpty ?? false,
              searchDelay: Duration.zero,
              showSelectedItems: true,
              loadingBuilder: (cxt, value) {
                return IndicateProgress.circular();
              },
              itemBuilder: (cxt, Map<String, dynamic> value, isSelected) {
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Theme.of(cxt).secondaryHeaderColor,
                  title: Text(value[customDisplayKey.titleDisplayLabelKey]),
                  subtitle: customDisplayKey.subtitleDisplayLabelKey == null
                      ? null
                      : Text(value[customDisplayKey.subtitleDisplayLabelKey] ??
                          ''),
                );
              },
              scrollbarProps: ScrollbarProps(
                  interactive: true,
                  notificationPredicate: (notification) {
                    if (notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {}

                    return true;
                  }),
              menuProps: const MenuProps(
                animationDuration: Duration(milliseconds: 0),
              ),
              listViewProps: const ListViewProps(
                shrinkWrap: true,
              )),
          asyncItems: (String filter) async {
            if (isPageable) {
              final results = await GraphQLService.queryPageable(
                  context: context,
                  endPointName: endPointName ?? '',
                  parameters: otherParameters,
                  pageableParams: PageableParams(
                    searchKey: filter,
                    size: 20,
                    page: 1,
                  ),
                  responseFields: queryFields ?? '');
              return results
                  .where((element) =>
                      element[customDisplayKey.titleDisplayLabelKey]
                          .toString()
                          .toLowerCase()
                          .contains(filter.toLowerCase()))
                  .toList();
            } else {
              if (endPointName != null) {
                final results = await GraphQLService.query(
                    context: context,
                    endPointName: endPointName,
                    optionResponseFields: optionalResponseField,
                    parameters: otherParameters,
                    responseFields: queryFields ?? '');
                return results
                    .where((element) =>
                        element[customDisplayKey.titleDisplayLabelKey]
                            .toString()
                            .toLowerCase()
                            .contains(filter.toLowerCase()))
                    .toList();
              } else {
                return [];
              }
            }
          },
          items: items ?? [],
          itemAsString: inFieldString ??
              (value) => "${value[customDisplayKey.titleDisplayLabelKey]}",
          selectedItem: onInitialValue(updateFields, key),
          onChanged: (data) => _onUpdate(key, data, inputType),
        ),
      );
    });
  }

  Widget multiSelect(
      {required BuildContext context,
      required String label,
      WidthSize? widthSize,
      required String key,
      bool readOnly = false,
      bool? validate = false,
      List<Map<String, dynamic>>? items,
      bool isPageable = false,
      String Function(Map<String, dynamic>)? inFieldString,
      CustomDisplayKey customDisplayKey = _customKey,
      String? queryFields,
      String? endPointName,
      String? inputType = 'String',
      bool fixed = false,
      List<OtherParameters>? otherParameters,
      FieldInputType? fieldInputType}) {
    checkForUpdate(key, label, fieldInputType, validate);

    final size = MediaQuery.of(context).size;
    return Observer(
        name: 'MultSelect',
        builder: (context) {
          return SizedBox(
            width: sizeSet(widthSize, context, fixed: fixed),
            child: DropdownSearch<Map<String, dynamic>>.multiSelection(
              enabled: !readOnly,
              clearButtonProps: const ClearButtonProps(
                icon: Icon(Icons.close),
                isVisible: true,
                tooltip: 'Clear Field',
              ),
              autoValidateMode: onInitialValue(updateFields, key) == null
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.always,
              validator: (value) {
                validateErrors(key, label, fieldInputType, validate, value);
                return generalValidator(value, label, fieldInputType, validate);
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  baseStyle: const TextStyle(fontSize: 16),
                  dropdownSearchDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 21.5, horizontal: 10),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: null,
                      labelText: label,
                      // labelStyle: const TextStyle(locale: Locale('sw')),
                      isDense: false)),
              compareFn: (item1, item2) {
                return item1 == item2;
              },
              popupProps: PopupPropsMultiSelection.menu(
                  fit: FlexFit.loose,
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                      autofocus: true,
                      decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Search',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Theme.of(context).dividerColor)),
                  containerBuilder: (cxt, widget) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: size.height * 0.35,
                            minHeight: size.height * 0.0,
                          ),
                          child: widget,
                        ),
                        // const Center(
                        //   child: Padding(
                        //     padding: EdgeInsets.all(8.0),
                        //     child: Text('Loading More...'),
                        //   ),
                        // )
                      ],
                    );
                  },
                  isFilterOnline: endPointName?.isNotEmpty ?? false,
                  searchDelay: Duration.zero,
                  showSelectedItems: true,
                  loadingBuilder: (cxt, value) {
                    return IndicateProgress.circular();
                  },
                  itemBuilder: (cxt, Map<String, dynamic> value, isSelected) {
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: Theme.of(cxt).secondaryHeaderColor,
                      title: Text(value[customDisplayKey.titleDisplayLabelKey]),
                      subtitle: customDisplayKey.subtitleDisplayLabelKey == null
                          ? null
                          : Text(
                              value[customDisplayKey.subtitleDisplayLabelKey] ??
                                  ''),
                    );
                  },
                  scrollbarProps: ScrollbarProps(
                      interactive: true,
                      notificationPredicate: (notification) {
                        if (notification.metrics.pixels ==
                            notification.metrics.maxScrollExtent) {}
                        //TODO Implement

                        return true;
                      }),
                  menuProps: const MenuProps(
                    animationDuration: Duration(milliseconds: 0),
                  ),
                  listViewProps: const ListViewProps(
                    shrinkWrap: true,
                  )),
              asyncItems: (String filter) async {
                if (isPageable) {
                  final results = await GraphQLService.queryPageable(
                      context: context,
                      endPointName: endPointName ?? '',
                      parameters: otherParameters,
                      pageableParams: PageableParams(
                        searchKey: filter,
                        size: 20,
                        page: 1,
                      ),
                      responseFields: queryFields ?? '');
                  return results
                      .where((element) =>
                          element[customDisplayKey.titleDisplayLabelKey]
                              .toString()
                              .toLowerCase()
                              .contains(filter.toLowerCase()))
                      .toList();
                } else {
                  if (endPointName != null) {
                    final results = await GraphQLService.query(
                        context: context,
                        endPointName: endPointName,
                        parameters: otherParameters,
                        responseFields: queryFields ?? '');
                    return results
                        .where((element) =>
                            element[customDisplayKey.titleDisplayLabelKey]
                                .toString()
                                .toLowerCase()
                                .contains(filter.toLowerCase()))
                        .toList();
                  } else {
                    return [];
                  }
                }
              },
              items: items ?? [],
              itemAsString: inFieldString ??
                  (value) => "${value[customDisplayKey.titleDisplayLabelKey]}",
              selectedItems: onInitialValue(updateFields, key),
              onChanged: (data) => _onUpdate(key, data, inputType),
            ),
          );
        });
  }

  Widget date({
    required BuildContext context,
    bool disableFuture = false,
    bool disablePast = false,
    bool flowTop = false,
    bool disable = false,
    bool isDateRange = false,
    bool validate = false,
    String? inputType = 'String',
    bool fixed = false,
    WidthSize? widthSize,
    required String label,
    required String key,
  }) {
    checkForUpdate(key, label, null, validate);

    return Observer(builder: (context) {
      return SizedBox(
        width: sizeSet(widthSize, context, fixed: fixed),
        child: CustomDate(
          onSelected: (value) {
            _onUpdate(key, value.toString(), inputType);
          },
          validator: (value) {
            validateErrors(key, label, null, validate, value);
            return generalValidator(
                value, label, FieldInputType.Other, validate);
          },
          textTypeInput: TextInputType.datetime,
          disableFuture: disableFuture,
          disablePast: disablePast,
          filled: true,
          flowTop: flowTop,
          enabled: !disable,
          labelText: label,
          isDateRange: isDateRange,
          readyOnly: true,
          showDateIcon: true,
          initialValue: onInitialValue(updateFields, key),
        ),
      );
    });
  }

  Widget attachment(
      {required String label,
      WidthSize? widthSize,
      required FieldInputType fieldInputType,
      FileTypeCross? fileType,
      bool? validate,
      String? inputType = 'String',
      required String key,
      bool fixed = false,
      required BuildContext context}) {
    checkForUpdate(key, label, fieldInputType, validate);

    TextEditingController controller = TextEditingController();
    return Observer(builder: (context) {
      return SizedBox(
        width: sizeSet(widthSize, context, fixed: fixed),
        child: TextFormField(
          initialValue: onInitialValue(updateFields, key),
          onTap: () async {
            FilePickerCross result = await FilePickerCross.importFromStorage(
              type: fileType ?? FileTypeCross.any,
            );
            controller.text = result.fileName ?? '';
            _onUpdate(
                key,
                {'fileName': result.fileName, 'value': result.toBase64()},
                inputType);
          },
          readOnly: true,
          controller: controller,
          onChanged: (value) {},
          validator: (value) {
            validateErrors(key, label, fieldInputType, validate, value);
            return generalValidator(value, label, fieldInputType, validate);
          },
          decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              suffixIcon: const Icon(Icons.attach_file),
              prefixText: 'File Name: '),
        ),
      );
    });
  }

  Widget checkBox({
    required BuildContext context,
    WidthSize? widthSize,
    Function(bool?)? onChanged,
    bool fixed = false,
    String? inputType = 'Boolean',
    required String label,
    required String key,
  }) {
    checkForUpdate(key, label, null, false);

    _checkBoxState = onInitialValue(updateFields, key) ?? false;
    return Observer(builder: (context) {
      return SizedBox(
        width: widthSize != null
            ? sizeSet(widthSize, context, fixed: fixed)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                value: _checkBoxState,
                onChanged: (value) {
                  setCheckBoxState(value);
                  _onUpdate(key, value, inputType);
                  if (onChanged != null) onChanged(value);
                }),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            )
          ],
        ),
      );
    });
  }

  Widget toggle({
    required BuildContext context,
    WidthSize? widthSize,
    String? inputType = 'Boolean',
    bool fixed = false,
    Function(bool?)? onChanged,
    required String key,
  }) {
    checkForUpdate(key, null, null, false);

    _switchState = onInitialValue(updateFields, key) ?? false;
    return Observer(builder: (context) {
      return SizedBox(
        width: widthSize != null
            ? sizeSet(widthSize, context, fixed: fixed)
            : null,
        child: Switch(
            value: _switchState,
            onChanged: (value) {
              setSwitchState(value);
              _onUpdate(key, value, inputType);
              if (onChanged != null) onChanged(value);
            }),
      );
    });
  }

  Widget button(
      {required BuildContext context,
      WidthSize? widthSize,
      required String label,
      required Function()? onPressed,
      bool fixed = false,
      bool validate = true,
      Color? backgroundColor,
      IconData? icon}) {
    if (icon == null) {
      return Observer(
          warnWhenNoObservables: false,
          builder: (context) {
            return SizedBox(
              height: 40,
              width: widthSize != null
                  ? sizeSet(widthSize, context, fixed: fixed)
                  : null,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5);
                        } else if (states.contains(MaterialState.disabled)) {
                          return Theme.of(context).disabledColor;
                        }
                        return backgroundColor ??
                            Theme.of(context)
                                .primaryColor; // Use the component's default.
                      },
                    ),
                  ),
                  onPressed: validate
                      ? updateState && updateFields != null
                          ? null
                          : hasErrors
                              ? null
                              : onPressed
                      : onPressed,
                  child: Text(label)),
            );
          });
    }
    return Observer(
        warnWhenNoObservables: false,
        builder: (context) {
          return SizedBox(
            width: widthSize != null
                ? sizeSet(widthSize, context, fixed: fixed)
                : null,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5);
                    } else if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context).disabledColor;
                    }
                    return backgroundColor ??
                        Theme.of(context)
                            .primaryColor; // Use the component's default.
                  },
                ),
              ),
              onPressed: validate
                  ? updateState && updateFields != null
                      ? null
                      : hasErrors
                          ? null
                          : onPressed
                  : onPressed,
              label: Text(label),
              icon: Icon(icon),
            ),
          );
        });
  }

  _onUpdate(String key, dynamic value, String? inputType) async {
    final instanceValues = FieldValues.getInstance().instanceValues;
    final instanceMap = {for (var map in instanceValues) map.keys.first: map};
    String foundKey = instanceMap.containsKey(key) ? key : 'noKey';
    late int valueIndex;
    if ('noKey' == foundKey) {
      Map<String, dynamic> json = {key: value, 'inputType': inputType};
      FieldValues.getInstance().addValue(json);
    } else {
      valueIndex = instanceValues
          .indexWhere((rawValue) => rawValue.keys.first == foundKey);

      FieldValues.getInstance().updateValue(value, foundKey, valueIndex);
    }
    notifierValue.value = value;
  }

  double sizeSet(WidthSize? widthSize, BuildContext context,
      {bool fixed = false}) {
    final screenSize = MediaQuery.of(context).size;
    double minusValue = 20;
    if (screenSize.width <= 1045 && !fixed) {
      return screenSize.width;
    }
    switch (widthSize) {
      case null:
        return (screenSize.width * 0.5) - minusValue;
      case WidthSize.col12:
        return screenSize.width;
      case WidthSize.col10:
        return (screenSize.width * (10 / 12)) - minusValue;
      case WidthSize.col8:
        return (screenSize.width * (8 / 12)) - minusValue;
      case WidthSize.col6:
        return (screenSize.width * (6 / 12)) - minusValue;
      case WidthSize.col4:
        return (screenSize.width * (4 / 12)) - minusValue;
      case WidthSize.col2:
        return (screenSize.width * (2 / 12)) - minusValue;
      case WidthSize.col11:
        return (screenSize.width * (11 / 12)) - minusValue;
      case WidthSize.col9:
        return (screenSize.width * (9 / 12)) - minusValue;
      case WidthSize.col7:
        return (screenSize.width * (7 / 12)) - minusValue;
      case WidthSize.col5:
        return (screenSize.width * (5 / 12)) - minusValue;
      case WidthSize.col3:
        return (screenSize.width * (3 / 12)) - minusValue;
      case WidthSize.col1:
        return (screenSize.width * (1 / 12)) - minusValue;
    }
  }

  checkForUpdate(key, validateName, fieldInputType, validate) {
    validateErrors(key, validateName, fieldInputType, validate, null);
    // if (updateFields != null || updateFields!.isNotEmpty) {
    //   FieldValues.getInstance().setValue(updateFields!);
    //   // assignInitialValue(key,validateName,fieldInputType,validate);
    // }
  }

  List<TextInputFormatter> inputFormatter(FieldInputType? fieldInputType) {
    List<TextInputFormatter> list = [];
    if (fieldInputType == FieldInputType.UpperCase) {
      list.add(UpperCaseTextFormatter());
    }
    if (fieldInputType == FieldInputType.DigitOnly) {
      list.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (fieldInputType == FieldInputType.MobileNumber) {
      list.addAll([
        FilteringTextInputFormatter.digitsOnly,
        // PhoneNumberTextInputFormatter()
        LengthLimitingTextInputFormatter(10)
      ]);
    }
    if (fieldInputType == FieldInputType.Currency) {
      list.addAll([CurrencyTextInputFormatter(symbol: '', decimalDigits: 0)]);
    }
    if (fieldInputType == FieldInputType.ServiceNumber) {
      list.add(UpperCaseTextFormatter());
    }
    return list;
  }

  onInitialValue(List<Map<String, dynamic>>? dataList, String key) {
    FieldValues.getInstance().setValue(dataList);
    final dataMap = dataList?.firstWhere((data) => data.keys.first == key,
        orElse: () => <String, dynamic>{});
    return dataMap?.values.first;
  }

  // assignInitialValue(key,validateName,fieldInputType,validate) async {
  //   if (updateFields != null) {
  //     for (var element in updateFields!) {
  //       if (element.containsKey(key)) {
  //         initialValue = element[key];
  //         validateErrors(key, validateName, fieldInputType, validate,initialValue.toString());
  //       }
  //     }
  //   }
  // }

  validateErrors(key, label, fieldInputType, validate, value) {
    _register(
        key: key,
        valid:
            generalValidator(value, label, fieldInputType, validate) == null);
  }

  String? _validateServiceNumber(String? value) {
    RegExp regExp = RegExp('^(mt|MT|p|P|mtm|MTM|pw|PW)[ ]([0-9])');
    if (isInputNull(value) || value!.isEmpty) {
      return 'Service Number must be provided';
    } else if (!regExp.hasMatch(value)) {
      return 'Invalid Service Number';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    RegExp regExp = RegExp(r'^0([0-9]{9})$');
    if (isInputNull(value) || value!.isEmpty) {
      return 'Mobile Number must be provided';
    } else if (!regExp.hasMatch(value)) {
      return 'Invalid Mobile number';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (isInputNull(value) || value!.isEmpty) {
      return 'Full Name must be provided';
    }
    if (!value.contains(RegExp(
        r"[A-Z][a-zA-Z]{2,15}\s[A-Z][a-zA-Z]{2,15}\s[A-Z][a-zA-Z]{2,15}"))) {
      return "Three names starting with Capital letter are required";
    }
    return null;
  }

  String? _validateNormalFields(dynamic value, validateName) {
    if (isInputNull(value) || value.isEmpty) {
      return '$validateName must be provided';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (isInputNull(value) || value!.isEmpty) {
      return 'Email must be provided';
    }
    if (!value
        .contains(RegExp(r"[a-z0-9]{2,15}[@][a-z]{2,15}[.][a-z]{2,15}"))) {
      return 'Invalid Email provided';
    }
    return null;
  }

  String? generalValidator(dynamic value, String? validateName,
      FieldInputType? fieldInputType, bool? validate) {
    if (fieldInputType == FieldInputType.MobileNumber && validate!) {
      return _validateMobileNumber(value);
    } else if (fieldInputType == FieldInputType.FullName && validate!) {
      return _validateFullName(value);
    } else if (fieldInputType == FieldInputType.ServiceNumber && validate!) {
      return _validateServiceNumber(value);
    } else if (fieldInputType == FieldInputType.EmailAddress && validate!) {
      return _validateEmail(value);
    } else if (validate!) {
      return _validateNormalFields(value, validateName);
    }
    return null;
  }

  _register({required String key, required bool valid}) {
    _validationMap[key] = valid;
    hasErrors = _validationMap.values.any((value) => !value);
    hasError.value = hasErrors;
  }
}

enum FieldInputType {
  UpperCase,
  AttachmentField,
  AttachmentButton,
  MobileNumber,
  DigitOnly,
  Currency,
  ServiceNumber,
  FullName,
  EmailAddress,
  Other
}

enum WidthSize {
  col12,
  col11,
  col10,
  col9,
  col8,
  col7,
  col6,
  col5,
  col4,
  col3,
  col2,
  col1
}

class CustomDisplayKey {
  final String titleDisplayLabelKey;
  final String? subtitleDisplayLabelKey;
  const CustomDisplayKey(
      {this.titleDisplayLabelKey = 'name', this.subtitleDisplayLabelKey});
}

class UpdateField {
  static UpdateField? _instance;
  static getInstance() {
    if (_instance == null) {
      return _instance = UpdateField();
    }
    return _instance!;
  }

  // Box? box;
  // Future<Box> init() async {
  //   return await Hive.openBox('fieldsBox');
  // }
}

class Field {
  static TextInput? _instance;
  static List<Map<String, dynamic>> updateFieldList = [];
  static TextInput _use() {
    _instance ??= TextInput();
    return _instance!;
  }

  static clearFields() {
    _instance = null;
  }

  static TextInput get use => _use();
}

class FieldValues {
  static FieldValues? _instance;
  List<Map<String, dynamic>> _values = [];
  List<Map<String, dynamic>> _storage = [];
  static FieldValues getInstance() {
    _instance ??= FieldValues();
    return _instance!;
  }

  static void clearInstance() {
    _instance = null;
  }

  void setValue(List<Map<String, dynamic>>? value) {
    _values = value ??= [];
    _storage = value;
  }

  void addValue(dynamic value) => _values.add(value);

  List<Map<String, dynamic>> get instanceValues => _values;

  List<Map<String, dynamic>> get updateStorage => _storage;

  updateValue(dynamic value, String key, int index) {
    if (value is String && value.isEmpty || value == null) {
      _values.removeAt(index);
      return;
    }
    _values[index].update(key, (x) => value);
  }
}

ValueNotifier<bool> hasError = ValueNotifier(true);
