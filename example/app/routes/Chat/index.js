// /**
//  * Sample React Native App
//  * https://github.com/facebook/react-native
//  * @flow
//  */

import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Alert,
  Dimensions,
  Platform,
} from 'react-native';

import IMUI from 'aurora-imui-react-native'
var InputView = IMUI.ChatInput;
var MessageListView = IMUI.MessageList;
const AuroraIController = IMUI.AuroraIMUIController;
const window = Dimensions.get('window');

import JMessage from 'jmessage-react-plugin';

export default class Chat extends Component {

  static navigationOptions = {
    title: "Chat",
  };

  constructor(props) {
    super(props);
    let initHeight;
    if (Platform.OS == "android") {
      initHeight = 100
    } else {
      initHeight = 86
    }
    this.state = {
      inputLayoutHeight: initHeight,
      messageListLayout: {},
      inputViewLayout: { width: window.width, height: initHeight, },
      menuContainerHeight: 625,
      from: 0,
      limit: 10,
    };

    this.updateLayout = this.updateLayout.bind(this);
    this.onTouchMsgList = this.onTouchMsgList.bind(this);
    this.conversation = this.props.navigation.state.params.conversation
    console.log(JSON.stringify(this.conversation))

    JMessage.getMyInfo((myInfo) => {
      this.myInfo = myInfo
    })
  }

  convertJMessageToAuroraMsg(jmessage) {
    var auroraMsg = {}
    auroraMsg.msgType = jmessage.type
    auroraMsg.msgId = jmessage.id

    if (jmessage.type === 'text') {
      auroraMsg.text = jmessage.text
    }

    if (jmessage.type === 'image') {
      auroraMsg.mediaPath = jmessage.thumbPath
    }

    if (jmessage.type === 'voice') {
      auroraMsg.mediaPath = jmessage.path
      auroraMsg.duration = jmessage.duration
    }

    if (jmessage.type === 'file') {
      if (jmessage.extras.fileType === 'video') {
        auroraMsg.mediaPath = jmessage.path
        auroraMsg.duration = jmessage.duration
        auroraMsg.msgType = "video"
      } else {
        console.log("cann't parse this file type ignore")
        return {}
      }
    }

    if (jmessage.type === 'event') {
      Alert.alert('event' , jmessage.eventType)
      auroraMsg.text = jmessage.eventType
    }

    if(jmessage.type === 'prompt') {
      auroraMsg.msgType = 'event'
      auroraMsg.text = jmessage.promptText
    }

    var user = {
      userId: "1",
      displayName: "",
      avatarPath: "1111111"
    }
    console.log("from user: " + jmessage.from.avatarThumbPath)
    user.userId = jmessage.from.username
    user.displayName = jmessage.from.nickname
    user.avatarPath = jmessage.from.avatarThumbPath
    if (user.displayName == "") {
      user.displayName = jmessage.from.username
    }
    if (user.avatarPath == "") {
      user.avatarPath = "ironman"
    }
    auroraMsg.fromUser = user
    auroraMsg.status = "send_succeed"

    auroraMsg.isOutgoing = true

    if (this.myInfo.username === jmessage.from.username) {
      auroraMsg.isOutgoing = true
    } else {
      auroraMsg.isOutgoing = false
    }

    auroraMsg.timeString = ""

    return auroraMsg
  }

  getNormalMessage() {
    var msg = {}
    if (this.conversation.type === 'single') {
      msg.username = this.conversation.username
    } else if (this.conversation.type === "group") {
      msg.groupId = this.conversation.groupId
    } else {
      msg.roomId = this.conversation.roomId
    }
    msg.type = this.conversation.type
    return msg
  }

  sendCustomMessage = () => {
    var messages = [];
    for (var i = 0; i < 10; i++) {
      var message = this.getNormalMessage()
      message.msgType = "custom"
      message.msgId = "10"
      message.status = "send_going"
      message.isOutgoing = true
      message.content = '<body bgcolor="#ff3399"><h5>This is a custom message. </h5>\
      <img src="/storage/emulated/0/XhsEmoticonsKeyboard/Emoticons/wxemoticons/icon_040_cover.png"></img></body>'
      message.contentSize = { 'height': 200, 'width': 200 }
      message.extras = { "extras": "fdfsf" }
      var user = {
        userId: "1",
        displayName: "",
        avatarPath: ""
      }
      user.displayName = "0001"
      user.avatarPath = "ironman"
      message.fromUser = user
      messages[i] = message;
    }

    AuroraIController.appendMessages(messages)
    var customMessage = {'type':"single",'username':'Wicked002','appKey':'58067d5678c387f20831a956','customObject':{'key':'value'}}
    JMessage.sendCustomMessage(customMessage,success => {
      console.log('JS sendCustomMessage success:'+JSON.stringify(success))
    },error => {
      console.log('JS sendCustomMessage error:'+JSON.stringify(error))
    })
  }

  componentDidMount() {
    this.resetMenu()
    this.setState({
      messageListLayout: { flex: 1, margin: 0, width: window.width }
    })
    var parames = {

      from: this.state.from,            // 开始的消息下标。
      limit: this.state.limit,            // 要获取的消息数。比如当 from = 0, limit = 10 时，是获取第 0 - 9 条历史消息。
      type: this.conversation.type,
      username: this.conversation.username,
      groupId: this.conversation.groupId,
      roomId: this.conversation.roomId
    }
    this.messageListDidLoadCallback = () => {
      JMessage.getHistoryMessages(parames, (messages) => {
        // Alert.alert('messages',JSON.stringify(messages))
        console.log("JS getHistoryMessage:"+JSON.stringify(messages));
        this.setState({
          from: this.state.from + 10
        })
        var auroraMessages = messages.map((message) => {
          var normalMessage = this.convertJMessageToAuroraMsg(message)
          if (normalMessage.msgType === "unknow") {
            return
          }
          return normalMessage
        })
        AuroraIController.insertMessagesToTop(auroraMessages)
      }, (error) => {
        Alert.alert('error!', JSON.stringify(error))
      })

      this.receiveMessageCallBack = (message) => {

        console.log("JS receiveMessage:"+JSON.stringify(message));
        const readParams = {
          type: "single",
          username: message.from.username,
          appKey: message.from.appKey,
          id: message.id,
        }

        //JMessage.setMsgHaveRead(readParams,(result) => {},(error) => {})

        if (this.conversation.type === 'single') {
          if (message.target.type === 'user') {
            if (message.from.username === this.conversation.username) {
              var msg = this.convertJMessageToAuroraMsg(message)
              AuroraIController.appendMessages([msg])
            }
            Alert.alert('message.from.username', message.from.username+",message:"+message.text)
          }
        } else if (this.conversation.type === 'group') {
          if (message.target.type === 'group') {
            if (message.from.id === this.conversation.groupId) {
              var msg = this.convertJMessageToAuroraMsg(message)
              AuroraIController.appendMessages([msg])
            }
          }
        } else {
          if (message.target.type === 'chatroom') {
            if (message.target.roomId === this.conversation.roomId) {
              var msg = this.convertJMessageToAuroraMsg(message)
              AuroraIController.appendMessages([msg])
            }
          }
        }
      }
      JMessage.addReceiveMessageListener(this.receiveMessageCallBack)
      //JMessage.addReceiptMessageListener((result)=>{})

    }
    AuroraIController.addMessageListDidLoadListener(this.messageListDidLoadCallback)
    // this.timer = setTimeout(() => {
    //   console.log("Sending custom message")
    //   this.sendCustomMessage();
    // }, 2000)
  }

  onInputViewSizeChange = (size) => {
    console.log("height: " + size.height)
    if (this.state.inputLayoutHeight != size.height) {
      this.setState({
        inputLayoutHeight: size.height,
        inputViewLayout: { width: size.width, height: size.height },
        messageListLayout: { flex: 1, width: window.width, margin: 0 }
      })
    }
  }

  componentWillUnmount() {
    JMessage.removeReceiveMessageListener(this.receiveMessageCallBack)
    AuroraIController.removeMessageListDidLoadListener(this.messageListDidLoadCallback)
    this.timer && clearTimeout(this.timer);
    if (this.conversation.type === "chatroom") {
      JMessage.leaveChatRoom({roomId: this.conversation.roomId}, (code) => {
        console.log("Leave chat room succeed")
      }, (error) => {
        alert("error: " + JSON.stringify(error))
      })
    } else {
      JMessage.exitConversation()
    }

  }

  resetMenu() {
    if (Platform.OS === "android") {
      this.refs["ChatInput"].showMenu(false)
      this.setState({
        messageListLayout: { flex: 1, width: window.width, margin: 0 },
      })
    } else {
      this.setState({
        inputViewLayout: { width: window.width, height: 86 }
      })
    }
  }

  updateLayout(layout) {
    this.setState({ inputViewLayout: layout })
  }

  onAvatarClick = (message) => {

  }

  onTouchMsgList() {
    AuroraIController.hidenFeatureView(true)
  }

  onTouchEditText = () => {
    console.log("scroll to bottom")
    this.refs["ChatInput"].showMenu(false)
    this.setState({
      inputViewLayout: { width: window.width, height: this.state.inputLayoutHeight }
    })
  }

  onFullScreen = () => {
    var navigationBar = 50
    this.setState({
      messageListLayout: { flex: 0, width: 0, height: 0 },
      inputViewLayout: { flex: 1, width: window.width, height: window.height }
    })
  }

  onRecoverScreen = () => {
    this.setState({
      messageListLayout: { flex: 1, width: window.width, margin: 0 },
      inputViewLayout: { flex: 0, width: window.width, height: this.state.inputLayoutHeight }
    })
  }

  onMsgClick = (message) => {
    console.log(message)
    // alert(JSON.stringify(message))
    Alert.alert('onSendGalleryFiles',JSON.stringify(message))
  }

  onMsgLongClick = (message) => {
    var msg = {}
    msg.type = 'group'
    msg.groupId = this.conversation.groupId
    msg.messageId = message.msgId
    Alert.alert('撤回消息','撤回消息')
    JMessage.retractMessage(msg, (success) => {
      var eventMsg = {}
      eventMsg.msgId = message.msgId
      eventMsg.msgType = "event"
      eventMsg.text = "撤回的消息"
      AuroraIController.updateMessage(eventMsg);
    }, (error) => {

    })

  }

  onStatusViewClick = (message) => {
    console.log(message)
    message.status = 'send_succeed'
    message.fromUser.avatarPath = message.mediaPath
    AuroraIController.updateMessage(message)
  }

  onBeginDragMessageList = () => {
    this.updateLayout({ width: window.width, height: 86, })
    AuroraIController.hidenFeatureView(true)
  }

  onPullToRefresh = () => {
    console.log("on pull to refresh")
    var parames = {

      from: this.state.from,            // 开始的消息下标。
      limit: this.state.limit,            // 要获取的消息数。比如当 from = 0, limit = 10 时，是获取第 0 - 9 条历史消息。
      type: this.conversation.type,
      username: this.conversation.username,
      groupId: this.conversation.groupId,
      roomId: this.conversation.roomId
    }
    JMessage.getHistoryMessages(parames, (messages) => {
      if (Platform.OS == "android") {
        this.refs["MessageList"].refreshComplete()
      }
      this.setState({
        from: this.state.from + 10
      })
      var auroraMessages = messages.map((message) => {
        var normalMessage = this.convertJMessageToAuroraMsg(message)
        if (normalMessage.msgType === "unknow") {
          return
        }
        return normalMessage
      })
      AuroraIController.insertMessagesToTop(auroraMessages)
    }, (error) => {
      Alert.alert('error!', JSON.stringify(error))
    })
  }


  setMessageTarget = (msg) => {
    if (this.conversation.type === 'single') {
      msg.username = this.conversation.username
    } else if (this.conversation.type === "group") {
      msg.groupId = this.conversation.groupId
    } else {
      msg.roomId = this.conversation.roomId
    }
    msg.type = this.conversation.type
  }

  onSendText = (text) => {
    // JMessage.createGroup({'name':'群','desc':'描述','groupType':'public'},success => {
    //   console.log('JS createGroup success:'+JSON.stringify(success))
    // },error => {
    //   console.log('JS createGroup error:'+JSON.stringify(error))
    // })

    // 34863871

    // JMessage.addGroupMembers({'id':'34863871','usernameArray':['wicked','wicked001','qqqqqq'],'appKey':'58067d5678c387f20831a956'},success => {
    //   console.log('JS addGroupMembers success:'+JSON.stringify(success))
    // },error => {
    //   console.log('JS addGroupMembers error:'+JSON.stringify(error))
    // })

    // var parames = {
    //   'type':'group',
    //   'groupId':'34863871',
    //   'username':'wwwwww',
    //   'appKey':'58067d5678c387f20831a956',
    //   'messageType':'text',
    //   'text':'123456',
    //   'groupAt':true,
    //   'usernames':['wicked','qqqqqq']
    // }

    // JMessage.sendGroupAtMessage(parames,success => {
    //   console.log('JS sendGroupAtMessage success:'+JSON.stringify(success))
    // },error => {
    //   console.log('JS sendGroupAtMessage error:'+JSON.stringify(error))
    // })

    // JMessage.createSendMessage(parames,
    // message => {console.log('JS createSendMessage groupAt:'+JSON.stringify(message))

    //   var groupAtMessage = {
    //     'type' : 'group',
    //     'groupId' : message.target.id,
    //     'appKey':'58067d5678c387f20831a956',
    //     'id' : ''+ message.id,
    //     'messageType' : message.type,
    //     'text' : message.text,
    //   }

    //   JMessage.sendMessage(groupAtMessage, success => {
    //     console.log('JS sendMessage success groupAt:'+JSON.stringify(success))
    //   }, error => {
    //     console.log('JS sendMessage error groupAt:'+JSON.stringify(error))
    //   })
    //   }
    // )

    var message = this.getNormalMessage()
    message.text = text
    message.messageType = "text"
    // message.messageType = "custom"
    // message.customObject = {'key':'value'}
    JMessage.createSendMessage(message, (msg) => {
      console.log('JS createSendMessage:'+JSON.stringify(msg))
      var auroraMsg = this.convertJMessageToAuroraMsg(msg)
      if (auroraMsg.msgType === undefined) {
        return
      }

      auroraMsg.status = 'send_going'
      AuroraIController.appendMessages([auroraMsg])
      AuroraIController.scrollToBottom(true)
      this.setMessageTarget(msg)
      Alert.alert('send text', JSON.stringify(msg))

      msg.messageSendingOptions = {
        needReadReceipt: true,
        isShowNotification:  true,
        isRetainOffline:  true,
        isCustomNotificationEnabled:  true,
        notificationTitle: "Title Test",
        notificationText: "context"
      };

      JMessage.sendMessage(msg, (jmessage) => {
        var auroraMsg = this.convertJMessageToAuroraMsg(jmessage)
        AuroraIController.updateMessage(auroraMsg)
        console.log('JS sendMessage success:'+JSON.stringify(jmessage))
      }, (error) => {
        console.log('JS sendMessage error:'+JSON.stringify(error))
      })

      // 这里的路径以android为例
      var userName = "";
      var appKey = "";
      var videoFilePath = "sdcard/DCIM/1.mp4";
      var videoFileName = "xxxxxx";
      var videoImagePath = "sdcard/DCIM/1.png";
      var videoImageFormat = "png";
      var videoDuration = 10;
      // JMessage.sendVideoMessage({'type': 'single','username': userName,'appKey': appKey,
      //       "path":videoFilePath,"name":videoFileName,"thumbPath":videoImagePath,"thumbFormat":videoImageFormat,"duration":videoDuration},
      //       (msg) => {
      //           console.log("sendVideo success");
      //       },(error) => {
      //           console.log("sendVideo error:"+error.description);
      //       });

    })
  }

  onTakePicture = (media) => {
    console.log("onTakePicture, path: " + media)
    var message = this.getNormalMessage()
    message.messageType = "image"
    message.path = media.mediaPath

    JMessage.createSendMessage(message, (msg) => {
      var auroraMsg = this.convertJMessageToAuroraMsg(msg)
      auroraMsg.status = 'send_going'
      AuroraIController.appendMessages([auroraMsg])
      AuroraIController.scrollToBottom(true)
      this.setMessageTarget(msg)
      JMessage.sendMessage(msg, (jmessage) => {
        var auroraMsg = this.convertJMessageToAuroraMsg(jmessage)
        AuroraIController.updateMessage(auroraMsg)
      }, (error) => {
        Alert.alert(`send image fail ${JSON.stringify(error)}`)
      })
    })
  }

  onStartRecordVoice = (e) => {
    console.log("on start record voice")
  }

  onFinishRecordVoice = (mediaPath) => {
    Alert.alert('onFinishRecordVoice', JSON.stringify(mediaPath))
    var message = this.getNormalMessage()
    message.messageType = "voice"
    message.path = mediaPath

    JMessage.createSendMessage(message, (msg) => {
      var auroraMsg = this.convertJMessageToAuroraMsg(msg)
      auroraMsg.status = 'send_going'
      AuroraIController.appendMessages([auroraMsg])
      AuroraIController.scrollToBottom(true)
      this.setMessageTarget(msg)
      JMessage.sendMessage(msg, (jmessage) => {
        var auroraMsg = this.convertJMessageToAuroraMsg(jmessage)
        AuroraIController.updateMessage(auroraMsg)
      }, (error) => {
        Alert.alert(`send image fail ${JSON.stringify(error)}`)
      })
    })
  }

  onCancelRecordVoice = () => {
    console.log("on cancel record voice")
  }

  onStartRecordVideo = () => {
    console.log("on start record video")
  }

  onFinishRecordVideo = (video) => {
    var message = this.getNormalMessage()
    message.messageType = "file"
    message.extras = {fileType: 'video'}
    message.path = video.mediaPath

    JMessage.createSendMessage(message, (msg) => {
      var auroraMsg = this.convertJMessageToAuroraMsg(msg)
      auroraMsg.status = 'send_going'
      AuroraIController.appendMessages([auroraMsg])
      AuroraIController.scrollToBottom(true)
      this.setMessageTarget(msg)

      JMessage.sendMessage(msg, (jmessage) => {
        var auroraMsg = this.convertJMessageToAuroraMsg(jmessage)
        AuroraIController.updateMessage(auroraMsg)
      }, (error) => {
        Alert.alert(`send image fail ${JSON.stringify(error)}`)
      })
    })
  }

  onSendGalleryFiles = (mediaFiles) => {
    for (index in mediaFiles) {
      Alert.alert('onSendGalleryFiles',JSON.stringify(mediaFiles[index]['mediaPath']))
      var message = this.getNormalMessage()
      message.messageType = "image"
      message.path = mediaFiles[index].mediaPath

      JMessage.createSendMessage(message, (msg) => {
        var auroraMsg = this.convertJMessageToAuroraMsg(msg)
        auroraMsg.status = 'send_going'
        AuroraIController.appendMessages([auroraMsg])
        AuroraIController.scrollToBottom(true)
        this.setMessageTarget(msg)
        JMessage.sendMessage(msg, (jmessage) => {
          var auroraMsg = this.convertJMessageToAuroraMsg(jmessage)
          AuroraIController.updateMessage(auroraMsg)
        }, (error) => {
          Alert.alert(`send image fail ${JSON.stringify(error)}`)
        })
      })
    }
  }

  onSwitchToMicrophoneMode = () => {
    AuroraIController.scrollToBottom(true)
  }

  onSwitchToGalleryMode = () => {
    AuroraIController.scrollToBottom(true)
  }

  onSwitchToCameraMode = () => {
    AuroraIController.scrollToBottom(true)
  }

  onShowKeyboard = (keyboard_height) => {
    var inputViewHeight = keyboard_height + 86
    this.updateLayout({ width: window.width, height: inputViewHeight, })
  }

  onSwitchToEmojiMode = () => {
    AuroraIController.scrollToBottom(true)
  }

  onInitPress() {
    console.log('on click init push');
    this.updateAction();
  }

  render() {
    return (
      <View style={styles.container}>
        <MessageListView style={this.state.messageListLayout}
          ref="MessageList"
          onAvatarClick={this.onAvatarClick}
          onMsgClick={this.onMsgClick}
          onMsgLongClick={this.onMsgLongClick}
          onStatusViewClick={this.onStatusViewClick}
          onTouchMsgList={this.onTouchMsgList}
          onTapMessageCell={this.onTapMessageCell}
          onBeginDragMessageList={this.onBeginDragMessageList}
          onPullToRefresh={this.onPullToRefresh}
          avatarSize={{ width: 40, height: 40 }}
          sendBubbleTextSize={18}
          sendBubbleTextColor={"#000000"}
          sendBubblePadding={{ left: 10, top: 10, right: 15, bottom: 10 }}
        />
        <InputView style={this.state.inputViewLayout}
          ref="ChatInput"
          menuContainerHeight={this.state.menuContainerHeight}
          isDismissMenuContainer={this.state.isDismissMenuContainer}
          onSendText={this.onSendText}
          onTakePicture={this.onTakePicture}
          onStartRecordVoice={this.onStartRecordVoice}
          onFinishRecordVoice={this.onFinishRecordVoice}
          onCancelRecordVoice={this.onCancelRecordVoice}
          onStartRecordVideo={this.onStartRecordVideo}
          onFinishRecordVideo={this.onFinishRecordVideo}
          onSendGalleryFiles={this.onSendGalleryFiles}
          onSwitchToEmojiMode={this.onSwitchToEmojiMode}
          onSwitchToMicrophoneMode={this.onSwitchToMicrophoneMode}
          onSwitchToGalleryMode={this.onSwitchToGalleryMode}
          onSwitchToCameraMode={this.onSwitchToCameraMode}
          onShowKeyboard={this.onShowKeyboard}
          onTouchEditText={this.onTouchEditText}
          onFullScreen={this.onFullScreen}
          onRecoverScreen={this.onRecoverScreen}
          onSizeChange={this.onInputViewSizeChange}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  inputView: {
    backgroundColor: 'green',
    width: window.width,
    height: 100,

  },
  btnStyle: {
    marginTop: 10,
    borderWidth: 1,
    borderColor: '#3e83d7',
    borderRadius: 8,
    backgroundColor: '#3e83d7'
  }
});

