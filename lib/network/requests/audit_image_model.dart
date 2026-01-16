
class AuditImageModel {
  final Uri? image;
  final String? imageStringPath;
  final int? questionId;
  final String? tag;
  final String? location;

  AuditImageModel({
    this.image,
    this.imageStringPath,
    this.questionId,
    this.tag,
    this.location,
  });

  factory AuditImageModel.fromJson(Map<String, dynamic> json) {
    return AuditImageModel(
      image: json['image'] != null ? Uri.parse(json['image']) : null,
      imageStringPath: json['imageStringPath'] as String?,
      questionId: json['questionId'] as int?,
      tag: json['tag'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image?.toString(),
      'imageStringPath': imageStringPath,
      'questionId': questionId,
      'tag': tag,
      'location': location,
    };
  }
}

class ImageModel {
  final String? imageStringPath;
  final String? tag;
  final String? location;

  ImageModel({
    this.imageStringPath,
    this.tag,
    this.location,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageStringPath: json['imageStringPath'] as String?,
      tag: json['tag'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageStringPath': imageStringPath,
      'tag': tag,
      'location': location,
    };
  }
}

class ImageList {
  final List<ImageModel>? list;

  ImageList({this.list});

  factory ImageList.fromJson(Map<String, dynamic> json) {
    return ImageList(
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => ImageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((item) => item.toJson()).toList(),
    };
  }
}
