// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:oratio_app/helpers/user.dart';
// import 'package:pocketbase/pocketbase.dart';

// Widget buildStorySection(BuildContext context) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 9),
//         child: Text(
//           'Prayers',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//       ),
//       SizedBox(
//         height: 100,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: 10,
//           itemBuilder: (context, index) => Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: _StoryAvatar(index: index),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// class _StoryAvatar extends StatelessWidget {
//   final int index;
//   final RecordModel user;

//   const _StoryAvatar({required this.index, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(2),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: index == 0
//                 ? null
//                 : LinearGradient(
//                     colors: [
//                       Theme.of(context).colorScheme.primary,
//                       Theme.of(context).colorScheme.secondary,
//                     ],
//                   ),
//           ),
//           child: CircleAvatar(
//             radius: 32,
//             backgroundColor: Theme.of(context).colorScheme.surface,
//               backgroundImage:
//                   getProfilePic(context, user:user) == null
//                       ? null
//                       : CachedNetworkImageProvider(
//                           getProfilePic(context, user:user)!),
//             child: index == 0
//                 ? const Icon(Icons.add)
//                 : user.getStringValue('avatar').isEmpty? Text(
//                     String.fromCharCode(65 + index),
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ): null,
//           ),
//         ),
//         const Gap(4),
//         Text(
//           index == 0 ? 'Say Prayer' : user.getStringValue('username'),
//           style: Theme.of(context).textTheme.labelSmall,
//         ),
//       ],
//     );
//   }
// }
