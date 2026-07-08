class OAuthUrls {
  OAuthUrls._();

  static String google(String baseUrl) =>
      '$baseUrl/v1/oauth2/authorization/google';
  static String kakao(String baseUrl) =>
      '$baseUrl/v1/oauth2/authorization/kakao';
  static String apple(String baseUrl) =>
      '$baseUrl/v1/oauth2/authorization/apple';
}
