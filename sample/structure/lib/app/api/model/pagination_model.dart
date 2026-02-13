class PaginationModel {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  PaginationModel({this.currentPage, this.lastPage, this.perPage, this.total});

  PaginationModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    return data;
  }
}
