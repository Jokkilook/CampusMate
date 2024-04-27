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
