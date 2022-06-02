import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  AudioPlayer? audioPlayer;
  late AudioCache audioCache;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentPos = 0;
  int totalDuration = 0;
  bool _isFav = true;
  String track = 'track1.mp3';
  Color color = Colors.black;
  IconData icon = Icons.favorite_outline;
  void _toggleLike() {
    setState(() {
      _isFav = !_isFav;
      if (_isFav == true) {
        icon = Icons.favorite_outline;
        color = Colors.black;
      } else {
        icon = Icons.favorite;
        color = Colors.red;
      }
    });
  }

  String intToTimeLeft(int value) {
    int m, s;

    // h = ((value ~/ (1000 * 60 * 60)) % 24);

    m = ((value ~/ (1000 * 60)) % 60);

    s = (value ~/ 1000) % 60;

    // String hourLeft =
    //     h.toString().length < 2 ? "0" + h.toString() : h.toString();

    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();

    String secondsLeft = s.toString().length < 2 ? "0$s" : s.toString();

    String result = "$minuteLeft:$secondsLeft";

    return result;
  }

  int currentPosit() {
    audioPlayer!.getCurrentPosition().then(
      (value) {
        setState(() {
          currentPos = value;
        });
      },
    );
    return currentPos;
  }

  int totalDur() {
    audioPlayer!.getDuration().then(
      (value) {
        setState(() {
          totalDuration = value;
        });
      },
    );
    return totalDuration;
  }

  Future setAudio() async {
    //repeat song when completed
    audioPlayer?.setReleaseMode(ReleaseMode.STOP);
    final player = AudioCache(prefix: 'assets/');
    final url = await player.load(track);
    audioPlayer!.setUrl(url.path, isLocal: true);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      audioPlayer = AudioPlayer();
      audioCache = AudioCache(fixedPlayer: audioPlayer);
    });
    setAudio();
    super.initState();

    audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer?.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer?.onAudioPositionChanged.listen((Duration newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.white,
            Color.fromARGB(255, 223, 219, 219),
          ],
        )),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/albart.jpg'),
                      fit: BoxFit.fill,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                        blurStyle: BlurStyle.solid,
                        spreadRadius: 0.1,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Billie Jean',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'David Cook (American Idols Cover)',
                        style: TextStyle(
                            color: Color.fromARGB(255, 166, 166, 166),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  InkWell(
                      onTap: () {
                        _toggleLike();
                      },
                      child: Icon(
                        icon,
                        color: color,
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer!.seek(position);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(intToTimeLeft(currentPosit()),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                    Text(intToTimeLeft(totalDur() - currentPosit()),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 30, 70, 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          track = 'track1.mp3';
                        });
                      },
                      child: const Icon(
                        Icons.fast_rewind,
                        color: Color.fromARGB(255, 207, 207, 207),
                        size: 40,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (isPlaying) {
                          await audioPlayer?.pause();
                        } else {
                          await audioPlayer?.resume();
                        }
                      },
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xff2921bb),
                        size: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          track = 'track2.mp3';
                        });
                      },
                      child: const Icon(
                        Icons.fast_forward,
                        color: Color.fromARGB(255, 207, 207, 207),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xff21b8c1),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Live Broadcasting',
                        style: TextStyle(
                            color: Color(0xff2921bb),
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Stack(
                      children: const [
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/user1.jpg'),
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                        ),
                        Positioned(
                          right: 20,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/user3.jpg'),
                          ),
                        ),
                        Positioned(
                          right: 37,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/user2.jpg'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
