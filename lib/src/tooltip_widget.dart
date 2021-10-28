/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ombre_widget_package/button/single_button.dart';
import 'package:ombre_widget_package/button/underline_button.dart';
import 'package:ombre_widget_package/header/normal_text.dart';
import 'package:ombre_widget_package/helper/utils.dart';

import 'get_position.dart';
import 'measure_size.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final String? description;
  static late bool isArrowUp;
  final VoidCallback? onTooltipTap;

  ToolTipWidget(
      {this.position,
      this.offset,
      this.screenSize,
      this.title,
      this.description,
      this.onTooltipTap,});

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  Offset? position;

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    return (widget.screenSize!.height - position.dy) <= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  @override
  void initState() {
    super.initState();
    position = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    ToolTipWidget.isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = ToolTipWidget.isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = ToolTipWidget.isArrowUp ? setHeight(8) : 0.0;
    var paddingBottom = ToolTipWidget.isArrowUp ? 0.0 : setHeight(8);

    return Stack(
      children: <Widget>[
        Positioned(
          top: contentY,
          left: setWidth(8),
          right: setWidth(8),
          child: FractionalTranslation(
            translation: Offset(0.0, contentFractionalOffset as double),
            child: Material(
              color: Colors.transparent,
              child: Container(
                // ignore: lines_longer_than_80_chars
                padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                child: Container(
                  width: widget.screenSize!.width - 20,
                  padding: EdgeInsets.all(setHeight(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            widget.title != null
                                ? NormalText(
                              text: widget.title!,
                              fontFamily: 'PlayfairDisplay-Bold',
                              fontSize: 18,
                            ) : Container(),
                            SizedBox(height: setHeight(widget.title != null
                                ? 8 : 0),),
                            NormalText(
                              text: widget.description!,
                              fontSize: 11,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: setHeight(13),),
                      Row(
                        children: [
                          Expanded(
                            child: NormalText(
                              text: 'Press anywhere to continue',
                              fontSize: 11,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                          UnderlineButton(
                            title: 'End Tutorial',
                            fontSize: 8,
                            width: 56,
                            onPressed: widget.onTooltipTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
