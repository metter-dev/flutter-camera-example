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
  final int width;
  final int height;

  ImageMedia({
    required String path,
    required this.width,
    required this.height,
    DateTime? createdAt,
  }) : super(
          path: path,
          createdAt: createdAt ?? DateTime.now(),
          type: MediaType.image,
        );
}
