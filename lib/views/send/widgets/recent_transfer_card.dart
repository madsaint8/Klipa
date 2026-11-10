// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:paywave/common/widgets/transaction/quick_send_contact.dart';
// import '../../../core/utils/constants/image_strings.dart';
// import '../../../providers/contacts/contacts_provider.dart';
// import '../../../send_money_screen.dart';


// class RecentTransfer extends ConsumerWidget {
//   const RecentTransfer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contactsAsync = ref.watch(contactsProvider);

//     return contactsAsync.when(
//       loading: () => const SizedBox(height: 100),
//       error: (_, __) => const Text('Failed to load contacts'),
//       data: (contacts) {
//         final list =
//             contacts.isEmpty ? seedQuickSendContacts : contacts;

//         return SizedBox(
//           height: 110,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: list.map(
//               (contact) {
//                 return buildQuickSendContact(
//                   contact,
//                   onTap: () {
//                     if (contact.name == 'Add +') {
//                       // TODO: open add-contact bottom sheet
//                       return;
//                     }

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder : (_) => const PayBeneficiaryScreen(
//                           //contact: contact,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ).toList(),
//           ),
//         );
//       },
//     );
//   }
// }


