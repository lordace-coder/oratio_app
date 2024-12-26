import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


class UpdateItem extends StatefulWidget {
  const UpdateItem({
    super.key,
  });

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  bool showFulltext = false;
  bool istapped = false;
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          // color: theme.itemBackgroundcolor,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                    ),
                    Gap(10),
                    Text(
                      "St Anthony's",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: theme.shadePrimary,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(itemBuilder: (context) => [])
              ],
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showFulltext = !showFulltext;
                      });
                    },
                    child: customTextWidget(
                      text:
                          'I/com.example.am( 3130): Background young concurrent copying GC freed 53034(2131KB) AllocSpace objects, 0(0B) LOS objects, 48% free, 2333KB/4521KB, paused 3.515ms total 255.684msThe input method toggled cursor monitoring on',
                      style: const TextStyle(
                          // color: theme.chatInoutColor,
                          ),
                      showFulltext: showFulltext,
                    ),
                  ),
                ),
                if (!showFulltext)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showFulltext = !showFulltext;
                      });
                    },
                    child: const Text(
                      'see more',
                      // style: TextStyle(color: theme.subtitleColor),
                    ),
                  ),
              ],
            ),
            if (showFulltext)
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showFulltext = !showFulltext;
                    });
                  },
                  child: const Text(
                    '..see less',
                    style: TextStyle(
                        // color: theme.subtitleColor,
                        ),
                  ),
                ),
              ),
            const Gap(10),
            Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  color: Colors.pinkAccent,
                )

                // Image.asset('assets/images/finance/9mobile_log.png'),
                ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          istapped = !istapped;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            // color: theme.itemBackgroundcolor,
                            borderRadius: BorderRadius.circular(15)),
                        width: 60,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              istapped
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.thumb_up_alt_outlined,
                              // color: theme.shadePrimary,
                              size: 20,
                            ),
                            const Text(
                              '10',
                              style: TextStyle(
                                  // color: theme.shadePrimary,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                    InkWell(
                      onTap: () {
                        // showCommentsBottomSheet(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            // color: theme.itemBackgroundcolor,
                            borderRadius: BorderRadius.circular(15)),
                        width: 60,
                        height: 30,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.mode_comment_outlined,
                              // color: theme.shadePrimary,
                              size: 20,
                            ),
                            Text(
                              '10',
                              style: TextStyle(
                                  // color: theme.shadePrimary,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // showCommentsBottomSheet(context);
                  },
                  child: const Row(
                    children: [
                      Text(
                        'View comments',
                        // style: TextStyle(color: theme.subtitleColor),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget customTextWidget({
  required String text,
  TextStyle? style,
  required bool showFulltext,
}) {
  if (showFulltext) {
    return Text(
      text,
      style: style,
    );
  }
  return Text(
    '${text.substring(0, 70)}...',
    overflow: TextOverflow.ellipsis,
    style: style,
  );
}
