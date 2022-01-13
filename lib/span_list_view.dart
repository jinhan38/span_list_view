import 'package:flutter/material.dart';

typedef IndexedWidgetBuilder = Widget Function(int index);

class SpanListView extends StatefulWidget {
  const SpanListView({
    required this.itemCount,
    required this.span,
    required this.usePercentFetchData,
    required this.widgetBuilder,
    this.initStateFunction,
    this.separatorWidget,
    this.horizontalSeparatorWidget,
    this.fetchDataPercent = 0.8,
    this.fetchData,
    this.physics = const ScrollPhysics(),
    this.pinnedHeader,
    this.pinnedFooter,
    this.scrollHeader,
    this.scrollFooter,
    this.pinnedScrollFooter = false,
    this.shrinkWrap = true,
    this.primary = false,
    this.padding = const EdgeInsets.all(0),
    this.lineVerticalAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.lineItemExpanded = true,
    Key? key,
  })  : assert((span > 0 && span < 11),
            'span must be less than 11 and higher than 0. Current span is $span.'),
        assert((fetchDataPercent < 1.0 && fetchDataPercent > 0),
            'etchDataPercent must be less than 1.0 and higher than 0. Current fetchDataPercent is $fetchDataPercent'),
        super(key: key);

  ///If [initStateFunction] is not null, it will be called in the initState.
  final Function? initStateFunction;

  ///[itemCount] is the total count of ListView.
  final int itemCount;

  ///[span] decides how many widgets to put in one horizontal line
  ///If set to 3, Three widgets will be rendered per line.
  ///min 1, max 10
  final int span;

  ///[widgetBuilder] is a function than returns a widget.
  ///You can get current index by calling [widgetBuilder],
  ///and rendering each item widget in the ListView
  final IndexedWidgetBuilder widgetBuilder;

  ///you can add Data by calling [fetchData].
  ///When to call can be set to the values of [usePercentFetchData] and [fetchDataPercent].
  final Function? fetchData;

  ///[usePercentFetchData] decides whether to use fetchDataPercent.
  ///If usePercentFetchData is True, you will applies fetchDataPercent.
  ///Otherwise, you will call [fetchData] when the index of ListView reaches last index.
  final bool usePercentFetchData;

  ///[fetchDataPercent] is very important.
  ///fetchDataPercent determines where the data will be called additionally.
  ///If fetchDataPercent is 0.8, you will call fetchData fetchData when itemCount reaches 80 percent.
  ///For example, If itemCount is 100, you will call fetchData when index is 80.
  ///This only applies when [usePercentFetchData] is true.
  ///must be higher than 0 and less than 1
  final double fetchDataPercent;

  ///[physics] is ScrollPhysics of ListView.
  final ScrollPhysics physics;

  ///[scrollHeader] is header of ListView.
  ///Visible when the scroll reaches the top
  final Widget? scrollHeader;

  ///[scrollFooter] is footer of ListView.
  ///Visible when the scroll reaches the bottom
  final Widget? scrollFooter;

  ///If it is false, it will be shown when you call [fetchData] function.
  ///It it is true, it will be always shown.
  final bool pinnedScrollFooter;

  ///[pinnedHeader] is header of ListView.
  ///It is pinned at the top regardless of the scrolling of ListView
  final Widget? pinnedHeader;

  ///[pinnedFooter] is footer of ListView.
  ///It is pinned at the bottom regardless of the scrolling of ListView
  final Widget? pinnedFooter;

  ///[separatorWidget] is separator between vertical lines.
  ///If it is null, It is not added.
  final Widget? separatorWidget;

  ///[horizontalSeparatorWidget] is SeparatorWidget of between items of line Row Widget.
  ///If it is null, It is not added.
  final Widget? horizontalSeparatorWidget;

  ///It is shrinkWrap of ListView.
  final bool shrinkWrap;

  ///It is primary of ListView.
  final bool primary;

  ///It is padding of ListView.
  final EdgeInsets padding;

  ///[lineVerticalAxisAlignment] is CrossAxisAlignment of line Row Widget.
  ///Default is CrossAxisAlignment.center.
  final CrossAxisAlignment lineVerticalAxisAlignment;

  ///[mainAxisAlignment] is MainAxisAlignment of line Row Widget.
  ///Default is MainAxisAlignment.spaceEvenly.
  final MainAxisAlignment mainAxisAlignment;

  ///Default of [lineItemExpanded] is true.
  ///If it is true,parent of items inside line Row Widget is Expanded Widget.
  ///Otherwise, parent of items is Flexible and flex is one.
  final bool lineItemExpanded;

  @override
  _SpanListViewState createState() => _SpanListViewState();
}

class _SpanListViewState extends State<SpanListView> {
  ///If you are adding data, [fetchingData] will be true and [widget.scrollFooter] will be shown.
  ///If you are not adding data, [fetchingData] will be false and [widget.scrollFooter] will be hidden.
  bool fetchingData = false;

  @override
  void initState() {
    if (widget.initStateFunction != null) {
      widget.initStateFunction!();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// If pinnedHeader and pinnedFooter are both null, return only ListView.
    /// If pinnedHeader or pinnedFooter is not null,
    /// put pinnedHeader and pinnedFooter at the top and bottom of ListView, after wrapping ListView with Column.

    if (widget.itemCount == 0) {
      return const SizedBox();
    } else {
      if (widget.pinnedHeader == null || widget.pinnedFooter == null) {
        return _listViewWidget();
      } else {
        return Column(
          children: [
            if (widget.pinnedHeader != null) ...[widget.pinnedHeader!],
            Expanded(child: _listViewWidget()),
            if (widget.pinnedFooter != null) ...[widget.pinnedFooter!],
          ],
        );
      }
    }
  }

  ///ListView Widget
  Widget _listViewWidget() {
    int _itemCount =
        _calcItemCount(itemCount: widget.itemCount, span: widget.span);
    return ListView.separated(
      itemCount: _itemCount,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      primary: widget.primary,
      physics: widget.physics,
      itemBuilder: (context, index) {
        _fetchData(
            usePercentFetchData: widget.usePercentFetchData,
            itemCount: _itemCount,
            currentIndex: index,
            fetchDataPercent: widget.fetchDataPercent,
            fetchData: widget.fetchData);

        List<int> itemIndexList = _calcDataListItemIndex(
            currentIndex: index,
            span: widget.span,
            itemCount: widget.itemCount);

        Widget listItemLine = _listItemLine(
            widgetBuilder: (index) => widget.widgetBuilder(index),
            span: widget.span,
            itemIndexList: itemIndexList,
            horizontalSeparatorWidget: widget.horizontalSeparatorWidget,
            lineVerticalAxisAlignment: widget.lineVerticalAxisAlignment,
            mainAxisAlignment: widget.mainAxisAlignment);

        if (index == 0) {
          return scrollHeaderWidget(
              listItemLine: listItemLine, scrollHeader: widget.scrollHeader);
        } else if (index == _itemCount - 1) {
          return scrollFooterWidget(
              listItemLine: listItemLine,
              scrollFooter: widget.scrollFooter,
              fetchingData: fetchingData);
        } else {
          return listItemLine;
        }
      },
      separatorBuilder: (context, index) {
        return widget.separatorWidget ?? const SizedBox();
      },
    );
  }

  ///If [scrollHeader] is null, return only [listItemLine].
  ///But [scrollHeader] not null, return [listItemLine] with scrollHeaderWidget.
  Widget scrollHeaderWidget({
    required Widget listItemLine,
    required Widget? scrollHeader,
  }) {
    if (scrollHeader == null) {
      return listItemLine;
    } else {
      return _listItemLineWithHeader(scrollHeader, listItemLine);
    }
  }

  ///It can be shown, when you are fetching data.
  ///If [scrollFooter] is null, return only [listItemLine].
  ///If value of fetchingData is false, return only [listItemLine].
  ///But [scrollFooter] not null, return [listItemLine] with scrollFooterWidget.
  Widget scrollFooterWidget({
    required Widget listItemLine,
    required Widget? scrollFooter,
    required bool fetchingData,
  }) {
    if (scrollFooter == null) {
      return listItemLine;
    } else if (!fetchingData && !widget.pinnedScrollFooter) {
      return listItemLine;
    } else {
      return _listItemLineWithFooter(scrollFooter, listItemLine);
    }
  }

  ///[_calcItemCount] is a function that finds itemCount of ListView.
  ///It is not the count of dataList
  ///If span is one, returns itemCount as is without calculation.
  ///But span is higher one, itemCount must be calculated considering span.
  int _calcItemCount({required int itemCount, required int span}) {
    if (span == 1) {
      return itemCount;
    } else {
      return (itemCount / span).ceil();
    }
  }

  ///This function is used for getting the index of dataList.
  ///If span one or zero, return currentIndex.
  ///But If span is higher one, need more calculation
  ///currentIndex is index of ListView. In other word, it is line index.
  ///So, you can get the index of current dataList by multiplying [currentIndex] and [span].
  ///With the index just obtained, run the for loop and store the index as much as span
  List<int> _calcDataListItemIndex(
      {required int currentIndex, required int span, required int itemCount}) {
    List<int> itemIndexList = [];
    if (span == 1) {
      itemIndexList.add(currentIndex);
    } else {
      int index = currentIndex * span;
      int count = 0;
      for (int i = 0; i < span; i++) {
        int tempIndex = index + count;
        if (tempIndex < itemCount) itemIndexList.add(tempIndex);
        count++;
      }
    }
    return itemIndexList;
  }

  ///If will be called when [widget.scrollHeader] is not null.
  Widget _listItemLineWithHeader(Widget scrollHeader, Widget listItemLine) {
    return Column(
      children: [
        scrollHeader,
        listItemLine,
      ],
    );
  }

  ///If will be called when [widget.scrollFooter] is not null.
  Widget _listItemLineWithFooter(Widget scrollFooter, Widget listItemLine) {
    return Column(
      children: [
        listItemLine,
        scrollFooter,
      ],
    );
  }

  ///one line Widget
  ///you can set Alignment by using values of [lineVerticalAxisAlignment], [mainAxisAlignment], and [widget.lineItemExpanded].
  ///If [horizontalSeparatorWidget] is not null, could put [widget.separatorWidget].
  Widget _listItemLine({
    required IndexedWidgetBuilder widgetBuilder,
    required int span,
    required List<int> itemIndexList,
    required Widget? horizontalSeparatorWidget,
    required CrossAxisAlignment lineVerticalAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
  }) {
    return Row(
      crossAxisAlignment: lineVerticalAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (int i = 0; i < itemIndexList.length; i++) ...[
          if (widget.lineItemExpanded) ...[
            Expanded(child: widgetBuilder(itemIndexList[i])),
          ] else ...[
            Flexible(flex: 1, child: widgetBuilder(itemIndexList[i])),
          ],
          if (horizontalSeparatorWidget != null &&
              i < itemIndexList.length - 1) ...[horizontalSeparatorWidget],
        ],
      ],
    );
  }

  ///It can be called when [fetchData] is not null.
  ///If [usePercentFetchData] will be True, decides when to call fetchData by using [fetchDataPercent].
  ///Otherwise, It will be called when currentIndex reaches last index.
  Future<void> _fetchData({
    required bool usePercentFetchData,
    required int itemCount,
    required int currentIndex,
    required double fetchDataPercent,
    required Function? fetchData,
  }) async {
    try {
      if (fetchData != null) {
        if (usePercentFetchData) {
          if (currentIndex == (itemCount * fetchDataPercent).floor()) {
            fetchingData = true;
            await fetchData();
            fetchingData = false;
          }
        } else {
          if (currentIndex == itemCount - 1) {
            fetchingData = true;
            await fetchData();
            fetchingData = false;
          }
        }
      }
    } catch (e) {
      print("_fetchData error : $e");
    }
  }
}
