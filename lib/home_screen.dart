import 'package:flutter/material.dart';
import 'package:span_list_view/span_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> dataList = [];
  int totalSize = 500;

  bool loading = false;

  @override
  void initState() {
    addData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SpanListView")),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      dataList.clear();
                      setState(() {});
                    },
                    child: const Text("초기화")),
              ),
              SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      await addData();
                      setState(() {});
                    },
                    child: const Text("생성")),
              ),
              SizedBox(width: 24),
            ],
          ),
          Expanded(
            child: SpanListView(
              initStateFunction: () {
                print("initStatedFunction");
              },
              lineVerticalAxisAlignment: CrossAxisAlignment.start,
              horizontalSeparatorWidget: const SizedBox(width: 12),
              separatorWidget: const SizedBox(height: 12),
              itemCount: dataList.length,
              span: 10,
              fetchDataPercent: 0.9,
              lineItemExpanded: false,
              usePercentFetchData: true,
              scrollHeader: Container(
                  width: double.infinity, height: 50, color: Colors.purple),
              scrollFooter: Container(
                  width: double.infinity, height: 50, color: Colors.pink),
              pinnedHeader: const CircularProgressIndicator(color: Colors.red),
              pinnedFooter: const CircularProgressIndicator(color: Colors.blue),
              widgetBuilder: (index) {
                return item(dataList[index], index);
              },
              fetchData: () async {
                if (!loading && totalSize > dataList.length) {
                  await addData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future addData() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() => loading = true);
    });
    await Future.delayed(const Duration(milliseconds: 200), () async {})
        .then((value) {
      List<String> tempList = [];
      for (int i = 0; i < 100; i++) {
        tempList.add("데이터 : ${dataList.length + i}");
      }
      dataList.addAll(tempList);

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        loading = false;
        setState(() => loading = false);
      });
    });
  }

  Widget item(String text, int index) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey,
      width: 80,
      child: Column(
        children: [
          Text(text),
          if (index.isEven)
            Container(
              width: 70,
              height: 29,
              color: Colors.blue,
            )
        ],
      ),
    );
  }
}
