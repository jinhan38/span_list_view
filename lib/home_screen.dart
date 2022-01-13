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
  int pageNum = 0;

  SizedBox sb24 = const SizedBox(width: 24);

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
              sb24,
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      pageNum = 0;
                      if (mounted) setState(() => dataList.clear());
                    },
                    child: const Text("초기화")),
              ),
              sb24,
              Expanded(
                  child: ElevatedButton(
                      onPressed: () async => await addData(),
                      child: const Text("생성"))),
              sb24,
            ],
          ),
          Expanded(
            child: SpanListView(
              pinnedScrollFooter: false,
              initStateFunction: () {},
              lineVerticalAxisAlignment: CrossAxisAlignment.start,
              horizontalSeparatorWidget: const SizedBox(width: 12),
              separatorWidget: const SizedBox(height: 12),
              itemCount: dataList.length,
              span: 4,
              fetchDataPercent: 0.9,
              lineItemExpanded: false,
              usePercentFetchData: true,
              scrollHeader: Container(
                alignment: Alignment.center,
                width: double.infinity,
                color: Colors.deepPurpleAccent,
                height: 45,
                child: const Text(
                  "스크롤 헤더",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              scrollFooter: const CircularProgressIndicator(color: Colors.blue),
              pinnedHeader: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                child: const Text(
                  "고정 헤더",
                  style: TextStyle(fontSize: 20),
                ),
                color: Colors.pinkAccent,
              ),
              pinnedFooter: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                child: const Text(
                  "고정 푸터",
                  style: TextStyle(fontSize: 20),
                ),
                color: Colors.greenAccent,
              ),
              padding: EdgeInsets.all(12),
              widgetBuilder: (index) {
                return GestureDetector(
                  child: item(dataList[index], index),
                  onTap: () {
                    print("index : $index");
                  },
                );
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

  ///add data
  Future addData() async {
    try {
      loading = true;
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        for (int i = 0; i < 100; i++) {
          int value = (pageNum * 100) + i;
          if (value == 100) {
            dataList.add("리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트리스트");
          } else {
            dataList.add(value.toString());
          }
        }
        pageNum++;
        loading = false;
        setState(() {});
      }).onError((error, stackTrace) {
        loading = false;
      });
    } catch (e) {
      print("addData error : $e");
    }
  }

  Widget item(String text, int index) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.shade300,
      width: 80,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )),
            ],
          ),
          if (index.isEven) ...[
            Container(
              width: 80,
              height: 29,
              color: Colors.blue,
            ),
          ]
        ],
      ),
    );
  }
}
