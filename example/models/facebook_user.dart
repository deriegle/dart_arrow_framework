part of arrow_framework_example;

class FacebookUser {
  FacebookUser({
    @required this.facebookUserId,
    @required this.facebookAuthToken,
  });

  final String facebookUserId;
  final String facebookAuthToken;

  Map<String, dynamic> toJson() {
    return {
      'facebookUserId': facebookUserId,
      'facebookAuthToken': facebookAuthToken,
    };
  }
}
