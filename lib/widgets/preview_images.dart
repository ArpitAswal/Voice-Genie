import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../presentation/controllers/home_controller.dart';

class PreviewImages extends StatelessWidget {
  const PreviewImages({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final ctrl = Get.find<HomeController>();

    return Obx(() => (ctrl.imagesFileList.isEmpty && ctrl.filePath.isEmpty)
        ? SizedBox(
            height: width * 0.2,
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                        height: width * 0.2,
                        width: width * 0.2,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ));
                  },
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                )),
          )
        : (ctrl.imagesFileList.isNotEmpty)
            ? SizedBox(
                height: width * 0.225,
                width: double.infinity,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 4.0),
                    itemCount: ctrl.imagesFileList.length,
                    itemBuilder: (context, index) {
                      return Stack(children: [
                        Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.only(right: 6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.lightGreenAccent.shade100
                                ],
                              ),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.file(
                                  File(ctrl.imagesFileList[index]),
                                  height: width * 0.225,
                                  width: width * 0.225,
                                  fit: BoxFit.cover,
                                ))),
                        positionWidget(ctrl, index)
                      ]);
                    }))
            : Stack(children: [
                Container(
                  height: width * 0.15,
                  margin: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 4.0,
                          spreadRadius: 1.0),
                      BoxShadow(
                          color: Colors.lightGreenAccent.shade100,
                          blurRadius: 4.0,
                          spreadRadius: 0.5)
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade300,
                        Colors.lightGreenAccent.shade100
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: width * 0.01,
                      ),
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade300,
                        size: 40,
                      ),
                      Flexible(
                        child: Text(
                          ctrl.filePath.value.split('/').last.split('-').last,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Cera",
                              fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.01,
                      ),
                    ],
                  ),
                ),
                positionWidget(ctrl, null)
              ]));
  }

  Widget positionWidget(HomeController ctrl, int? index) {
    return Positioned(
        top: 0,
        right: (index == null) ? 0 : 6,
        child: InkWell(
          onTap: () {
            (ctrl.imagesFileList.isNotEmpty)
                ? ctrl.imagesFileList.removeAt(index!)
                : ctrl.filePath.value = "";
          },
          child: const CircleAvatar(
              radius: 8,
              backgroundColor: Colors.black45,
              child: Center(
                child: Icon(Icons.clear, color: Colors.white, size: 10),
              )),
        ));
  }
}
