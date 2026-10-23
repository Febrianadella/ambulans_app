import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<RatingEntity> submitRating(RatingEntity rating);
  Future<List<RatingEntity>> getRatingsForDriver(String driverId);
}
