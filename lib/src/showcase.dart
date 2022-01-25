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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:ombre_widget_package/helper/utils.dart';

import 'custom_paint.dart';
import 'get_position.dart';
import 'layout_overlays.dart';
import 'showcase_widget.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  @override
  final GlobalKey? key;

  final Widget child;
  final String? title;
  final bool isUp;
  final bool isDown;
  final double addTop;
  final String? description;
  final ShapeBorder? shapeBorder;
  final VoidCallback? onTargetClick;
  final VoidCallback? onEndTutorialClick;
  final bool? disposeOnTap;
  final bool noHole;
  final bool isEnd;
  final EdgeInsets overlayPadding;

  const Showcase(
      {required this.key,
      required this.child,
      this.title,
      required this.description,
      this.shapeBorder,
      this.onTargetClick,
      this.onEndTutorialClick,
      this.disposeOnTap,
        this.isUp = false,
        this.isDown = false,
        this.noHole = false,
        this.isEnd = false,
        this.addTop = 0,
      this.overlayPadding = EdgeInsets.zero,})
      : assert(
            onTargetClick == null
                ? true
                : (disposeOnTap == null ? false : true),
            "disposeOnTap is required if you're using onTargetClick"),
        assert(
            disposeOnTap == null
                ? true
                : (onTargetClick == null ? false : true),
            "onTargetClick is required if you're using disposeOnTap");

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  bool _showShowCase = false;
  Timer? timer;
  GetPosition? position;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    position ??= GetPosition(
      key: widget.key,
      padding: widget.overlayPadding,
      screenWidth: MediaQuery.of(context).size.width,
      screenHeight: MediaQuery.of(context).size.height,
    );
    showOverlay();
  }

  ///
  /// show overlay if there is any target widget
  ///
  void showOverlay() {
    final activeStep = ShowCaseWidget.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      if (ShowCaseWidget.of(context)!.autoPlay) {
        timer = Timer(
            Duration(
                seconds: ShowCaseWidget.of(context)!.autoPlayDelay.inSeconds),
            _nextIfAny);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      overlayBuilder: (context, rectBound, offset) {
        final size = MediaQuery.of(context).size;
        position = GetPosition(
          key: widget.key,
          padding: widget.overlayPadding,
          screenWidth: size.width,
          screenHeight: size.height,
        );
        return buildOverlayOnTarget(offset, rectBound.size, rectBound, size);
      },
      showOverlay: true,
      child: widget.child,
    );
  }

  void _nextIfAny() {
    if (timer != null && timer!.isActive) {
      if (ShowCaseWidget.of(context)!.autoPlayLockEnable) {
        return;
      }
      timer!.cancel();
    } else if (timer != null && !timer!.isActive) {
      timer = null;
    }
    ShowCaseWidget.of(context)!.completed(widget.key);
  }

  void _getOnTargetTap() {
    if (widget.disposeOnTap == true) {
      ShowCaseWidget.of(context)!.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _nextIfAny).call();
    }
  }

  void _getOnTooltipTap() {
    if(widget.onEndTutorialClick != null){
      ShowCaseWidget.of(context)!.dismiss();
      widget.onEndTutorialClick!();
    }else{
      ShowCaseWidget.of(context)!.dismiss();
    }
  }

  Widget buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) =>
      Visibility(
        visible: _showShowCase,
        maintainAnimation: true,
        maintainState: true,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _nextIfAny,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomPaint(
                  painter: ShapePainter(
                      opacity: 0.8,
                      rect: widget.noHole ? Rect.zero : position!.getRect(),
                      shapeBorder: widget.shapeBorder,
                      color: Color(hexStringToHexInt('#040303').hashCode)),
                ),
              ),
            ),
            _TargetWidget(
              offset: offset,
              size: size,
              onTap: _getOnTargetTap,
              shapeBorder: widget.shapeBorder,
            ),
            GestureDetector(
              onTap: _nextIfAny,
              child: ToolTipWidget(
                position: position,
                isUp: widget.isUp,
                isDown: widget.isDown,
                addTop: widget.addTop,
                offset: offset,
                screenSize: screenSize,
                title: widget.title,
                description: widget.description,
                onTooltipTap: _getOnTooltipTap,
                isEnd: widget.isEnd,
              ),
            ),
          ],
        ),
      );
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size? size;
  final Animation<double>? widthAnimation;
  final VoidCallback? onTap;
  final ShapeBorder? shapeBorder;

  _TargetWidget({
    Key? key,
    required this.offset,
    this.size,
    this.widthAnimation,
    this.onTap,
    this.shapeBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: onTap,
          child: Pulse(
            preferences: AnimationPreferences(
              autoPlay: AnimationPlayStates.Loop,
            ),
            child: Container(
              height: size!.height + 16,
              width: size!.width + 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white60, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
