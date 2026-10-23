import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';
import '../models/rating_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RatingEntity> submitRating(RatingEntity rating) async {
    final model = RatingModel(
      id: rating.id,
      orderId: rating.orderId,
      userId: rating.userId,
      score: rating.score,
      review: rating.review,
      createdAt: rating.createdAt,
    );
    return await remoteDataSource.submitRating(model);
  }

  @override
  Future<List<RatingEntity>> getRatingsForDriver(String driverId) async {
    return await remoteDataSource.getRatingsForDriver(driverId);
  }
}
