class Status {
  String? errorMessage;
  
  get isSuccess => errorMessage == null ? true : false; 

  Status({this.errorMessage});
}