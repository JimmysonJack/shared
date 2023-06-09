// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_component/shared_component.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class CustomDate extends StatefulWidget {
  const CustomDate({
    Key? key,
    this.onTap,
    this.initialValue,
    this.validator,
    this.enabled,
    this.readyOnly,
    this.labelText,
    this.borderRadius,
    this.focusBorder,
    this.textTypeInput,
    this.showDateIcon = false,
    this.filled = false,
    this.flowTop = false,
    this.isDateRange = false,
    required this.onSelected,
    this.disableFuture = false,
    this.disablePast = false,
  }) : super(key: key);
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool? enabled;
  final bool? readyOnly;
  final String? labelText;
  final double? borderRadius;
  final double? focusBorder;
  final TextInputType? textTypeInput;
  final bool showDateIcon;
  final bool filled;
  final bool flowTop;
  final bool isDateRange;
  final bool disableFuture;
  final bool disablePast;
  final String? initialValue;
  final Function(String) onSelected;

  @override
  _CustomDateState createState() => _CustomDateState();
}

class _CustomDateState extends State<CustomDate> {
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool sourceFocused = false;
  final FocusNode _focus = FocusNode();
  late double height;
  DateRangePickerController controller = DateRangePickerController();
  TextEditingController textController = TextEditingController();
  @override
  void initState() {
    if (widget.initialValue != null) textController.text = widget.initialValue!;
    _focus.addListener(() {
      setState(() {
        sourceFocused = _focus.hasFocus;
      });
      if (sourceFocused) {
        _overlayEntry = _createOverlay();
        Overlay.of(context).insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });

    super.initState();
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final FocusScopeNode scopeNode = FocusScope.of(context);
    return OverlayEntry(
        builder: (context) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScopeNode scopeNode = FocusScope.of(context);

                if (scopeNode.hasFocus) scopeNode.unfocus();
              },
              child: Stack(
                children: [
                  Positioned(
                      left: offset.dx,
                      width: size.width,
                      height: 300,
                      child: CompositedTransformFollower(
                          offset: Offset(0, size.height),
                          showWhenUnlinked: true,
                          followerAnchor: widget.flowTop
                              ? Alignment.bottomLeft
                              : Alignment.topLeft,
                          // targetAnchor: Alignment.topCenter,
                          link: _layerLink,
                          child: Card(
                            elevation: 5,
                            color: Theme.of(context).cardColor,
                            child: SfDateRangePicker(
                              // showActionButtons: true,
                              showNavigationArrow: true,
                              onCancel: () {
                                setState(() {
                                  _range = '';
                                  _selectedDate = '';
                                  _rangeCount = '';
                                  _dateCount = '';
                                });
                                scopeNode.unfocus();
                              },
                              onSubmit: (data) {
                                if (widget.isDateRange) {
                                  if (_range.isEmpty) {
                                    NotificationService.snackBarError(
                                      context: context,
                                      title:
                                          'Date ${widget.isDateRange ? 'Range' : ''} is not Selected',
                                    );
                                  } else {
                                    scopeNode.unfocus();
                                  }
                                } else {
                                  if (_selectedDate.isEmpty) {
                                    NotificationService.snackBarError(
                                      context: context,
                                      title:
                                          'Date ${widget.isDateRange ? 'Range' : ''} is not Selected',
                                    );
                                  } else {
                                    scopeNode.unfocus();
                                  }
                                }
                              },
                              // cancelText: 'Cancel',
                              // confirmText: 'Ok',
                              // enablePastDates: false,
                              maxDate:
                                  widget.disableFuture ? DateTime.now() : null,
                              minDate:
                                  widget.disablePast ? DateTime.now() : null,
                              controller: controller,
                              onSelectionChanged: onSelectionChanged,
                              selectionMode: widget.isDateRange
                                  ? DateRangePickerSelectionMode.range
                                  : DateRangePickerSelectionMode.single,
                              initialSelectedRange: PickerDateRange(
                                DateTime.now(),
                                DateTime.now(),
                              ),
                            ),
                          ))),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height / 2.5;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        focusNode: _focus,
        controller: textController,
        autovalidateMode: widget.initialValue == null
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.always,
        // initialValue: widget.initialValue,
        decoration: InputDecoration(
            suffixIcon: const Icon(Icons.date_range),
            labelText: widget.labelText,
            filled: widget.filled,
            fillColor: Theme.of(context).cardColor),
        onTap: widget.onTap ??
            () {
              setState(() {
                sourceFocused = true;
              });
            },
        textInputAction: TextInputAction.next,
        enabled: widget.enabled ?? true,
        readOnly: widget.readyOnly!,
        validator: widget.validator ?? (value) => null,
        keyboardType: widget.textTypeInput ?? TextInputType.text,
      ),
    );
  }

  onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final FocusScopeNode scopeNode = FocusScope.of(context);
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            '${DateFormat('yyy-MM-dd').format(args.value.startDate)} -- ${DateFormat('yyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';
        widget.onSelected(_range);
        textController.text = _range;
      } else if (args.value is DateTime) {
        _selectedDate = DateFormat('yyy-MM-dd').format(args.value).toString();
        widget.onSelected(_selectedDate);
        textController.text = _selectedDate;
        if (sourceFocused) scopeNode.unfocus();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.lenght.toString();
        widget.onSelected(_dateCount);
        textController.text = _dateCount;
      } else {
        _rangeCount = args.value.length.toString();
        widget.onSelected(_rangeCount);
        textController.text = _rangeCount;
      }
    });
  }
}
