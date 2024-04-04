class NotesModel {
  final String title;
  final String content;
  final String url;

  NotesModel(this.title, this.content, this.url);

  factory NotesModel.fromJson(Map<String, dynamic> json) {
    return NotesModel(json["title"], json["content"], json["url"]);
  }
}
