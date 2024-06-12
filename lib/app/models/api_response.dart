class ApiResponse<T> {
  final List<T> results;

  ApiResponse({
    required this.results,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse<T>(
      results: List<T>.from(json['results'].map((result) => fromJsonT(result))),
    );
  }
}