import '../models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<RatingModel> submitRating(RatingModel rating);
  Future<List<RatingModel>> getRatingsForDriver(String driverId);
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  @override
  Future<RatingModel> submitRating(RatingModel rating) async {
    return rating;
  }

  @override
  Future<List<RatingModel>> getRatingsForDriver(String driverId) async {
    return [];
  }
}
