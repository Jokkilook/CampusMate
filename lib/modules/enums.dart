enum MessageType { text, picture, video, notice }

MessageType stringToEnumMessageType(String value) {
  MessageType result;

  switch (value) {
    case "MessageType.text":
      result = MessageType.text;
      break;
    case "text":
      result = MessageType.text;
      break;
    case "MessageType.picture":
      result = MessageType.picture;
      break;
    case "picture":
      result = MessageType.picture;
      break;
    case "MessageType.video":
      result = MessageType.video;
      break;
    case "video":
      result = MessageType.video;
      break;
    case "MessageType.notice":
      result = MessageType.notice;
      break;
    case "notice":
      result = MessageType.notice;
      break;
    default:
      result = MessageType.text;
  }

  return result;
}

enum ThemeType { light, dark, system }

ThemeType stringToEnumThemeType(String value) {
  ThemeType result;
  switch (value) {
    case "light":
      result = ThemeType.light;
      break;
    case "dark":
      result = ThemeType.dark;
      break;
    case "system":
      result = ThemeType.system;
      break;
    default:
      result = ThemeType.system;
      break;
  }
  return result;
}
