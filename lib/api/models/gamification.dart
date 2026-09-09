part of '../client.dart';

class GamificationProfile {
  final int? xp;
  final int? level;
  final GamificationReputation? reputation;
  final List<GamificationBadge> badges;
  final bool? leaderboardOptIn;
  final GamificationContributionCounts? contributionCounts;

  const GamificationProfile({
    this.xp,
    this.level,
    this.reputation,
    this.badges = const [],
    this.leaderboardOptIn,
    this.contributionCounts,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      xp: json['xp'] as int?,
      level: json['level'] as int?,
      reputation: json['reputation'] == null
          ? null
          : GamificationReputation.fromJson(
              json['reputation'] as Map<String, dynamic>,
            ),
      badges:
          (json['badges'] as List?)
              ?.map(
                (e) => GamificationBadge.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
      leaderboardOptIn: json['leaderboard_opt_in'] as bool?,
      contributionCounts: json['contribution_counts'] == null
          ? null
          : GamificationContributionCounts.fromJson(
              json['contribution_counts'] as Map<String, dynamic>,
            ),
    );
  }
}

class GamificationReputation {
  final int? accepted;
  final int? total;
  final double? value;

  const GamificationReputation({this.accepted, this.total, this.value});

  factory GamificationReputation.fromJson(Map<String, dynamic> json) {
    return GamificationReputation(
      accepted: json['accepted'] as int?,
      total: json['total'] as int?,
      value: (json['value'] as num?)?.toDouble(),
    );
  }
}

class GamificationBadge {
  final String? badgeKey;
  final String? awardedAt;

  const GamificationBadge({this.badgeKey, this.awardedAt});

  factory GamificationBadge.fromJson(Map<String, dynamic> json) {
    return GamificationBadge(
      badgeKey: json['badge_key']?.toString(),
      awardedAt: json['awarded_at']?.toString(),
    );
  }
}

class GamificationContributionCounts {
  final int? newReportAccepted;
  final int? corroborationAccepted;
  final int? statusChangingAccepted;

  const GamificationContributionCounts({
    this.newReportAccepted,
    this.corroborationAccepted,
    this.statusChangingAccepted,
  });

  factory GamificationContributionCounts.fromJson(Map<String, dynamic> json) {
    return GamificationContributionCounts(
      newReportAccepted: json['new_report_accepted'] as int?,
      corroborationAccepted: json['corroboration_accepted'] as int?,
      statusChangingAccepted: json['status_changing_accepted'] as int?,
    );
  }
}

class GamificationOptInResult {
  final bool? success;
  final bool? leaderboardOptIn;

  const GamificationOptInResult({this.success, this.leaderboardOptIn});

  factory GamificationOptInResult.fromJson(Map<String, dynamic> json) {
    return GamificationOptInResult(
      success: json['success'] as bool?,
      leaderboardOptIn: json['leaderboard_opt_in'] as bool?,
    );
  }
}
