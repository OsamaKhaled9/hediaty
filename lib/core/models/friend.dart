class Friend {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendAvatar;
  int upcomingEventsCount;  // Make this non-final so it can be updated

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
    required this.upcomingEventsCount,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['userId'],
      friendId: json['friendId'],
      friendName: json['friendName'],
      friendAvatar: json['friendAvatar'],
      upcomingEventsCount: json['upcomingEventsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'upcomingEventsCount': upcomingEventsCount,
    };
  }
}
