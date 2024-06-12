fontSize(String? subject) {
    
    if(subject != null) {
      switch(subject.length){
        case > 125: 
          return 16.0;
        case > 75:
          return 18.0;
        case > 50:
          return 20.0;
        case > 25:
          return 22.0;
        default:
          return 24.0;
      }
    }
  }