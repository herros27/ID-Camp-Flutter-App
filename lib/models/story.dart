import 'package:freezed_annotation/freezed_annotation.dart';

// These two lines are crucial
part 'story.freezed.dart';
part 'story.g.dart';
//Perintah untuk build freeze : flutter pub run build_runner build 
@freezed
abstract class Story with _$Story {
  const factory Story({
    required String id,
    required String name,
    required String description,
    required String photoUrl,
    double? lat,
    double? lon,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}
