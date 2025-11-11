import 'package:isar/isar.dart';
import '../models/resource_model.dart';

part 'audio_resource_schema.g.dart';

@collection
class AudioResourceIsar {
  Id id = Isar.autoIncrement;

  @Index()
  String? resourceId;

  String? title;
  String? duration;
  int? progress;
  String? status;
  String? category;
  String? segmentationStatus;
  DateTime? lastStudied;

  // 存储音频文件名（相对路径，不是绝对路径）
  // iOS 每次启动应用容器路径会变化，因此只存储文件名
  String? filePath;  // 文件名（例如: "audio.mp3"）
  String? originalFileName;  // 原始文件名

  AudioResourceIsar();

  AudioResourceIsar.fromAudioResource(AudioResource resource, {this.filePath, this.originalFileName}) {
    resourceId = resource.id;
    title = resource.title;
    duration = resource.duration;
    progress = resource.progress;
    status = resource.status.toString();
    category = resource.category.toString();
    segmentationStatus = resource.segmentationStatus.toString();
    lastStudied = resource.lastStudied;
  }

  AudioResource toAudioResource() {
    LearningStatus statusValue;
    switch (status) {
      case 'LearningStatus.notStarted':
        statusValue = LearningStatus.notStarted;
        break;
      case 'LearningStatus.learning':
        statusValue = LearningStatus.learning;
        break;
      case 'LearningStatus.mastered':
        statusValue = LearningStatus.mastered;
        break;
      default:
        statusValue = LearningStatus.notStarted;
    }

    ResourceCategory categoryValue;
    switch (category) {
      case 'ResourceCategory.jlpt':
        categoryValue = ResourceCategory.jlpt;
        break;
      case 'ResourceCategory.news':
        categoryValue = ResourceCategory.news;
        break;
      case 'ResourceCategory.dialogue':
        categoryValue = ResourceCategory.dialogue;
        break;
      default:
        categoryValue = ResourceCategory.custom;
    }

    SegmentationStatus segmentationValue;
    switch (segmentationStatus) {
      case 'SegmentationStatus.notSegmented':
        segmentationValue = SegmentationStatus.notSegmented;
        break;
      case 'SegmentationStatus.segmenting':
        segmentationValue = SegmentationStatus.segmenting;
        break;
      case 'SegmentationStatus.segmented':
        segmentationValue = SegmentationStatus.segmented;
        break;
      case 'SegmentationStatus.failed':
        segmentationValue = SegmentationStatus.failed;
        break;
      default:
        segmentationValue = SegmentationStatus.notSegmented;
    }

    return AudioResource(
      id: resourceId ?? '',
      title: title ?? '',
      duration: duration ?? '未知',
      progress: progress ?? 0,
      status: statusValue,
      category: categoryValue,
      segmentationStatus: segmentationValue,
      lastStudied: lastStudied,
      filePath: filePath, // 添加文件路径
    );
  }
}
