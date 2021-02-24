import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter with VGS Collect/Show SDK'),
    );
  }
}

typedef void CardCollectFormCallback(CardCollectFormController controller);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const COLLECT_FORM_VIEW_TYPE = 'card-collect-form-view';
const SHOW_FORM_VIEW_TYPE = 'card-show-form-view';

const CARD_TOKEN_KEY = 'cardNumber';
const DATE_TOKEN_KEY = 'expDate';

class _MyHomePageState extends State<MyHomePage> {
  CardCollectFormController collectController;
  CardShowFormController showController;

  String cardToken;
  String dateToken;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Color(0xff3c4c5d),
        ),
        body: Row(children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, top: 12.0, right: 6.0, bottom: 12.0),
              child: Column(children: <Widget>[
                Expanded(
                  child: _cardCollect(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _collectButton(),
                ),
                Text("Powered by VGS Collect SDK",
                    style:
                        TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          VerticalDivider(
            color: Color(0xff3c4c5d),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 6.0, top: 16.0, right: 12.0, bottom: 12.0),
              child: Column(children: <Widget>[
                Expanded(
                  child: _cardShow(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _showButton(),
                ),
                Text("Powered by VGS Show SDK",
                    style:
                        TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
      );
    }
    return Center(
        child: Text("iOS is not implemented, will be available soon.",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)));
  }

  Widget _cardCollect() {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    return PlatformViewLink(
      viewType: COLLECT_FORM_VIEW_TYPE,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        var platformView = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: COLLECT_FORM_VIEW_TYPE,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: StandardMessageCodec(),
        );
        platformView
            .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        platformView
            .addOnPlatformViewCreatedListener(_createCardCollectController);
        platformView.create();
        return platformView;
      },
    );
  }

  Widget _collectButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Color(0xff3c4c5d),
      child: new Text('Submit',
          style: new TextStyle(fontSize: 16.0, color: Colors.white)),
      onPressed: () {
        collectController.redactCardAsync().then((value) {
          cardToken = value.entries
              .firstWhere((element) => element.key == CARD_TOKEN_KEY)
              .value;
          dateToken = value.entries
              .firstWhere((element) => element.key == DATE_TOKEN_KEY)
              .value;
        });
      },
    );
  }

  void _createCardCollectController(int id) {
    print("View id = $id");
    collectController = new CardCollectFormController._(id);
  }

  Widget _cardShow() {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    return PlatformViewLink(
      viewType: SHOW_FORM_VIEW_TYPE,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        var platformView = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: SHOW_FORM_VIEW_TYPE,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: StandardMessageCodec(),
        );
        platformView
            .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        platformView
            .addOnPlatformViewCreatedListener(_createCardShowController);
        platformView.create();
        return platformView;
      },
    );
  }

  Widget _showButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Color(0xff3c4c5d),
      child: new Text('Reveal',
          style: new TextStyle(fontSize: 16.0, color: Colors.white)),
      onPressed: () {
        showController.revealCardAsync(cardToken, dateToken);
      },
    );
  }

  void _createCardShowController(int id) {
    print("View id = $id");
    showController = new CardShowFormController._(id);
  }
}

class CardCollectFormController {
  CardCollectFormController._(int id)
      : _channel = new MethodChannel('$COLLECT_FORM_VIEW_TYPE/$id');

  final MethodChannel _channel;

  Future<Map<dynamic, dynamic>> redactCardAsync() async {
    return await _channel.invokeMethod('redactCard', null);
  }
}

class CardShowFormController {
  CardShowFormController._(int id)
      : _channel = new MethodChannel('$SHOW_FORM_VIEW_TYPE/$id');

  final MethodChannel _channel;

  Future<void> revealCardAsync(String cardToken, String dateToken) async {
    return await _channel.invokeMethod('revealCard', [cardToken, dateToken]);
  }
}
