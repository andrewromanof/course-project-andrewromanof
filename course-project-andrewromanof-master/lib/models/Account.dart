class Account {
  String? userName;
  String? password;
  String? email;
  int? numposts;
  int? followers;
  int? following;

  Account({ this.userName, this.password, this.email, this.numposts,this.followers, this.following });

}

final mainaccount = Account(userName: "myusername",password: "mypassword",email: "temp@gmail.com",numposts: 0,followers: 0,following: 0 );
