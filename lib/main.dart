// import 'package:icons_launcher/cli_commands.dart';
// import 'package:icons_launcher/utils/cli_logger.dart';
// import 'package:icons_launcher/utils/constants.dart';
// import 'package:icons_launcher/utils/flavor_helper.dart';
// import 'package:icons_launcher/utils/icon.dart';
// import 'package:icons_launcher/utils/template.dart';
// import 'package:icons_launcher/utils/utils.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_again/english_words.dart';
import 'package:fsrs/fsrs.dart' as f;
import 'package:flutter_reactive_value/flutter_reactive_value.dart'; // state nem mentett
// import 'package:translator/translator.dart';
import 'package:hive_again/enhuDictionary.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // válasz ikonok
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_persistent_value_notifier/flutter_persistent_value_notifier.dart'; // state mentett
import 'package:hive_again/animation_thingy.dart';
import 'package:url_launcher/url_launcher.dart'; // url-ek megnyitásához .. tádáá
import 'package:flutter_tts/flutter_tts.dart';

final showBudges = PersistentValueNotifier<bool>(
  sharedPreferencesKey: 'showBudges',
  initialValue: false,
);


// var targetLanguage = "en";
// var sourceLanguage = "hu";

var currentWord = ReactiveValueNotifier("");
var currentMeaning = ReactiveValueNotifier("");

var front = ReactiveValueNotifier("");
var back = ReactiveValueNotifier("");

var mode; // active or passive

var meaningBox;
var passiveCardsBox;
var activeCardsBox;
var passiveDueBox;
var activeDueBox;
var passiveStateBox;
var activeStateBox;

var newStateCountPassive = ReactiveValueNotifier(0);
var learningCountPassive = ReactiveValueNotifier(0);
var reviewCountPassive = ReactiveValueNotifier(0);
var relearningCountPassive = ReactiveValueNotifier(0);

var newStateCountActive = ReactiveValueNotifier(0);
var learningCountActive = ReactiveValueNotifier(0);
var reviewCountActive = ReactiveValueNotifier(0);
var relearningCountActive = ReactiveValueNotifier(0);

var dueCountPassive = ReactiveValueNotifier(0);
var laterCountPassive = ReactiveValueNotifier(0);
var dueCountActive = ReactiveValueNotifier(0);
var laterCountActive = ReactiveValueNotifier(0);

var currentDue = ReactiveValueNotifier(0);

var fsrs = f.FSRS();
var card = f.Card();
var now = DateTime.now();
// print("Now: $now");
var schedulingCards = fsrs.repeat(card, now);

var flutterTts = FlutterTts();

// final translator = GoogleTranslator();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ez nem tudom mit csinál de nyafogott nélküle

  await initPersistentValueNotifier(prefix: 'io.github.nameweird.angolmag');  // A unique SharedPreferences prefix for your app


// var engines = await glFlutterTts.getEngines;

  // Web: a böngészőben nincs Android TTS motor, ezért ott kihagyjuk.
  try {
    if (!kIsWeb) await flutterTts.setEngine("com.google.android.tts");
    await flutterTts.setLanguage("en-US");
    await flutterTts.awaitSpeakCompletion(true);
  } catch (e) {
    // TTS nem elérhető ezen a platformon
  }

  await Hive.initFlutter();

  meaningBox = await Hive.openBox('meaningBox');
  passiveCardsBox = await Hive.openBox('passiveCardsBox');
  activeCardsBox = await Hive.openBox('activeCardsBox');
  passiveDueBox = await Hive.openBox('passiveDueBox');
  activeDueBox = await Hive.openBox('activeDueBox');
  passiveStateBox = await Hive.openBox('passiveStateBox');
  activeStateBox = await Hive.openBox('activeStateBox');

  await meaningBox.clear();

  // if (await meaningBox.length == 0) {
  //   for (var e in enhuDictionary.keys) {
  //     await meaningBox.put(e, enhuDictionary[e]);
  //   }
  // }

  // Egyben írjuk be (webes IndexedDB-n soronként nagyon lassú lenne).
  await meaningBox.putAll(enhuDictionary);

  // print(await meaningBox.length);

  // await passiveCardsBox.clear();
  // await passiveDueBox.clear();
  // await activeCardsBox.clear();
  // await activeDueBox.clear();
  // await passiveStateBox.clear();
  // await activeStateBox.clear();

  // print("passiveCardsBox.length: ${passiveCardsBox.length}");

  // // adunk +5öt a passzívhoz
  // await plusFivePassive();

  // // kövi kari
  // await nextPassiveCard();

  // // reviewolunk egyet
  // await reviewPassive("again");

  // // stats betöltése
  await getStatsAll();
  // print(dueCountPassive.value);
  // print(laterCountPassive.value);
  // await plusFivePassive();
  // await nextPassiveCard();
  // print("${currentWord.value} ${currentMeaning.value}");

  runApp(MaterialApp(
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        color: Colors.amberAccent,
      ),
      scaffoldBackgroundColor: Colors.amber,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.amber,
      ),
      brightness: Brightness.light,
      /* light theme settings */
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      /* dark theme settings */
    ),
    // themeMode: darkMode.value,
    themeMode: ThemeMode.system,
    /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
    debugShowCheckedModeBanner: false,
    title: 'AngolMag',
    home: HomeRoute(),
  ));
}

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Passzív szókincs', style: TextStyle(fontSize: 26)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'új státuszú: ${newStateCountPassive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'tanulás alatt: ${learningCountPassive.reactiveValue(context)}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'átnéznivaló: ${reviewCountPassive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'újra tanulás alatt: ${relearningCountPassive.reactiveValue(context)}'),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'esedékes: ${dueCountPassive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'később: ${laterCountPassive.reactiveValue(context)}'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          child: FaIcon(FontAwesomeIcons.dumbbell),
                          onPressed: () async {
                            mode = "passive";
                            if (dueCountPassive.value == 0) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Ó jaj!"),
                                      content:
                                          Text("Nincs esedékes átnéznivaló..."),
                                    );
                                  });
                            } else {
                              await nextPassiveCard();
                              await getStatsAll();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ReviewRoute()),
                              );
                            }
                          },
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "passive";
                            await plusFivePassive();
                            await nextPassiveCard();
                            await getStatsAll();
                          },
                          child: Text('+5'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "passive";
                            await plusFivePassive();
                            await plusFivePassive();
                            await nextPassiveCard();
                            await getStatsAll();
                          },
                          child: Text('+10'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "passive";
                            await plusFivePassive();
                            await plusFivePassive();
                            await plusFivePassive();
                            await plusFivePassive();
                            await nextPassiveCard();
                            await getStatsAll();
                          },
                          child: Text('+20'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Aktív szókincs', style: TextStyle(fontSize: 26)),
                    // Text(
                    //     '${statsPassiveState.value.due} ${statsPassiveState.value.later} ${statsPassiveState.value.learning} ${statsPassiveState.value.overdue}'),
                    // Text(statsActiveState.value.toString()), // nem kell
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'új státuszú: ${newStateCountActive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'tanulás alatt: ${learningCountActive.reactiveValue(context)}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'átnéznivaló: ${reviewCountActive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'újra tanulás alatt: ${relearningCountActive.reactiveValue(context)}'),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'esedékes: ${dueCountActive.reactiveValue(context)}'),
                            Text('  '),
                            Text(
                                'később: ${laterCountActive.reactiveValue(context)}'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          child: FaIcon(FontAwesomeIcons.dumbbell),
                          onPressed: () async {
                            await getStatsAll();
                            if (dueCountActive.value == 0) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Ó jaj!"),
                                      content:
                                          Text("Nincs esedékes átnéznivaló..."),
                                    );
                                  });
                            } else {
                              mode = "active";
                              await nextActiveCard();
                              await getStatsAll();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ReviewRoute()),
                              );
                            }
                          },
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "active";
                            await plusFiveActive();
                            await nextActiveCard();
                            await getStatsAll();
                          },
                          child: Text('+5'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "active";
                            await plusFiveActive();
                            await plusFiveActive();
                            await nextActiveCard();
                            await getStatsAll();
                          },
                          child: Text('+10'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewRoute()),
                            );
                            front.value = "";
                            back.value = "";
                            mode = "active";
                            await plusFiveActive();
                            await plusFiveActive();
                            await plusFiveActive();
                            await plusFiveActive();
                            await nextActiveCard();
                            await getStatsAll();
                          },
                          child: Text('+20'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // stats frissítés...
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () async {
                        await getStatsAll();
                        const snackBar = SnackBar(
                          content: Text('Statisztikák frissítve'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      icon: FaIcon(FontAwesomeIcons.arrowsRotate)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewRoute extends StatelessWidget {
  const ReviewRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${currentDue.reactiveValue(context) - 1}"),
      ),
      endDrawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(value: showBudges.value, onChanged: (bool value) {showBudges.value = false;} )
          ],
        ), // Populate the Drawer in the next step.
      ),
      body: Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${front.reactiveValue(context)}",
                          style: TextStyle(fontSize: 30),
                        ),
                      ]),
                ),
                // Divider(),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimationThingy(
                          text: "${back.reactiveValue(context)}") // IconButton(
                    ],
                  ),
                ),
                // Divider(),
                // Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Badge(
                      isLabelVisible: showBudges.value,
                      backgroundColor: Colors.blue,
                      offset: Offset(-10, -5),
                      label: Text('újra'),
                      child: IconButton(
                        onPressed: () async {
                          if (mode == "passive") {
                            await reviewPassive("again");
                            await getStatsAll();
                            if (dueCountPassive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextPassiveCard();
                            }
                          } else if (mode == "active") {
                            await reviewActive("again");
                            await getStatsAll();
                            if (dueCountActive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextActiveCard();
                            }
                          }
                        },
                        icon: FaIcon(FontAwesomeIcons.faceSadCry),
                        iconSize: 45,
                        color: Colors.blue,
                      ),
                    ),
                    Badge(
                      isLabelVisible: showBudges.value,
                      backgroundColor: Colors.blue,
                      offset: Offset(-10, -5),
                      label: Text('nehéz'),
                      child: IconButton(
                        onPressed: () async {
                          if (mode == "passive") {
                            await reviewPassive("hard");
                            await getStatsAll();
                            if (dueCountPassive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextPassiveCard();
                            }
                          } else if (mode == "active") {
                            await reviewActive("hard");
                            await getStatsAll();
                            if (dueCountActive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextActiveCard();
                            }
                          }
                        },
                        icon: FaIcon(FontAwesomeIcons.faceRollingEyes),
                        iconSize: 45,
                        color: Colors.green,
                      ),
                    ),
                    Badge(
                      isLabelVisible: showBudges.value,
                      backgroundColor: Colors.blue,
                      offset: Offset(-10, -5),
                      label: Text('jó'),
                      child: IconButton(
                        onPressed: () async {
                          if (mode == "passive") {
                            await reviewPassive("good");
                            await getStatsAll();
                            if (dueCountPassive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextPassiveCard();
                            }
                          } else if (mode == "active") {
                            await reviewActive("good");
                            await getStatsAll();
                            if (dueCountActive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextActiveCard();
                            }
                          }
                        },
                        icon: FaIcon(FontAwesomeIcons.faceSmileBeam),
                        iconSize: 45,
                        color: Colors.orange,
                      ),
                    ),
                    Badge(
                      isLabelVisible: showBudges.value,
                      backgroundColor: Colors.blue,
                      offset: Offset(-10, -5),
                      label: Text('könnyű'),
                      child: IconButton(
                        onPressed: () async {
                          if (mode == "passive") {
                            await reviewPassive("easy");
                            await getStatsAll();
                            if (dueCountPassive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextPassiveCard();
                            }
                          } else if (mode == "active") {
                            await reviewActive("easy");
                            // await reviewActive("hard");
                            await getStatsAll();
                            if (dueCountActive.value == 0) {
                              Navigator.pop(context);
                            } else {
                              await nextActiveCard();
                            }
                          }
                        },
                        icon: FaIcon(FontAwesomeIcons.faceKissWinkHeart),
                        iconSize: 45,
                        color: Colors.red,
                      ),
                    ),
                    // Badge(
                    //   offset: Offset(-10, -5),
                    //   label: Text('kihagy'),
                    //   child: IconButton(
                    //     onPressed: () {
                    //       if (skipAlertToldYou.value == false) {
                    //         skipAlertToldYou.value = true;
                    //         showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) {
                    //               return AlertDialog(
                    //                 title: Text("Szkippelgetünk?"),
                    //                 content: Text(
                    //                     "Kihagyott szavak nem lesznek kikérdezve többé. Csak akkor hagyj ki szót, ha már tudod olyan jól a választ, hogy nem szükséges tanulnod, vagy ha valamiért nem akarod megtanulni az adott szót. (nyomd megint)"),
                    //                 // actions: [
                    //                 //   ElevatedButton(
                    //                 //       onPressed: () {},
                    //                 //       child: Text("Back")),
                    //                 //   ElevatedButton(
                    //                 //       onPressed: () {},
                    //                 //       child: Text("Next")),
                    //                 // ],
                    //               );
                    //             });
                    //       } else {
                    //         print(card);
                    //         if (card.combination.toString() ==
                    //             'Combination([0]-[1])') {
                    //           // skippedIDsPassive.value.add(card.master.toString());
                    //           skippedPassiveIDsbox.add(card.master.toString());
                    //         } else {
                    //           // skippedIDsActive.value.add(card.master.toString());
                    //           skippedActiveIDsbox.add(card.master.toString());
                    //         }
                    //         dolphin.removeFromMaster(card.master.toString());
                    //         front.value = card.front!.join();
                    //         back.value = card.back!.join();
                    //         stats.value = dolphin.summary();
                    //         if (card.combination.toString() ==
                    //             'Combination([0]-[1])') {
                    //           statsPassiveState.value = dolphin
                    //               .summary(); // state-be mentjük a passive tanulási stats-t (hogy milyen állapotban hány kártya van)
                    //           removeAllMasters();
                    //           addUntilCurrentLinePassive();
                    //           loadPassiveReviews();
                    //           removeSkippedIDsPassive();
                    //         } else {
                    //           statsActiveState.value = dolphin
                    //               .summary(); // state-be mentjük a passive tanulási stats-t (hogy milyen állapotban hány kártya van)
                    //           removeAllMasters();
                    //           addUntilCurrentLineActive();
                    //           loadActiveReviews();
                    //           removeSkippedIDsActive();
                    //         }
                    //         if (stats.value.due! +
                    //                 stats.value.overdue! +
                    //                 stats.value.learning! ==
                    //             0) {
                    //           Navigator.pop(context);
                    //         } else {
                    //           card = dolphin.nextCard()!;
                    //         }
                    //       }
                    //       ;
                    //     },
                    //     icon: FaIcon(FontAwesomeIcons.faceKissWinkHeart),
                    //     iconSize: 45,
                    //     color: Colors.red,
                    //   ),
                    // ),
                  ],
                ),
                                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        var url = Uri.parse(
                            "https://hu.wiktionary.org/wiki/${currentWord.value}");
                        launchUrl(url);
                      },
                      icon: const FaIcon(FontAwesomeIcons.w),
                    ),
                    IconButton(
                      onPressed: () {
                        var url = Uri.parse(
                            "https://hunglish.hu/search?huSentence=&enSentence=${currentWord.value}&doc.genre=-10");
                        launchUrl(url);
                      },
                      icon: const FaIcon(FontAwesomeIcons.h),
                    ),
                    IconButton(
                      onPressed: () {
                        var url = Uri.parse(
                            "https://translate.google.com/?sl=en&tl=hu&text=${currentWord.value}&op=translate");
                        launchUrl(url);
                        // launchURLAppHunglish;
                      },
                      icon: const FaIcon(FontAwesomeIcons.g),
                    ),
                    IconButton(
                      onPressed: () {
                        FlutterTts().speak(currentWord.value);
                        ;
                      },
                      icon: const Icon(Icons.volume_up),
                    ),
                    SizedBox(width: 30),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> getPassiveStats() async {
  newStateCountPassive.value = 0;
  learningCountPassive.value = 0;
  reviewCountPassive.value = 0;
  relearningCountPassive.value = 0;
  for (var e in await passiveStateBox.keys) {
    if (await passiveStateBox.get(e) == "newState") {
      newStateCountPassive.value = newStateCountPassive.value + 1;
    } else if (await passiveStateBox.get(e) == "learning") {
      learningCountPassive.value = learningCountPassive.value + 1;
    } else if (await passiveStateBox.get(e) == "review") {
      reviewCountPassive.value = reviewCountPassive.value + 1;
    } else if (await passiveStateBox.get(e) == "relearning") {
      relearningCountPassive.value = relearningCountPassive.value + 1;
    }
  }
  // print("newState: ${newStateCountPassive.value}");
  // print("learning: ${learningCountPassive.value}");
  // print("review: ${reviewCountPassive.value}");
  // print("relearning: ${relearningCountPassive.value}");
}

Future<void> plusFivePassive() async {
  var igoal = await passiveCardsBox.length + 5;
  print("passiveCardsBox.length: ${passiveCardsBox.length}");
  for (var i = await passiveCardsBox.length; i < igoal; i++) {
    print("i in plusFivePassive: $i");
    await passiveCardsBox.put(englishWords[i], f.Card().toJson());
    await passiveDueBox.put(
        englishWords[i], await passiveCardsBox.get(englishWords[i])["due"]);
    await passiveStateBox.put(englishWords[i],
        passiveCardsBox.get(englishWords[i])["state"].toString());
  }
  print(passiveCardsBox.keys);
}

// Future<void> plusFivePassive() async {
//   for (var i = 0; i < 5; i++) {
//     for (var e in englishWords) {
//       if (passiveCardsBox.keys.contains(e)) {
//         print("vanmárilyen");
//       } else {
//         print("nincsmégilyen");
//         print(e);
//         await passiveCardsBox.put(e, f.Card().toJson());
//         await passiveDueBox.put(e, await passiveCardsBox.get(e)["due"]);
//         await passiveStateBox.put(
//             e, passiveCardsBox.get(e)["state"].toString());
//         break;
//       }
//     }
//   }
// }

Future<void> nextPassiveCard() async {
  print(await passiveCardsBox.keys);
  for (var e in await passiveCardsBox.keys) {
    // if (passiveCardsBox.get(e) != "skip") {}
    if (currentWord.value == "") {
      currentWord.value = e;
    } else {
      if (DateTime.parse(await passiveDueBox.get(currentWord.value))
              .compareTo(DateTime.parse(await passiveDueBox.get(e))) >
          0) {
        currentWord.value = e;
      }
    }
  }
  currentMeaning.value = meaningBox.get(currentWord.value);
  print(currentWord.value);
  print(currentMeaning.value);
  front.value = currentWord.value;
  back.value = currentMeaning.value;
}

Future<void> reviewPassive(rating) async {
  // card = f.Card.fromJson(await passiveCardsBox.get(currentWord.value));
  now = DateTime.now();
  schedulingCards = fsrs.repeat(card, now);

  if (rating == "again") {
    card = schedulingCards[f.Rating.again]!.card;
  } else if (rating == "hard") {
    card = schedulingCards[f.Rating.hard]!.card;
  } else if (rating == "good") {
    card = schedulingCards[f.Rating.good]!.card;
  } else if (rating == "easy") {
    card = schedulingCards[f.Rating.easy]!.card;
  }
  print(rating);
  print(card);

  await ttsBothPassive();

  await passiveCardsBox.put(currentWord.value, card.toJson());
  await passiveDueBox.put(
      currentWord.value, await passiveCardsBox.get(currentWord.value)["due"]);
  await passiveStateBox.put(currentWord.value,
      passiveCardsBox.get(currentWord.value)["state"].toString());
}

Future<void> getActiveStats() async {
  newStateCountActive.value = 0;
  learningCountActive.value = 0;
  reviewCountActive.value = 0;
  relearningCountActive.value = 0;
  for (var e in await activeStateBox.keys) {
    if (await activeStateBox.get(e) == "newState") {
      newStateCountActive.value = newStateCountActive.value + 1;
    } else if (await activeStateBox.get(e) == "learning") {
      learningCountActive.value = learningCountActive.value + 1;
    } else if (await activeStateBox.get(e) == "review") {
      reviewCountActive.value = reviewCountActive.value + 1;
    } else if (await activeStateBox.get(e) == "relearning") {
      relearningCountActive.value = relearningCountActive.value + 1;
    }
  }
  // print("newState: ${newStateCountActive.value}");
  // print("learning: ${learningCountActive.value}");
  // print("review: ${reviewCountActive.value}");
  // print("relearning: ${relearningCountActive.value}");
}

Future<void> plusFiveActive() async {
  var iigoal = await activeCardsBox.length + 5;
  print("activeCardsBox.length: ${activeCardsBox.length}");
  for (var i = await activeCardsBox.length; i < iigoal; i++) {
    print("i in plusFiveActive: $i");
    await activeCardsBox.put(englishWords[i], f.Card().toJson());
    await activeDueBox.put(
        englishWords[i], await activeCardsBox.get(englishWords[i])["due"]);
    await activeStateBox.put(englishWords[i],
        activeCardsBox.get(englishWords[i])["state"].toString());
  }
  print(activeCardsBox.keys);
}

// Future<void> plusFiveActive() async {
//   for (var i = 0; i < 5; i++) {
//     for (var e in englishWords) {
//       if (activeCardsBox.keys.contains(e)) {
//         print("vanmárilyen");
//       } else {
//         print("nincsmégilyen");
//         print(e);
//         await activeCardsBox.put(e, f.Card().toJson());
//         await activeDueBox.put(e, await activeCardsBox.get(e)["due"]);
//         await activeStateBox.put(e, activeCardsBox.get(e)["state"].toString());
//         break;
//       }
//     }
//   }
// }

Future<void> nextActiveCard() async {
  print(await activeCardsBox.keys);
  for (var e in await activeCardsBox.keys) {
    // if (activeCardsBox.get(e) != "skip") {}
    if (currentWord.value == "") {
      currentWord.value = e;
    } else {
      if (DateTime.parse(await activeDueBox.get(currentWord.value))
              .compareTo(DateTime.parse(await activeDueBox.get(e))) >
          0) {
        currentWord.value = e;
      }
    }
  }
  currentMeaning.value = meaningBox.get(currentWord.value);
  print(currentWord.value);
  print(currentMeaning.value);
  front.value = currentMeaning.value;
  back.value = currentWord.value;
}

Future<void> reviewActive(rating) async {
  // card = f.Card.fromJson(await activeCardsBox.get(currentWord.value));
  now = DateTime.now();
  schedulingCards = fsrs.repeat(card, now);
  print(card);
  if (rating == "again") {
    card = schedulingCards[f.Rating.again]!.card;
  } else if (rating == "hard") {
    card = schedulingCards[f.Rating.hard]!.card;
  } else if (rating == "good") {
    card = schedulingCards[f.Rating.good]!.card;
  } else if (rating == "easy") {
    card = schedulingCards[f.Rating.easy]!.card;
  }

  await ttsBothActive();

  await activeCardsBox.put(currentWord.value, card.toJson());
  await activeDueBox.put(
      currentWord.value, await activeCardsBox.get(currentWord.value)["due"]);
  await activeStateBox.put(currentWord.value,
      activeCardsBox.get(currentWord.value)["state"].toString());
}

Future<void> getPassiveDueAndLater() async {
  dueCountPassive.value = 0;
  laterCountPassive.value = 0;
  if (passiveCardsBox.length > 0) {
    for (var e in passiveCardsBox.keys) {
      if (DateTime.parse(await passiveDueBox.get(e)).compareTo(DateTime.now()) <
          0) {
        dueCountPassive.value = dueCountPassive.value + 1;
      } else
      // if (DateTime.parse(await passiveDueBox.get(e))
      //         .compareTo(DateTime.now()) >
      //     0)
      {
        laterCountPassive.value = laterCountPassive.value + 1;
      }
    }
  }
}

Future<void> getActiveDueAndLater() async {
  dueCountActive.value = 0;
  laterCountActive.value = 0;
  if (activeCardsBox.length > 0) {
    for (var e in activeCardsBox.keys) {
      if (DateTime.parse(await activeDueBox.get(e)).compareTo(DateTime.now()) <
          0) {
        dueCountActive.value = dueCountActive.value + 1;
      } else
      // if (DateTime.parse(await activeDueBox.get(e))
      //         .compareTo(DateTime.now()) >
      //     0)
      {
        laterCountActive.value = laterCountActive.value + 1;
      }
    }
  }
}

Future<void> getStatsAll() async {
  await getPassiveStats();
  await getActiveStats();
  await getPassiveDueAndLater();
  await getActiveDueAndLater();
  if (mode == "passive") {
    currentDue.value = dueCountPassive.value;
  } else {
    currentDue.value = dueCountActive.value;
  }
}

Future<void> ttsBothPassive() async {
  await flutterTts.setLanguage("en-US");
  await FlutterTts().speak(currentWord.value);
  // await Future.delayed(Duration(milliseconds: 750));
  await flutterTts.setLanguage("hu-HU");
  await FlutterTts().speak(currentMeaning.value);
  await flutterTts.setLanguage("en-US");
  // await Future.delayed(Duration(milliseconds: 750));
}

Future<void> ttsBothActive() async {
  await flutterTts.setLanguage("hu-HU");
  await FlutterTts().speak(currentMeaning.value);
  await flutterTts.setLanguage("en-US");
  await FlutterTts().speak(currentWord.value);
  // await Future.delayed(Duration(milliseconds: 750));
}
