import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/subscription_model.dart';

final userSubscriptionStreamProvider = StreamProvider<SubscriptionModel>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return Stream.value(SubscriptionModel.free());
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .collection('subscription')
      .doc('current')
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return SubscriptionModel.free();
    }
    return SubscriptionModel.fromJson(snapshot.data()!);
  });
});
