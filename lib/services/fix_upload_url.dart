class FixUploadUrl {
  String fixImgBBUrl(String url) {
    if (url.startsWith('https://i.ibb.co/')) {
      return url.replaceFirst('https://i.ibb.co/', 'https://i.ibb.co.com/');
    }
    return url;
  }
}