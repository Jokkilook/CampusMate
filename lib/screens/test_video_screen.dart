import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

//ignore: must_be_immutable
class TestVideoScreen extends StatefulWidget {
  TestVideoScreen({super.key, this.file, this.path, this.url});
  final XFile? file;
  VideoPlayerController? controller;
  bool isPortrait = true;
  bool isShow = true;
  String? path;
  String? url;

  @override
  State<TestVideoScreen> createState() => _TestVideoScreenState();
}

class _TestVideoScreenState extends State<TestVideoScreen> {
  @override
  void initState() {
    if (widget.path != null) {
      widget.controller = VideoPlayerController.file(File(widget.path!))
        ..addListener(() {
          if (widget.controller!.value.isCompleted) {
            widget.isShow = true;
          }
          setState(() {});
        })
        ..initialize().then((value) {
          widget.controller!.play();
          setState(() {});
        });
    } else if (widget.file != null) {
      widget.controller = VideoPlayerController.file(File(widget.file!.path))
        ..addListener(() {
          if (widget.controller!.value.isCompleted) {
            widget.isShow = true;
          }
          setState(() {});
        })
        ..initialize().then((value) {
          widget.controller!.play();
          setState(() {});
        });
    } else if (widget.url != null) {
      widget.controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.url!))
            ..addListener(() {
              if (widget.controller!.value.isCompleted) {
                widget.isShow = true;
              }
              setState(() {});
            })
            ..initialize().then((value) {
              widget.controller!.play();
              setState(() {});
            });
    } else {
      widget.controller = VideoPlayerController.networkUrl(Uri.parse(
          "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/20220224_171953.mp4?alt=media&token=58eec2f4-6b68-4666-b6e9-b692c44aab4b"))
        ..addListener(() {
          if (widget.controller!.value.isCompleted) {
            widget.isShow = true;
          }
          setState(() {});
        })
        ..initialize().then((value) {
          widget.controller!.play();
          setState(() {});
        });
    }

    //회전고정 해제
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
      [],
    );
    super.initState();

    Future.delayed(const Duration(seconds: 2))
        .then((value) => widget.isShow = false);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.dispose();
  }

  void setPortrait() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  void setLandscape() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  String videoTimeShower(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes % 60);
    final seconds = twoDigits(duration.inSeconds % 60);

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        //플레이어 나갈 때 다시 회전 고정
        WidgetsFlutterBinding.ensureInitialized();
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        );
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedOpacity(
            opacity: widget.isShow ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AppBar(
              iconTheme: const CupertinoIconThemeData(color: Colors.white),
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.black.withOpacity(0.7),
              shadowColor: Colors.transparent,
              toolbarOpacity: 0.7,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            widget.isShow = !widget.isShow;
            setState(() {});
          },
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                //영상 표시 부분
                widget.controller?.value.isInitialized ?? false
                    ? AspectRatio(
                        aspectRatio: widget.controller!.value.aspectRatio,
                        child: VideoPlayer(widget.controller!),
                      )
                    : const Center(child: CircularProgressIndicator()),
                //상단 뒤로가기 바
                // Positioned(
                //     left: 0,
                //     right: 0,
                //     top: 0,
                //     child: AnimatedOpacity(
                //       opacity: widget.isShow ? 1 : 0,
                //       duration: const Duration(milliseconds: 300),
                //       child: Container(
                //         alignment: Alignment.bottomLeft,
                //         height: 100,
                //         color: Colors.black.withOpacity(0.7),
                //         child: IconButton(
                //           onPressed: () {
                //             Navigator.pop(context);
                //           },
                //           icon: const Icon(
                //             Icons.arrow_back,
                //             color: Colors.white,
                //             size: 30,
                //           ),
                //         ),
                //       ),
                //     )),
                //하단 컨트롤 패널
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  //페이드인&아웃 애니메이션 추가
                  child: AnimatedOpacity(
                      opacity: widget.isShow ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            //재생 바
                            widget.controller?.value.isInitialized ?? false
                                ? SizedBox(
                                    height: 10,
                                    child: VideoProgressIndicator(
                                        widget.controller!,
                                        colors: VideoProgressColors(
                                            bufferedColor:
                                                Colors.green.withOpacity(0.2),
                                            backgroundColor:
                                                Colors.white.withOpacity(0.1),
                                            playedColor:
                                                Colors.green.withOpacity(0.9)),
                                        allowScrubbing: true),
                                  )
                                : Container(
                                    color: Colors.white.withOpacity(0.1),
                                    height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    //재생 버튼
                                    IconButton(
                                      onPressed: () {
                                        if (widget
                                                .controller?.value.isPlaying ??
                                            false) {
                                          widget.controller!.pause();
                                          setState(() {});
                                        } else {
                                          widget.controller!.play();
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                        widget.controller?.value.isPlaying ??
                                                false
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                    //볼륨 버튼
                                    IconButton(
                                      onPressed: () {
                                        if ((widget.controller?.value.volume ??
                                                0) >
                                            0) {
                                          widget.controller!.setVolume(0);
                                          setState(() {});
                                        } else {
                                          widget.controller!.setVolume(1);
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                        (widget.controller?.value.volume ?? 0) >
                                                0
                                            ? Icons.volume_up
                                            : Icons.volume_off,
                                        color: Colors.white,
                                      ),
                                    ),

                                    //재생 시간 표시
                                    widget.controller != null
                                        ? ValueListenableBuilder(
                                            valueListenable: widget.controller!,
                                            builder: (context,
                                                VideoPlayerValue value, child) {
                                              return Text(
                                                  videoTimeShower(
                                                      value.position),
                                                  style: const TextStyle(
                                                      color: Colors.white));
                                            },
                                          )
                                        : const Text(
                                            "00:00",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                    const Text(
                                      " / ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    //전체 시간 표시
                                    widget.controller != null
                                        ? Text(
                                            videoTimeShower(widget
                                                .controller!.value.duration),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )
                                        : const Text(
                                            "00:00",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ],
                                ),
                                //전체화면 버튼
                                IconButton(
                                  onPressed: () {
                                    if (widget.isPortrait) {
                                      widget.isPortrait = false;
                                      setLandscape();
                                    } else {
                                      widget.isPortrait = true;
                                      setPortrait();
                                    }
                                  },
                                  icon: Icon(
                                    widget.isPortrait
                                        ? Icons.stay_primary_landscape
                                        : Icons.stay_primary_portrait,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20)
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
