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

    return Obx(() => (ctrl.imagesFileList.isEmpty)
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
        : SizedBox(
            height: width * 0.2,
            width: double.infinity,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ctrl.imagesFileList.length,
                itemBuilder: (context, index) {
                  return Stack(children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          File(ctrl.imagesFileList[index]),
                          height: width * 0.2,
                          width: width * 0.2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 6,
                        child: InkWell(
                          onTap: () {
                            ctrl.imagesFileList.removeAt(index);
                          },
                          child: const CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.black45,
                              child: Center(
                                child: Icon(Icons.clear,
                                    color: Colors.white, size: 10),
                              )),
                        )),
                  ]);
                })));
  }
}
