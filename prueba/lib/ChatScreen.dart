import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:lottie/lottie.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;
  final String chatUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.chatUserId,
    required this.chatUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String _conversationId;
  final StreamController<List<QueryDocumentSnapshot>> _streamController =
      StreamController();
  Timer? _timer;
  String? _editingMessageId;
  bool _isUploadingImage = false;
  final emojiParser = EmojiParser();
  bool _isEmojiPickerVisible = false;

  final List<String> _emojis = [
    "😀",
    "😃",
    "😄",
    "😁",
    "😆",
    "😅",
    "🤣",
    "😂",
    "🙂",
    "🙃",
    "🫠",
    "😉",
    "😊",
    "😇",
    "🥰",
    "😍",
    "🤩",
    "😘",
    "😗",
    "☺️",
    "😚",
    "😙",
    "🥲",
    "😋",
    "😛",
    "😜",
    "🤪",
    "😝",
    "🤑",
    "🤗",
    "🤭",
    "🫢",
    "🫣",
    "🤫",
    "🤔",
    "🫡",
    "🤐",
    "🤨",
    "😐",
    "😑",
    "😶",
    "🫥",
    "😶‍🌫️",
    "😏",
    "😒",
    "🙄",
    "😬",
    "😮‍💨",
    "🤥",
    "🫨",
    "🙂‍↔️",
    "🙂‍↕️",
    "😌",
    "😔",
    "😪",
    "🤤",
    "😴",
    "😷",
    "🤒",
    "🤕",
    "🤢",
    "🤮",
    "🤧",
    "🥵",
    "🥶",
    "🥴",
    "😵",
    "😵‍💫",
    "🤯",
    "🤠",
    "🥳",
    "🥸",
    "😎",
    "🤓",
    "🧐",
    "😕",
    "🫤",
    "😟",
    "🙁",
    "☹️",
    "😮",
    "😯",
    "😲",
    "😳",
    "🥺",
    "🥹",
    "😦",
    "😧",
    "😨",
    "😰",
    "😥",
    "😢",
    "😭",
    "😱",
    "😖",
    "😣",
    "😞",
    "😓",
    "😩",
    "😫",
    "🥱",
    "😤",
    "😡",
    "😠",
    "🤬",
    "😈",
    "👿",
    "💀",
    "☠️",
    "💩",
    "🤡",
    "👹",
    "👺",
    "👻",
    "👽",
    "👾",
    "🤖",
    "😺",
    "😸",
    "😹",
    "😻",
    "😼",
    "😽",
    "🙀",
    "😿",
    "😾",
    "🙈",
    "🙉",
    "🙊",
    "💋",
    "💯",
    "💢",
    "💥",
    "💫",
    "💦",
    "💨",
    "🕳️",
    "💤",
    "👋",
    "🤚",
    "🖐️",
    "✋",
    "🖖",
    "🫱",
    "🫲",
    "🫳",
    "🫴",
    "🫷",
    "🫸",
    "👌",
    "🤌",
    "🤏",
    "✌️",
    "🤞",
    "🫰",
    "🤟",
    "🤘",
    "🤙",
    "👈",
    "👉",
    "👆",
    "🖕",
    "👇",
    "☝️",
    "🫵",
    "👍",
    "👎",
    "✊",
    "👊",
    "🤛",
    "🤜",
    "👏",
    "🙌",
    "🫶",
    "👐",
    "🤲",
    "🤝",
    "🙏",
    "✍️",
    "💅",
    "🤳",
    "💪",
    "🦾",
    "🦿",
    "🦵",
    "🦶",
    "👂",
    "🦻",
    "👃",
    "🧠",
    "🫀",
    "🫁",
    "🦷",
    "🦴",
    "👀",
    "👁️",
    "👅",
    "👄",
    "🫦",
    "👶",
    "🧒",
    "👦",
    "👧",
    "🧑",
    "👱",
    "👨",
    "🧔",
    "🧔‍♂️",
    "🧔‍♀️",
    "👨‍🦰",
    "👨‍🦱",
    "👨‍🦳",
    "👨‍🦲",
    "👩",
    "👩‍🦰",
    "🧑‍🦰",
    "👩‍🦱",
    "🧑‍🦱",
    "👩‍🦳",
    "🧑‍🦳",
    "👩‍🦲",
    "🧑‍🦲",
    "👱‍♀️",
    "👱‍♂️",
    "🧓",
    "👴",
    "👵",
    "🙍",
    "🙍‍♂️",
    "🙍‍♀️",
    "🙎",
    "🙎‍♂️",
    "🙎‍♀️",
    "🙅",
    "🙅‍♂️",
    "🙅‍♀️",
    "🙆",
    "🙆‍♂️",
    "🙆‍♀️",
    "💁",
    "💁‍♂️",
    "💁‍♀️",
    "🙋",
    "🙋‍♂️",
    "🙋‍♀️",
    "🧏",
    "🧏‍♂️",
    "🧏‍♀️",
    "🙇",
    "🙇‍♂️",
    "🙇‍♀️",
    "🤦",
    "🤦‍♂️",
    "🤦‍♀️",
    "🤷",
    "🤷‍♂️",
    "🤷‍♀️",
    "🫅",
    "🤴",
    "👸",
    "👳",
    "👳‍♂️",
    "👳‍♀️",
    "👲",
    "🧕",
    "🤵",
    "👰",
    "🤰",
    "🤱",
    "👩‍🍼",
    "💃",
    "🕺",
    "🛀",
    "🛌",
    "🧑‍🤝‍🧑",
    "👭",
    "👫",
    "👬",
    "💏",
    "👩‍❤️‍💋‍👨",
    "👨‍❤️‍💋‍👨",
    "👩‍❤️‍💋‍👩",
    "💑",
    "👩‍❤️‍👨",
    "👨‍❤️‍👨",
    "👩‍❤️‍👩",
    "💌",
    "💘",
    "💝",
    "💖",
    "💗",
    "💓",
    "💞",
    "💕",
    "💟",
    "❣️",
    "💔",
    "❤️‍🔥",
    "❤️‍🩹",
    "❤️",
    "🩷",
    "🧡",
    "💛",
    "💚",
    "💙",
    "🩵",
    "💜",
    "🤎",
    "🖤",
    "🩶",
    "🤍"
        "🐵"
        "🐒"
        "🦍"
        "🦧"
        "🐶"
        "🐕"
        "🦮"
        "🐕‍🦺"
        "🐩"
        "🐺"
        "🦊"
        "🦝"
        "🐱"
        "🐈"
        "🐈‍⬛"
        "🦁"
        "🐯"
        "🐅"
        "🐆"
        "🐴"
        "🫎"
        "🫏"
        "🐎"
        "🦄"
        "🦓"
        "🦌"
        "🦬"
        "🐮"
        "🐂"
        "🐃"
        "🐄"
        "🐷"
        "🐖"
        "🐗"
        "🐽"
        "🐏"
        "🐑"
        "🐐"
        "🐪"
        "🐫"
        "🦙"
        "🦒"
        "🐘"
        "🦣"
        "🦏"
        "🦛"
        "🐭"
        "🐁"
        "🐀"
        "🐹"
        "🐰"
        "🐇"
        "🐿️"
        "🦫"
        "🦔"
        "🦇"
        "🐻"
        "🐻‍❄️"
        "🐨"
        "🐼"
        "🦥"
        "🦦"
        "🦨"
        "🦘"
        "🦡"
        "🐾"
        "🦃"
        "🐔"
        "🐓"
        "🐣"
        "🐤"
        "🐥"
        "🐦"
        "🐧"
        "🕊️"
        "🦅"
        "🦆"
        "🦢"
        "🦉"
        "🦤"
        "🪶"
        "🦩"
        "🦚"
        "🦜"
        "🪽"
        "🐦‍⬛"
        "🪿"
        "🐦‍🔥"
        "🐸"
        "🐊"
        "🐢"
        "🦎"
        "🐍"
        "🐲"
        "🐉"
        "🦕"
        "🦖"
        "🐳"
        "🐋"
        "🐬"
        "🦭"
        "🐟"
        "🐠"
        "🐡"
        "🦈"
        "🐙"
        "🐚"
        "🪸"
        "🪼"
        "🐌"
        "🦋"
        "🐛"
        "🐜"
        "🐝"
        "🪲"
        "🐞"
        "🦗"
        "🪳"
        "🕷️"
        "🕸️"
        "🦂"
        "🦟"
        "🪰"
        "🪱"
        "🦠"
        "💐"
        "🌸"
        "💮"
        "🪷"
        "🏵️"
        "🌹"
        "🥀"
        "🌺"
        "🌻"
        "🌼"
        "🌷"
        "🪻"
        "🌱"
        "🪴"
        "🌲"
        "🌳"
        "🌴"
        "🌵"
        "🌾"
        "🌿"
        "☘️"
        "🍀"
        "🍁"
        "🍂"
        "🍃"
        "🪹"
        "🪺"
        "🍄"
        "🍇"
        "🍈"
        "🍉"
        "🍊"
        "🍋"
        "🍋‍🟩"
        "🍌"
        "🍍"
        "🥭"
        "🍎"
        "🍏"
        "🍐"
        "🍑"
        "🍒"
        "🍓"
        "🫐"
        "🥝"
        "🍅"
        "🫒"
        "🥥"
        "🥑"
        "🍆"
        "🥔"
        "🥕"
        "🌽"
        "🌶️"
        "🫑"
        "🥒"
        "🥬"
        "🥦"
        "🧄"
        "🧅"
        "🥜"
        "🫘"
        "🌰"
        "🫚"
        "🫛"
        "🍄‍🟫"
        "🍞"
        "🥐"
        "🥖"
        "🫓"
        "🥨"
        "🥯"
        "🥞"
        "🧇"
        "🧀"
        "🍖"
        "🍗"
        "🥩"
        "🥓"
        "🍔"
        "🍟"
        "🍕"
        "🌭"
        "🥪"
        "🌮"
        "🌯"
        "🫔"
        "🥙"
        "🧆"
        "🥚"
        "🍳"
        "🥘"
        "🍲"
        "🫕"
        "🥣"
        "🥗"
        "🍿"
        "🧈"
        "🧂"
        "🥫"
        "🍱"
        "🍘"
        "🍙"
        "🍚"
        "🍛"
        "🍜"
        "🍝"
        "🍠"
        "🍢"
        "🍣"
        "🍤"
        "🍥"
        "🥮"
        "🍡"
        "🥟"
        "🥠"
        "🥡"
        "🦀"
        "🦞"
        "🦐"
        "🦑"
        "🦪"
        "🍦"
        "🍧"
        "🍨"
        "🍩"
        "🍪"
        "🎂"
        "🍰"
        "🧁"
        "🥧"
        "🍫"
        "🍬"
        "🍭"
        "🍮"
        "🍯"
        "🍼"
        "🥛"
        "☕"
        "🫖"
        "🍵"
        "🍶"
        "🍾"
        "🍷"
        "🍸"
        "🍹"
        "🍺"
        "🍻"
        "🥂"
        "🥃"
        "🫗"
        "🥤"
        "🧋"
        "🧃"
        "🧉"
        "🧊"
        "🥢"
        "🍽️"
        "🍴"
        "🥄"
        "🔪"
        "🫙"
        "🏺"
        "🎃"
        "🎄"
        "🎆"
        "🎇"
        "🧨"
        "✨"
        "🎈"
        "🎉"
        "🎊"
        "🎋"
        "🎍"
        "🎎"
        "🎏"
        "🎐"
        "🎑"
        "🧧"
        "🎀"
        "🎁"
        "🎗️"
        "🎟️"
        "🎫"
        "🎖️"
        "🏆"
        "🏅"
        "🥇"
        "🥈"
        "🥉"
        "⚽"
        "⚾"
        "🥎"
        "🏀"
        "🏐"
        "🏈"
        "🏉"
        "🎾"
        "🥏"
        "🎳"
        "🏏"
        "🏑"
        "🏒"
        "🥍"
        "🏓"
        "🏸"
        "🥊"
        "🥋"
        "🥅"
        "⛳"
        "⛸️"
        "🎣"
        "🤿"
        "🎽"
        "🎿"
        "🛷"
        "🥌"
        "🎯"
        "🪀"
        "🪁"
        "🔫"
        "🎱"
        "🔮"
        "🪄"
        "🎮"
        "🕹️"
        "🎰"
        "🎲"
        "🧩"
        "🧸"
        "🪅"
        "🪩"
        "🪆"
        "♠️"
        "♥️"
        "♦️"
        "♣️"
        "♟️"
        "🃏"
        "🀄"
        "🎴"
        "🎭"
        "🖼️"
        "🎨"
        "🧵"
        "🪡"
        "🧶"
        "🪢"
        "🧑‍⚕️"
        "👨‍⚕️"
        "👩‍⚕️"
        "🧑‍🎓"
        "👨‍🎓"
        "👩‍🎓"
        "🧑‍🏫"
        "👨‍🏫"
        "👩‍🏫"
        "🧑‍⚖️"
        "👨‍⚖️"
        "👩‍⚖️"
        "🧑‍🌾"
        "👨‍🌾"
        "👩‍🌾"
        "🧑‍🍳"
        "👨‍🍳"
        "👩‍🍳"
        "🧑‍🔧"
        "👨‍🔧"
        "👩‍🔧"
        "🧑‍🏭"
        "👨‍🏭"
        "👩‍🏭"
        "🧑‍💼"
        "👨‍💼"
        "👩‍💼"
        "🧑‍🔬"
        "👨‍🔬"
        "👩‍🔬"
        "🧑‍💻"
        "👨‍💻"
        "👩‍💻"
        "🧑‍🎤"
        "👨‍🎤"
        "👩‍🎤"
        "🧑‍🎨"
        "👨‍🎨"
        "👩‍🎨"
        "🧑‍✈️"
        "👨‍✈️"
        "👩‍✈️"
        "🧑‍🚀"
        "👨‍🚀"
        "👩‍🚀"
        "🧑‍🚒"
        "👨‍🚒"
        "👩‍🚒"
        "👮"
        "👮‍♂️"
        "👮‍♀️"
        "🕵️"
        "🕵️‍♂️"
        "🕵️‍♀️"
        "💂"
        "💂‍♂️"
        "💂‍♀️"
        "🥷"
        "👷"
        "👷‍♂️"
        "👷‍♀️"
        "👼"
        "🎅"
        "🤶"
        "🧑‍🎄"
        "🦸"
        "🦸‍♂️"
        "🦸‍♀️"
        "🦹"
        "🦹‍♂️"
        "🦹‍♀️"
        "🧙"
        "🧙‍♂️"
        "🧙‍♀️"
        "🧚"
        "🧚‍♂️"
        "🧚‍♀️"
        "🧛"
        "🧛‍♂️"
        "🧛‍♀️"
        "🧜"
        "🧜‍♂️"
        "🧜‍♀️"
        "🧝"
        "🧝‍♂️"
        "🧝‍♀️"
        "🧞"
        "🧞‍♂️"
        "🧞‍♀️"
        "🧟"
        "🧟‍♂️"
        "🧟‍♀️"
        "🧌"
        "🤵"
        "🤵‍♂️"
        "🤵‍♀️"
        "👰"
        "👰‍♂️"
        "👰‍♀️"
        "🤰"
        "🫃"
        "🫄"
        "🤱"
        "👩‍🍼"
        "👨‍🍼"
        "🧑‍🍼"
        "💆"
        "💆‍♂️"
        "💆‍♀️"
        "🚶"
        "🚶‍♂️"
        "🚶‍♀️"
        "🚶‍➡️"
        "🚶‍♀️‍➡️"
        "🚶‍♂️‍➡️"
        "🧍"
        "🧍‍♂️"
        "🧍‍♀️"
        "🧎"
        "🧎‍♂️"
        "🧎‍♀️"
        "🧎‍➡️"
        "🧎‍♀️‍➡️"
        "🧎‍♂️‍➡️"
        "🧑‍🦯"
        "🧑‍🦯‍➡️"
        "👨‍🦯"
        "👨‍🦯‍➡️"
        "👩‍🦯"
        "👩‍🦯‍➡️"
        "🧑‍🦼"
        "🧑‍🦼‍➡️"
        "👨‍🦼"
        "👨‍🦼‍➡️"
        "👩‍🦼"
        "👩‍🦼‍➡️"
        "🧑‍🦽"
        "🧑‍🦽‍➡️"
        "👨‍🦽"
        "👨‍🦽‍➡️"
        "👩‍🦽"
        "👩‍🦽‍➡️"
        "🏃"
        "🏃‍♂️"
        "🏃‍♀️"
        "🏃‍➡️"
        "🏃‍♀️‍➡️"
        "🏃‍♂️‍➡️"
        "💇"
        "💇‍♂️"
        "💇‍♀️"
        "🕴️"
        "👯"
        "👯‍♂️"
        "👯‍♀️"
        "🧖"
        "🧖‍♂️"
        "🧖‍♀️"
        "🧗"
        "🧗‍♂️"
        "🧗‍♀️"
        "🤺"
        "🏇"
        "⛷️"
        "🏂"
        "🏌️"
        "🏌️‍♂️"
        "🏌️‍♀️"
        "🏄"
        "🏄‍♂️"
        "🏄‍♀️"
        "🚣"
        "🚣‍♂️"
        "🚣‍♀️"
        "🏊"
        "🏊‍♂️"
        "🏊‍♀️"
        "⛹️"
        "⛹️‍♂️"
        "⛹️‍♀️"
        "🏋️"
        "🏋️‍♂️"
        "🏋️‍♀️"
        "🚴"
        "🚴‍♂️"
        "🚴‍♀️"
        "🚵"
        "🚵‍♂️"
        "🚵‍♀️"
        "🤸"
        "🤸‍♂️"
        "🤸‍♀️"
        "🤼"
        "🤼‍♂️"
        "🤼‍♀️"
        "🤽"
        "🤽‍♂️"
        "🤽‍♀️"
        "🤾"
        "🤾‍♂️"
        "🤾‍♀️"
        "🤹"
        "🤹‍♂️"
        "🤹‍♀️"
        "🧘"
        "🧘‍♂️"
        "🧘‍♀️"
  ];

  @override
  void initState() {
    super.initState();
    _conversationId =
        _getConversationId(widget.currentUserId, widget.chatUserId);
    _startMessageStream();
  }

  String _getConversationId(String user1Id, String user2Id) {
    return user1Id.compareTo(user2Id) < 0
        ? '$user1Id-$user2Id'
        : '$user2Id-$user1Id';
  }

  void _startMessageStream() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchMessages();
    });
  }

  void _fetchMessages() async {
    try {
      final messages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_conversationId)
          .collection('mensajes')
          .orderBy('timestamp', descending: true)
          .get();

      _streamController.add(messages.docs);
    } catch (e) {
      print('Error al recuperar mensajes: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    try {
      if (_editingMessageId != null) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_conversationId)
            .collection('mensajes')
            .doc(_editingMessageId)
            .update({
          'message': _messageController.text,
          'isEdited': true,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'delivered',
        });
        _editingMessageId = null;
      } else {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_conversationId)
            .collection('mensajes')
            .add({
          'senderId': widget.currentUserId,
          'receiverId': widget.chatUserId,
          'message': emojiParser.emojify(_messageController.text),
          'timestamp': FieldValue.serverTimestamp(),
          'isEdited': false,
          'isSeen': false,
          'status': 'delivered',
        });
      }
      _messageController.clear();
    } catch (e) {
      print('Error al enviar el mensaje: $e');
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_conversationId)
          .collection('mensajes')
          .doc(messageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje eliminado')),
      );
    } catch (e) {
      print('Error al eliminar el mensaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el mensaje')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true;
      });
      String downloadUrl = await _uploadImageToFirebase(pickedFile.path);
      await _sendImageMessage(downloadUrl);
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<String> _uploadImageToFirebase(String imagePath) async {
    try {
      File file = File(imagePath);
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return '';
    }
  }

  Future<void> _sendImageMessage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_conversationId)
          .collection('mensajes')
          .add({
        'senderId': widget.currentUserId,
        'receiverId': widget.chatUserId,
        'message': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
        'isSeen': false,
        'status': 'delivered',
      });
    } catch (e) {
      print('Error al enviar la imagen: $e');
    }
  }

  void _showMessageOptions(String messageId, String message, bool isSender) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSender)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    _messageController.text = message;
                    _editingMessageId = messageId;
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () {
                  _deleteMessage(messageId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            onPressed: _showEmojiPicker,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: Lottie.asset('assets/images/plane.json'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/images/cat.json',
                            width: 100), // Lottie cuando no hay mensajes
                        const SizedBox(height: 10),
                        const Text('No hay mensajes',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender =
                        message['senderId'] == widget.currentUserId;

                    return GestureDetector(
                      onLongPress: () {
                        _showMessageOptions(
                          message.id,
                          message['message'],
                          isSender,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Align(
                          alignment: isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message['timestamp'] != null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                              (message['timestamp']
                                                      as Timestamp)
                                                  .millisecondsSinceEpoch)
                                          .toLocal()
                                          .toString()
                                          .split(' ')[1]
                                      : '',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                if (message['isEdited'])
                                  const Text(
                                    '(Editado)',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploadingImage) const CircularProgressIndicator(),
          if (_isEmojiPickerVisible)
            SizedBox(
              height: 250,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _messageController.text += _emojis[index];
                    },
                    child: Center(
                      child: Text(
                        _emojis[index],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    _messageController.dispose();
    super.dispose();
  }
}
