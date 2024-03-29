class ScheduleData {
  Map<String, bool> mon = {
    "MON08": true,
    "MON09": true,
    "MON10": true,
    "MON11": true,
    "MON12": true,
    "MON13": true,
    "MON14": true,
    "MON15": true,
    "MON16": true,
    "MON17": true,
    "MON18": true,
    "MON19": true,
  };

  Map<String, bool> tue = {
    "TUE08": true,
    "TUE09": true,
    "TUE10": true,
    "TUE11": true,
    "TUE12": true,
    "TUE13": true,
    "TUE14": true,
    "TUE15": true,
    "TUE16": true,
    "TUE17": true,
    "TUE18": true,
    "TUE19": true,
  };

  Map<String, bool> wed = {
    "WED08": true,
    "WED09": true,
    "WED10": true,
    "WED11": true,
    "WED12": true,
    "WED13": true,
    "WED14": true,
    "WED15": true,
    "WED16": true,
    "WED17": true,
    "WED18": true,
    "WED19": true,
  };

  Map<String, bool> thu = {
    "THU08": true,
    "THU09": true,
    "THU10": true,
    "THU11": true,
    "THU12": true,
    "THU13": true,
    "THU14": true,
    "THU15": true,
    "THU16": true,
    "THU17": true,
    "THU18": true,
    "THU19": true,
  };

  Map<String, bool> fri = {
    "FRI08": true,
    "FRI09": true,
    "FRI10": true,
    "FRI11": true,
    "FRI12": true,
    "FRI13": true,
    "FRI14": true,
    "FRI15": true,
    "FRI16": true,
    "FRI17": true,
    "FRI18": true,
    "FRI19": true,
  };

  late List<Map<String, bool>> schedule;

  ScheduleData() {
    schedule = [mon, tue, wed, thu, fri];
  }

  void reset() {
    schedule = [mon, tue, wed, thu, fri];
  }
}
