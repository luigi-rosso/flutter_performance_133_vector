import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

abstract class ProceduralShapeRenderer {
  void advance(double elapsed);
  void render(Size size, Offset offset, Canvas canvas);
}

class AnimatedProceduralShape extends LeafRenderObjectWidget {
  final ProceduralShapeRenderer renderer;
  const AnimatedProceduralShape({this.renderer});
  @override
  RenderObject createRenderObject(BuildContext context) {
    return ProceduralShapeRenderBox()..renderer = renderer;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ProceduralShapeRenderBox renderObject) {
    renderObject.renderer = renderer;
  }

  @override
  void didUnmountRenderObject(covariant ProceduralShapeRenderBox renderObject) {
    renderObject.dispose();
  }
}

class ProceduralShapeRenderBox extends RenderBox {
  ProceduralShapeRenderer renderer;
  int _frameCallbackID;
  double _lastFrameTime = 0.0;

  void updatePlayState() {
    if (attached) {
      markNeedsPaint();
    } else {
      _lastFrameTime = 0;
      if (_frameCallbackID != null) {
        SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackID);
      }
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    updatePlayState();
  }

  @override
  void detach() {
    super.detach();
    dispose();
  }

  void dispose() {
    updatePlayState();
  }

  void _beginFrame(Duration timestamp) {
    _frameCallbackID = null;
    final double t =
        timestamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    double elapsedSeconds = _lastFrameTime == 0.0 ? 0.0 : t - _lastFrameTime;
    _lastFrameTime = t;

    renderer?.advance(elapsedSeconds);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint again
    if (_frameCallbackID != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackID);
    }
    _frameCallbackID =
        SchedulerBinding.instance.scheduleFrameCallback(_beginFrame);
    renderer?.render(size, offset, context.canvas);
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset screenOffset) => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }
}
