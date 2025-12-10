// lib/models/user_plan.dart

class UserPlan {
  final bool isPremium;
  final int demoUsesLeft;

  const UserPlan({
    required this.isPremium,
    required this.demoUsesLeft,
  });

  /// Varsayılan durum: DEMO, 1 kullanım hakkı
  factory UserPlan.initialDemo() {
    return const UserPlan(
      isPremium: false,
      demoUsesLeft: 1,
    );
  }

  UserPlan copyWith({
    bool? isPremium,
    int? demoUsesLeft,
  }) {
    return UserPlan(
      isPremium: isPremium ?? this.isPremium,
      demoUsesLeft: demoUsesLeft ?? this.demoUsesLeft,
    );
  }

  @override
  String toString() =>
      'UserPlan(isPremium: $isPremium, demoUsesLeft: $demoUsesLeft)';
}
