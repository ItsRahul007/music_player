final List<String> orderByOptions = [
  'Name',
  'Size',
  'Latest first',
  'Oldest first'
];

class AudioFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final String? artist;
  final String? base64Str; //! it will be the thumbnail image

  AudioFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    this.artist,
    this.base64Str,
  });
}
