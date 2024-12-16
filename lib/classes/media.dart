abstract class MediaItem {
  final String path;
  final DateTime createdAt;
  final MediaType type;

  MediaItem({
    required this.path,
    required this.createdAt,
    required this.type,
  });
}

enum MediaType { video, image }

class VideoMedia extends MediaItem {
  final Duration duration;
  final String? thumbnail;

  VideoMedia({
    required String path,
    required this.duration,
    this.thumbnail,
    DateTime? createdAt,
  }) : super(
          path: path,
          createdAt: createdAt ?? DateTime.now(),
          type: MediaType.video,
        );
}

class ImageMedia extends MediaItem {
  int? width;
  int? height;

  ImageMedia({
    required String path,
    int? width,
    int? height,
    DateTime? createdAt,
  }) : super(
          path: path,
          createdAt: createdAt ?? DateTime.now(),
          type: MediaType.image,
        );
}
