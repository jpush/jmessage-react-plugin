# API

#### Usage

```javascript
import JMessage from 'jmessage-react-plugin';
```

**Note:** API 所用到的所有对象模型（userInf，Group，conversation，message），可以到 [Models](./Models.md) 中查阅。

- [初始化](#初始化)
  - [init](#init)
  - [setDebugMode](#setdebugmode)
  - [setBadge](#setbadge)
- [用户登录、注册及属性维护](#用户登录注册及属性维护)
  - [register](#register)
  - [login](#login)
  - [logout](#logout)
  - [getMyInfo](#getmyinfo)
  - [getUserInfo](#getuserinfo)
  - [updateMyPassword](#updatemypassword)
  - [updateMyAvatar](#updatemyavatar)
  - [updateMyInfo](#updatemyinfo)
  - [downloadThumbUserAvatar](#downloadthumbuseravatar)
  - [downloadOriginalUserAvatar](#downloadoriginaluseravatar)

- [群组](#群组)
  - [createGroup](#creategroup)
  - [dissolveGroup](#dissolvegroup)
  - [getGroupIds](#getgroupids)
  - [getGroupInfo](#getgroupinfo)
  - [updateGroupInfo](#updategroupinfo)
  - [addGroupMembers](#addgroupmembers)
  - [removeGroupMembers](#removegroupmembers)
  - [getGroupMembers](#getGroupMembers)
  - [exitGroup](#exitgroup)
  - [isGroupBlocked](#isGroupBlocked)
  - [getBlockedGroupList](#getBlockedGroupList)
  - [updateGroupAvatar](#updateGroupAvatar)
  - [downloadThumbGroupAvatar](#downloadThumbGroupAvatar)
  - [downloadOriginalGroupAvatar](#downloadOriginalGroupAvatar)
  - [addGroupAdmins](#addgroupadmins)
  - [removeGroupAdmins](#removegroupadmins)
  - [changeGroupType](#changegrouptype)
  - [getPublicGroupInfos](#getpublicgroupinfos)
  - [applyJoinGroup](#applyjoingroup)
  - [processApplyJoinGroup](#processapplyjoingroup)
  - [transferGroupOwner](#transferGroupOwner)
  - [setGroupMemberSilence](#setGroupMemberSilence)
  - [isSilenceMember](#isSilenceMember)
  - [groupSilenceMembers](#groupSilenceMembers)
  - [setGroupNickname](#setGroupNickname)

- [黑名单](#黑名单)
  - [addUsersToBlacklist](#addUsersToBlacklist)
  - [removeUsersFromBlacklist](#removeUsersFromBlacklist)
  - [getBlacklist](#getBlacklist)

- [免打扰](#免打扰)
  - [setNoDisturb](#setNoDisturb)
  - [getNoDisturbList](#getNoDisturbList)
  - [setNoDisturbGlobal](#setNoDisturbGlobal)
  - [isNoDisturbGlobal](#isNoDisturbGlobal)

- [聊天](#聊天)
  - [createSendMessage](#createsendmessage)
  - [sendMessage](#sendmessage)
  - [sendTextMessage](#sendtextmessage)
  - [sendImageMessage](#sendimagemessage)
  - [sendVoiceMessage](#sendvoicemessage)
  - [sendCustomMessage](#sendcustommessage)
  - [sendLocationMessage](#sendlocationmessage)
  - [sendFileMessage](#sendfilemessage)
  - [retractMessage](#retractmessage)
  - [getHistoryMessages](#gethistorymessages)
  - [downloadOriginalImage](#downloadoriginalimage)
  - [downloadThumbImage](#downloadthumbimage)
  - [downloadVoiceFile](#downloadvoicefile)
  - [downloadFile](#downloadfile)
- [会话](#会话)
  - [createConversation](#createconversation)
  - [deleteConversation](#deleteconversation)
  - [enterConversation](#enterconversation)
  - [exitConversation](#exitconversation)
  - [getConversation](#getconversation)
  - [getConversations](#getconversations)
  - [getAllUnreadCount](#getallunreadcount)
  - [resetUnreadMessageCount](#resetunreadmessagecount)
- [聊天室](#聊天室)
  - [getChatRoomListByApp](#getchatroomlistbyapp)
  - [getChatRoomListByUser](#getchatroomlistbyuser)
  - [getChatRoomInfos](#getchatroominfos)
  - [getChatRoomOwner](#getchatroomowner)
  - [enterChatRoom](#enterchatroom)
  - [leaveChatRoom](#leavechatroom)
  - [getChatRoomConversationList](#getchatroomconversationlist)
- [好友](#好友)
  - [sendInvitationRequest](#sendinvitationrequest)
  - [acceptInvitation](#acceptInvitation)
  - [declineInvitation](#declineinvitation)
  - [getFriends](#getfriends)
  - [removeFromFriendList](#removefromfriendlist)
  - [updateFriendNoteName](#updatefriendnotename)
  - [updateFriendNoteText](#updatefriendnotetext)
- [事件监听]()
  - [消息事件](#addreceivemessagelistener)
    - [addReceiveMessageListener](#addreceivemessagelistener)
    - [removeReceiveMessageListener](#addreceivemessagelistener)
    - [addReceiveChatRoomMsgListener](#addreceivechatroommsglistener)
    - [removeReceiveChatRoomMsgListener](#removereceivechatroommsglistener)
  - [已读消息回执](#addReceiptMessageListener)
    - [addReceiptMessageListener](#addReceiptMessageListener)
    - [removeReceiptMessageListener](#removeReceiptMessageListener)
  - [离线消息](#addsyncofflinemessagelistener)
    - [addSyncOfflineMessageListener](#addsyncofflinemessagelistener)
    - [removeSyncOfflineMessageListener](#addsyncofflinemessagelistener)
  - [消息漫游](#addsyncroamingmessagelistener)
    - [addSyncRoamingMessageListener](#addsyncroamingmessagelistener)
    - [removeSyncRoamingMessageListener](#addsyncroamingmessagelistener)
  - [好友请求事件](#addcontactnotifylistener)
    - [addContactNotifyListener](#addcontactnotifylistener)
    - [removeContactNotifyListener](#addcontactnotifylistener)
  - [接收到消息撤回事件](#addmessageretractlistener)
    - [addMessageRetractListener](#addmessageretractlistener)
    - [removeMessageRetractListener](#addmessageretractlistener)
  - [登录状态变更](#addloginstatechangedlistener)
    - [addLoginStateChangedListener](#addloginstatechangedlistener)
    - [removeLoginStateChangedListener](#addloginstatechangedlistener)

  - [监听接收入群申请事件](#addreceiveapplyjoingroupapprovallistener)
    - [addReceiveApplyJoinGroupApprovalListener](#addreceiveapplyjoingroupapprovallistener)
    - [removeReceiveApplyJoinGroupApprovalListener](#removereceiveapplyjoingroupapprovallistener)

  - [监听管理员拒绝入群申请事件](#addreceivegroupadminrejectlistener)
    - [addReceiveGroupAdminRejectListener](#addreceivegroupadminrejectlistener)
    - [removeReceiveGroupAdminRejectListener](#removereceivegroupadminrejectlistener)

  - [监听管理员同意入群申请事件](#addreceivegroupadminapprovallistener)
    - [addReceiveGroupAdminApprovalListener](#addreceivegroupadminapprovallistener)
    - [removeReceiveGroupAdminApprovalListener](#removereceivegroupadminapprovallistener)



- [点击消息通知事件（Android Only）](#addclickmessagenotificationlistener)
    - [addClickMessageNotificationListener](#addclickmessagenotificationlistener)
    - [removeClickMessageNotificationListener](#addclickmessagenotificationlistener)



## 初始化

### init[⬆](#api)
**注意 Android 仍需在 build.gradle 中配置 appKey，具体可以[参考这个文件](https://github.com/jpush/jmessage-react-plugin/blob/dev/example/android/app/build.gradle)**
初始化插件。建议在应用起始页的构造函数中调用。

#### 示例

```javascript
JMessage.init({
  appkey: "换成在极光官网上注册的应用 Appkey",
  isOpenMessageRoaming: false // 是否开启消息漫游，默认不开启
  isProduction: true, // 是否为生产模式
})	
```
#### 参数说明

- appkey：极光官网注册的应用 AppKey。**Android 仍需配置 app 下 build.gradle 中的 AppKey。**
- isOpenMessageRoaming：是否开启消息漫游，不传默认关闭。
- isProduction：是否为生产模式。
- channel：(选填)应用的渠道名称。

### setDebugMode[⬆](#api)

设置是否开启 debug 模式，开启后 SDK 将会输出更多日志信息，推荐在应用对外发布时关闭。

#### 示例

```js
JMessage.setDebugMode({ enable: true })
```
#### 参数说明

- enable：为 true 打开 Debug 模式，false 关闭 Debug 模式。

### setBadge[⬆](#api)

设置 badge 值，该操作会设置本地应用的 badge 值，同时设置极光服务器的 badge 值，收到消息 badge +1 会在极光服务器 badge 的基础上累加。

#### 示例

```javascript
JMessage.setBadge(5, (success) => {})
```

## 用户登录、注册及属性维护

### register[⬆](#api)

用户注册。

#### 示例

```javascript
// 注册
JMessage.register({
  username: "登录用户名",
  password: "登录密码"
}， () => {/*注册成功回调*/}, (error) => {/*注册失败回调*/})
```

#### 参数说明

- username: 用户名。在应用中用于唯一标识用户，必须唯一。支持以字母或者数字开头，支持字母、数字、下划线、英文点（.）、减号、@。长度限制：Byte(4~128)。
- password: 用户密码。不限制字符。长度限制：Byte(4~128)。

### login[⬆](#api)

```javascript
// 登录
JMessage.login({
  username: "登录用户名",
  password: "登录密码"
}，() => {/*登录成功回调*/}, (error) => {/*登录失败回调*/})
```

#### 参数说明

- username: 用户名。
- password: 用户密码。

### logout[⬆](#api)

用户登出。

#### 示例

```js
JMessage.logout()
```

### getMyInfo[⬆](#api)

获取当前登录用户信息。如果未登录会返回空对象。可以用于判断用户登录状态

关于 UserInfo 的构成，可以查看 [Models 文档](./Models.md)。

#### 示例

```js
JMessage.getMyInfo((UserInf) => {
	if (UserInf.username === undefine) {
      // 未登录
	} else {
      // 已登录
	}
})
```

### getUserInfo[⬆](#api)

获取用户信息。该接口可以获取不同 AppKey 下（即不同应用）的用户信息，如果 AppKey 为空，则默认为当前应用下。

#### 示例

```js
JMessage.getUserInfo({ username: 'username', appKey: 'your_app_key' },
  (userInfo) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```
### updateMyPassword[⬆](#api)

更新当前登录用户的密码。

#### 示例

```js
JMessage.updateMyPassword({ oldPwd: 'old_password', newPwd: 'new_password' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

### updateMyAvatar[⬆](#api)

更新当前登录用户的头像。

#### 示例

```js
JMessage.updateMyAvatar({ imgPath: 'img_local_path' },
  () => {
    // success do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- imgPath: 本地图片文件的绝对路径地址。注意在 Android 6.0 及以上版本系统中，需要动态请求 `WRITE_EXTERNAL_STORAGE` 权限。
  两个系统中的图片路径分别类似于：
  - Android：`/storage/emulated/0/DCIM/Camera/IMG_20160526_130223.jpg`
  - iOS：`/var/mobile/Containers/Data/Application/7DC5CDFF-6581-4AD3-B165-B604EBAB1250/tmp/photo.jpg`

### updateMyInfo[⬆](#api)

更新当前登录用户信息。包括了：昵称（nickname）、生日（birthday）、个性签名（signature）、性别（gender）、地区（region）和具体地址（address）。

#### 示例

```js
JMessage.updateMyInfo({ nickname: 'nickname' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- nickname: 昵称。不支持字符 "\n" 和 "\r"；长度限制：Byte (0~64)。
- birthday: (Number)生日日期的毫秒数。
- gender: 必须为 'male', 'female' 和 'unknown' 中的一种。
- 其余都为 `string` 类型，支持全部字符串；长度限制为 Byte (0~250)。

### downloadThumbUserAvatar[⬆](#api)

下载用户头像缩略图。

#### 示例

```javascript
const param = {
  username: 'theUserName'，
  appKey: 'you appKey'
}
JMessage.downloadThumbUserAvatar(param, (result) => {}, (err) => {})
```

#### 参数说明：

- param (object):
  - username (string): 用户名
  - appKey (string): 
- result (object):
  - username (string): 用户名
  - appKey (string):
  - filePath (string): 下载后的图片路径

### downloadOriginalUserAvatar[⬆](#api)

下载用户头像原图。

#### 示例

```javascript
const param = {
  username: 'theUserName'，
  appKey: 'you appKey'
}
JMessage.downloadThumbUserAvatar(param, (result) => {}, (err) => {})
```

#### 参数说明：

- param (object):
  - username (string): 用户名
  - appKey (string): 
- result (object):
  - username (string): 用户名
  - appKey (string):
  - filePath (string): 下载后的图片路径

## 群组

### createGroup[⬆](#api)

创建群组。

#### 示例

```js
JMessage.createGroup({ name: 'group_name', desc: 'group_desc' },
  (groupId) => {  // groupId: 新创建的群组 ID
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- name (string): 群组名。不支持 "\n" 和 "\r" 字符，长度限制为 0 ~ 64 Byte。
- groupType (string): 指定创建群的类型，可以为 'private' 和 'public', 默认为 private。
- desc (string): 群组描述。长度限制为 0 ~ 250 Byte。


### dissolveGroup[⬆](#api)

解散群

#### 示例
```js
JMessage.dissolveGroup({ groupId: 'group_id' },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 要解散的群组 id。

### getGroupIds[⬆](#api)

获取当前用户群组

#### 示例
```js
JMessage.getGroupIds(
  (result) => {
    /**
     * result {Array[Number]} 当前用户所加入的群组的groupID的list
     */
  }, (error) => {
    /**
     * error {Object} {code:Number,desc:String}
     */
  }
)
```

#### 参数说明

无

### getGroupInfo[⬆](#api)

根据群组id获取群组信息

#### 示例

```js
JMessage.getGroupInfo(
  { id: "1234567" },
  (result) => {
    /**
     * result {Object} 群组信息
        {
          desc:""
          id:"1234567"
          isBlocked:false
          isNoDisturb:false
          level:0
          maxMemberCount:500
          name:"China no 1"
          owner:"1234"
          ownerAppKey:"abcdef..."
          type:"group" // or single
        }
     */
  }, (error) => {
    /**
     * error {Object} {code:Number,desc:String}
     */
  }
)
```

#### 参数说明

- id(string): 指定群组

### updateGroupInfo[⬆](#api)

更新群组信息。

#### 示例

```js
JMessage.updateGroupInfo({ id: 'groupId' ,newName: 'group_name', newDesc: 'group_desc' },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- id (string): 指定操作的群 groupId
- newName (string): 群组名。不支持 "\n" 和 "\r" 字符，长度限制为 0 ~ 64 Byte。
- newDesc (string): 群组描述。长度限制为 0 ~ 250 Byte。

### addGroupMembers[⬆](#api)

批量添加群成员

#### 示例
```js
JMessage.addGroupAdmins({ id: 'group_id', usernameArray: ['ex_username1', 'ex_username2'], appKey: 'appkey' },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId
- usernameArray (array<string>): 被添加的的用户名数组。
- appKey: 被添加用户所属应用的 AppKey。如果不填，默认为当前应用。

### removeGroupMembers[⬆](#api)

批量删除群成员

#### 示例
```js
JMessage.removeGroupMembers({ id: 'group_id', usernameArray: ['ex_username1', 'ex_username2'], appKey: 'appkey' },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId
- usernameArray (array<string>): 被添加的的用户名数组。
- appKey: 被添加用户所属应用的 AppKey。如果不填，默认为当前应用。

### getGroupMembers[⬆](#api)

获取群组成员列表

#### 示例
```js
JMessage.getGroupMembers({ id: 'group_id'},
  (groupMemberInfoArray) => {  // 群成员数组
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId

### exitGroup[⬆](#api)

退出群组

#### 示例
```js
JMessage.exitGroup({ id: 'group_id'},
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId

### isGroupBlocked[⬆](#api)

查询指定群组是否被屏蔽

#### 示例
```js
JMessage.isGroupBlocked({ id: 'group_id'},
  (result) => {  
    var isBlocked = result.isBlocked

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId

### getBlockedGroupList[⬆](#api)

获取被当前登录用户屏蔽的群组列表

#### 示例
```js
JMessage.getBlockedGroupList((groupArr) => {  
    for (groupInfo in groupArr) {
      // do something.
    }
  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

### updateGroupAvatar[⬆](#api)

 更新指定群组头像

#### 示例
```js
JMessage.updateGroupAvatar({ id: 'group_id'，imgPath:'newAvatar.jpg'},
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId
- imgPath (string): 本地图片绝对路径

### downloadThumbGroupAvatar[⬆](#api)

 下载群组头像缩略图，如果已经下载，不会重复下载。

#### 示例
```js
JMessage.downloadThumbGroupAvatar({ id: 'group_id'},
  (result) => {  
     var id = result.id
     var filePath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId

### downloadOriginalGroupAvatar[⬆](#api)

 下载群组头像原图，如果已经下载，不会重复下载。

#### 示例
```js
JMessage.downloadOriginalGroupAvatar({ id: 'group_id'},
  (result) => {  
     var id = result.id
     var filePath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- id (string): 指定操作的群 groupId

#### 返回值说明
- groupArr: GroupInfo 数组

### addGroupAdmins[⬆](#api)

批量添加管理员

#### 示例
```js
JMessage.addGroupAdmins({ groupId: 'group_id', usernames: ['ex_username1', 'ex_username2'] },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- usernames (array<string>): 被添加的的用户名数组。

### removeGroupAdmins[⬆](#api)

批量删除管理员

#### 示例
```js
JMessage.removeGroupAdmins({ groupId: 'group_id', usernames: ['ex_username1', 'ex_username2'] },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- usernames (array<string>): 被移除的的用户名数组。

### changeGroupType[⬆](#api)

修改群类型

#### 示例
```js
JMessage.changeGroupType({ groupId: 'group_id', type: 'public' },
  () => {  // 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- type (string): 要修改的类型可以为如下值  'private' | 'public'

### getPublicGroupInfos[⬆](#api)

分页获取指定 appKey 下的共有群

#### 示例
```js
JMessage.getPublicGroupInfos({ appKey: 'my_appkey', start: 0, count: 20 },
  (groudArr) => {  //group = [{GroupInfo}] 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- appKey (string): 获取指定 appkey
- start (int): 开始的位置
- count (int): 获取的数量

### applyJoinGroup[⬆](#api)

申请入群（公开群）

#### 示例
```js
JMessage.applyJoinGroup({ groupId: 'group_id', reason: 'Hello I from ...' },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

### processApplyJoinGroup[⬆](#api)

批量处理入群（公开群）申请

#### 示例
```js
JMessage.processApplyJoinGroup({ events: ['ex_event_id_1', 'ex_event_id_2'], reason: 'Hello I from ...' },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- events (array<string>): eventId 数组,当有用户申请入群的时候(或者被要求)会回调一个 event(通过 addReceiveApplyJoinGroupApprovalListener 监听)，每个 event 会有个 id，用于审核入群操作。
- reason (string): 入群理由。

### transferGroupOwner[⬆](#api)

移交群主

#### 示例
```js
JMessage.transferGroupOwner({ groupId: 'group_id', username: 'ex_username', appKey: 'ex_appKey'},
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- username (string): 待移交者用户名。
- appKey (string): 待移交者 appKey, 若传入空则默认使用本应用 appKey。

### setGroupMemberSilence[⬆](#api)

设置禁言或解禁用户

#### 示例
```js
JMessage.setGroupMemberSilence({ groupId: 'group_id', username: 'ex_username', appKey: 'ex_appKey'，isSilence: true},
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- username (string): 待移交者用户名。
- appKey (string): 待移交者 appKey, 若传入空则默认使用本应用 appKey。
- isSilence（Boolean）:true 设置禁言， false 取消禁言

### isSilenceMember[⬆](#api)

判断用户是否被禁言

#### 示例
```js
JMessage.isSilenceMember({ groupId: 'group_id', username: 'ex_username', appKey: 'ex_appKey'},
  (result) => {  
    var isSilence =result.isSilence

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- username (string): 待移交者用户名。
- appKey (string): 待移交者 appKey, 若传入空则默认使用本应用 appKey。

### groupSilenceMembers[⬆](#api)

获取群禁言列表 （注意在获取群列表成功后该方法才有效）

#### 示例
```js
JMessage.groupSilenceMembers({ groupId: 'group_id'},
  (groupMemberInfoArray) => {  // 群成员数组
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。

### setGroupNickname[⬆](#api)

设置群成员昵称

#### 示例
```js
JMessage.setGroupNickname({ groupId: 'group_id', username: 'ex_username', appKey: 'ex_appKey', nickName: "ex_nikename"},
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明
- groupId (string): 指定操作的群 groupId。
- username (string): 待移交者用户名。
- appKey (string): 待移交者 appKey, 若传入空则默认使用本应用 appKey。
- nickName (string): 设置的昵称

## 黑名单

### addUsersToBlacklist[⬆](#api)

批量加入用户到黑名单

#### 示例

```js
JMessage.addUsersToBlacklist({ usernameArray: ['user1', 'user2'], appKey: 'appKey' },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- usernameArray （array<string>）: 待添加的用户名数组。
- appKey (string): 待添加用户所属应用的 AppKey，如果为空或不填，默认为当前应用。

### removeUsersFromBlacklist[⬆](#api)

批量将用户从黑名单中移除

#### 示例

```js
JMessage.removeUsersFromBlacklist({ usernameArray: ['user1', 'user2'], appKey: 'appKey' },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- usernameArray （array<string>）: 待移除的用户名数组。
- appKey (string): 待添加用户所属应用的 AppKey，如果为空或不填，默认为当前应用。

### getBlacklist[⬆](#api)

批量将用户从黑名单中移除

#### 示例

```js
JMessage.getBlacklist((userInfoArray) => {  //黑名单中用户的 UserInfo 数组。
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```


## 免打扰

### setNoDisturb[⬆](#api)

设置对某个用户或群组是否免打扰

#### 示例

```js
JMessage.setNoDisturb({ type: 'single', username: 'username', isNoDisturb: true },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type （string）: 'single' / 'group'，指明是用户还是群组。
- appKey (string): 待添加用户所属应用的 AppKey，如果为空或不填，默认为当前应用。
- username (string): 用户名。当 type 为 'single' 时必填。
- groupId (string): 群组 id。当 type 为 'group' 时必填。
- isNoDisturb (boolean): true: 开启免打扰；false: 关闭免打扰

### getNoDisturbList[⬆](#api)

设置对某个用户或群组是否免打扰

#### 示例

```js
JMessage.getNoDisturbList((result) => {  
    var userInfoArr = result.userInfoArray
    var groupInfoArr = result.groupInfoArray

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 返回值说明

- result：
    - userInfoArray （array<UserInfo>）: 处于免打扰状态的用户信息列表；
    - userInfoArray: 处于免打扰状态的用户信息列表；

### setNoDisturbGlobal[⬆](#api)

设置全局免打扰。

#### 示例

```js
JMessage.setNoDisturbGlobal({ isNoDisturb: true },
  () => {  
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- isNoDisturb (boolean): true: 开启免打扰；false: 关闭免打扰

### isNoDisturbGlobal[⬆](#api)

判断当前是否开启了全局免打扰。

#### 示例

```js
JMessage.isNoDisturbGlobal((result) => {
  var isNoDisturb = result.isNoDisturb


  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 返回值说明

- result 
    - isNoDisturb：是否开启全局免打扰。

## 聊天

### createSendMessage[⬆](#api)

创建消息，创建好消息后需要调用 [sendMessage](#sendmessage) 来发送消息。如果需要状态更新（发送中到发送完成）推荐这种方式，聊天室不支持该接口。

#### 示例

```javascript
JMessage.createSendMessage({type: 'single', username: 'username', appKey: 'appkey', messageType: 'text / image / voice / file / location / custom',text:'message text'}, (message) => {})

// or 
JMessage.createSendMessage({type: 'group', groupId: 'group id', appKey: 'appkey', messageType: 'text / image / voice / file / location / custom',text:'message text'}, (message) => {})
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageType: 不同的消息类型需要不同的字段。
  - messageType = text 时 `text` 为必填。
  - messageType = image 时 `path` 为必填。
  - messageType = voice 时 `path` 为必填。
  - messageType = file 时 `path` 为必填。
  - messageType = location 时 `latitude`   `longitude`  和 `scale` 为必填，`address` 选填。
  - messageType = custom 时 `customObject` 为必填。
- text: 消息内容（文字消息需要该字段）。
- path: 资源文件路径（图片、语言、文件消息需要该字段）。
- latitude：纬度（位置消息需要该字段）。
- longitude：进度（位置消息需要该字段）。
- scale：地图缩放比例（位置消息需要该字段）。
- address：详细地址信息（位置消息需要该字段）。
- customObject：自定义消息键值对（自定义消息需要该字段）。
- extras: 自定义键值对，value 必须为字符串类型，可在所有类型的消息中附加键值对（非必须）。

### sendMessage[⬆](#api)

与 [createSendMessage](#createsendmessage) 配合使用，用于发送创建好的消息。

#### 示例

```javascript
JMessage.createSendMessage({type: 'single', username: 'username', appKey: 'appkey', messageType: 'text / image / voice / file / location / custom',text:'message text'}, (message) => {
  JMessage.sendMessage({id: message.id, type: 'single', username: 'username',appKey: 'appKey',}, () => {
    // 成功回调
  }, () => {
    // 失败回调
  })
})
```

#### 参数

- id: 创建好的 message id。
- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。


- messageSendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。
  - needReadReceipt: 设置这条消息的发送是否需要对方发送已读回执 开启之后，对方收到消息后，如果调用了setMsgHaveRead()接口， 则作为消息发送方，会收到已读消息回执事件通知

### sendTextMessage[⬆](#api)

发送文本消息。

#### 示例

```js
JMessage.sendTextMessage({ type: 'single', username: 'username', appKey: 'appKey',
  text: 'hello world', extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendTextMessage({ type: 'group', groupId: 'target_group_id', text: 'hello world',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。
- text: 消息内容。
- extras: 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendImageMessage[⬆](#api)

发送图片消息，在收到消息时 SDK 默认会自动下载缩略图，如果要下载原图，需调用 `downloadOriginalImage` 方法。

#### 示例

```js
JMessage.sendImageMessage({ type: 'single', username: 'username', appKey: 'appKey',
  path: 'image_path', extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendImageMessage({ type: 'group', groupId: 'target_group_id', path: 'image_path',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- path: 本地图片的绝对路径。格式分别类似为：
  - Android：`/storage/emulated/0/DCIM/Camera/IMG_20160526_130223.jpg`
  - iOS：`/var/mobile/Containers/Data/Application/7DC5CDFF-6581-4AD3-B165-B604EBAB1250/tmp/photo.jpg`
- extras: 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendVoiceMessage[⬆](#api)

发送语音消息，在收到消息时 SDK 默认会自动下载语音文件，如果下载失败（即语音消息文件路径为空），可调用 `downloadVoiceFile` 手动下载。

#### 示例

```js
JMessage.sendVoiceMessage({ type: 'single', username: 'username', appKey: 'appKey',
  path: 'voice_file_path', extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendVoiceMessage({ type: 'group', groupId: 'target_group_id', path: 'voice_file_path',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- path: 本地音频文件的绝对路径。
- extras: 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendCustomMessage[⬆](#api)

发送自定义消息。

#### 示例

```js
JMessage.sendCustomMessage({ type: 'single', username: 'username', appKey: 'appKey',
  customObject: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendCustomMessage({ type: 'group', groupId: 'target_group_id', path: 'voice_file_path',
  customObject: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- customObject: 自定义键值对，`value` 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendLocationMessage[⬆](#api)

发送地理位置消息，通常需要配合地图插件使用。

#### 示例

```js
JMessage.sendLocationMessage({ type: 'single', username: 'username', appKey: 'appKey',
  latitude: 22.54, longitude: 114.06, scale:1, address: '深圳市',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendLocationMessage({ type: 'group', groupId: 'target_group_id',
  latitude: 22.54, longitude: 114.06, scale:1, address: '深圳市',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- latitude: 纬度。
- longitude: 经度。
- scale: 地图缩放比例。
- address: 详细地址。
- extras: 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendFileMessage[⬆](#api)

发送文件消息。对方在收到文件消息时 SDK 不会自动下载，下载文件需手动调用 `downloadFile` 方法。

#### 示例

```js
JMessage.sendFileMessage({ type: 'single', username: 'username', appKey: 'appKey',
  path: 'file_path', extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })

// or

JMessage.sendFileMessage({ type: 'group', groupId: 'target_group_id', path: 'file_path',
  extras: {key1: 'value1'}, messageSendingOptions: JMessage.messageSendingOptions },
  (msg) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。
- path: 本地文件的绝对路径。
- extras: 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数（只对 Android 生效）。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### retractMessage[⬆](#api)

消息撤回。调用后被撤回方会收到一条 `retractMessage` 事件。并且双方的消息内容将变为不可见。

#### 示例

```js
JMessage.retractMessage({type: 'single', username: 'username', appKey: 'appKey',
  messageId: 'target_msg_id'},
  () => {
   // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 要撤回的消息 id。

### getHistoryMessages[⬆](#api)

从最新的消息开始获取历史消息。

#### 示例

```js
JMessage.getHistoryMessages({ type: 'single', username: 'username',
  appKey: 'appKey', from: 0, limit: 10 },
  (msgArr) => { // 以参数形式返回消息对象数组
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- from: 第一条消息对应的下标，起始为 0。
- limit: 消息数。当 from = 0 并且 limit = -1 时，返回所有的历史消息。
- isDescend: 是否降序（消息时间戳从大到小排序），默认为 false。

### downloadOriginalImage[⬆](#api)

下载图片消息原图。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```js
JMessage.downloadOriginalImage({ type: 'single', username: 'username',
  messageId: 'target_msg_id' },
  (result) => {
    var msgId = result.messageId
    var imgPath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 图片消息 id。

### downloadThumbImage[⬆](#api)

下载图片消息缩略图。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```js
JMessage.downloadThumbImage({ type: 'single', username: 'username',
  messageId: 'target_msg_id' },
  (result) => {
    var msgId = result.messageId
    var imgPath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 图片消息 id。

### downloadVoiceFile[⬆](#api)

下载语音文件。如果已经下载，会直接返回本地文件路径，不会重复下载。

### 示例

```js
JMessage.downloadVoiceFile({ type: 'single', username: 'username',
  messageId: 'target_msg_id' },
  (result) => {
    var msgId = result.messageId
    var imgPath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 语音消息 id。

### downloadFile[⬆](#api)

下载文件。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```js
JMessage.downloadFile({ type: 'single', username: 'username',
  messageId: 'target_msg_id' },
  (result) => {
    var msgId = result.messageId
    var imgPath = result.filePath

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 文件消息 id。

## 会话

### createConversation[⬆](#api)

创建 [会话](./Models.md)。

#### 示例

```js
JMessage.createConversation({ type: 'single', username: 'username', appKey: 'appKey' },
  (conversation) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。

### deleteConversation[⬆](#api)

删除聊天会话，同时也会删除本地聊天记录。

#### 示例

```js
JMessage.deleteConversation({ type: 'single', username: 'username', appKey: 'appKey' },
  (conversation) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
 )
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。

### enterConversation[⬆](#api)

**(Android only)** 进入聊天会话。当调用后，该聊天会话的消息将不再显示通知。

iOS 默认应用在前台时，就不会显示通知。

#### 示例

```js
JMessage.enterConversation({ type: 'single', username: 'username', appKey: 'appKey' },
  (conversation) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
 )
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。

### exitConversation[⬆](#api)

**(Android only)** 退出当前聊天会话。调用后，聊天会话之后的相关消息通知将会被触发。

#### 示例

```js
JMessage.exitConversation();
```

### getConversation[⬆](#api)

获取[聊天会话对象](./Models.md)。

#### 示例

```js
JMessage.getConversation({ type: 'single', username: 'username', appKey: 'appKey' },
  (conversation) => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
 )
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。

### getConversations[⬆](#api)

从本地数据库获取会话列表。默认按照会话的最后一条消息时间降序排列。

#### 示例

```js
JMessage.getConversations((conArr) => { // conArr: 会话数组。
  // do something.

}, (error) => {
    var code = error.code
    var desc = error.description
})
```

### getAllUnreadCount[⬆](#api)

当前用户所有会话的未读消息总数

- ⚠️  截止jmessage-sdk-2.6.1 返回的数量为会话列表的未读总数即包括了被移除的群组、好友的未读.

#### 示例

```js
JMessage.getAllUnreadCount(
  (result) => {
    /**
     * result {Number} 当前用户所有会话的未读消息总数
     */
  }
)
```

#### 参数说明

无

### resetUnreadMessageCount[⬆](#api)

重置会话的未读消息数。

#### 示例

```js
JMessage.resetUnreadMessageCount({ type: 'single', username: 'username', appKey: 'appKey' },
  (conversation) => { 
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
 )
```

#### 参数说明

- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。

### setMsgHaveRead[⬆](#api)

设置消息已读

#### 示例

```js
JMessageModule.setMsgHaveRead(params,(result) =>{
        var code = result.code
        var desc = result.description
        },(error) => {
        var code = error.code
        var desc = error.description
    }
)
```

#### 参数说明
- type: 会话类型。可以为 'single' 或 'group' 或 'chatRoom'。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- roomId: 对象聊天室 id。当 `type` 为 'chatRoom' 时，`roomId` 为必填。
- id: mssageId。必填，不填则无法设置消息已读

## 聊天室

聊天室的消息不存数据库，不支持获取历史消息，只支持文本消息。进入聊天室即可接收该聊天室的消息，退出则不在接收。

### getChatRoomListByApp[⬆](#api)

查询当前 AppKey 下的聊天室信息。

#### 示例

```js
JMessage.getChatRoomListByApp({ start: 0, count: 5, reason: '请求添加好友'},
  (chatRoomList) => { // chatRoomList 为所有聊天室信息
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- start: 起始位置。
- count: 获得个数。

### getChatRoomListByUser[⬆](#api)

获取当前用户（登录用户）所加入的所有聊天室信息。

#### 示例

```js
JMessage.getChatRoomListByUser((chatRoomList) => { // chatRoomList 为当前用户加入的所有聊天室列表
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

### getChatRoomInfos[⬆](#api)

查询指定 roomId 聊天室信息。

#### 示例

```js
JMessage.getChatRoomInfos({ roomIds: ['Example_RoomId_1'，'Example_RoomId_2']},
  (chatRoomList) => { // chatRoomList 为指定的聊天室列表
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomIds：需要获取聊天室详情的聊天室 id 列表。

### getChatRoomOwner[⬆](#api)

查询指定 roomId 聊天室的所有者。

#### 示例

```js
JMessage.getChatRoomOwner({ roomId: 'Example_RoomId_1'},
  (userInfo) => { // userInfo 为该聊天室的所有者
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomId：需要获取聊天室所有者的聊天室 id。

### enterChatRoom[⬆](#api)

进入聊天室，进入后才能收到聊天室信息及发言。

#### 示例

```js
JMessage.enterChatRoom({ roomId: 'Example_RoomId_1'},
  (conversation) => { // 进入聊天室，会自动创建并返回该聊天室会话信息。
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomId：要进入的聊天室的 id。

### leaveChatRoom[⬆](#api)

离开指定聊天室。

#### 示例

```js
JMessage.leaveChatRoom({ roomId: 'Example_RoomId_1'},
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomId：要离开的聊天室的 id。

### getChatRoomConversationList[⬆](#api)

从本地获取用户的聊天室会话列表，没有则返回为空的列表。

#### 示例

```js
JMessage.getChatRoomConversationList( (conversationList) => { // conversationList 为聊天室会话信息。
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```



## 好友

JMessage 好友模块仅实现对用户好友关系的托管，以及相关好友请求的发送与接收。
除此之外更多的功能，比如仅允许好友间聊天需要开发者自行实现。

### sendInvitationRequest[⬆](#api)

发送添加好友请求，调用后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```js
JMessage.sendInvitationRequest({ username: 'username', appKey: 'appKey', reason: '请求添加好友'},
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- username: 对方用户的用户名。
- appKey: 对方用户所属应用的 AppKey，如果为空则默认为当前应用。
- reason: 申请理由。

### acceptInvitation[⬆](#api)

接受申请好友请求，调用后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```js
JMessage.acceptInvitation({ username: 'username', appKey: 'appKey' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- username: 申请发送用户的用户名。
- appKey: 申请发送用户所在应用的 AppKey。

### declineInvitation[⬆](#api)

拒绝申请好友请求，调用成功后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```js
JMessage.declineInvitation({ username: 'username', appKey: 'appKey', reason: '拒绝理由' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- username: 申请发送用户的用户名。
- appKey: 申请发送用户所在应用的 AppKey。
- reason: 拒绝理由。长度要求为 0 ~ 250 Byte。

### getFriends[⬆](#api)

获取好友列表。

#### 示例

```js
JMessage.getFriends((friendArr) => {  // 好友用户对象数组。
  // do something.

}, (error) => {
    var code = error.code
    var desc = error.description
})
```

### removeFromFriendList[⬆](#api)

删除好友，调用成功后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```js
JMessage.removeFromFriendList({ username: 'username', appKey: 'appKey' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

### updateFriendNoteName[⬆](#api)

更新好友备注名。

#### 示例

```js
JMessage.updateFriendNoteName({ username: 'username', appKey: 'appKey', noteName: 'noteName' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- username: 好友的用户名。
- appKey: 好友所属应用的 AppKey，如果为空默认为当前应用。
- noteName: 备注名。不支持 "\n" 和 "\r" 字符，长度要求为 0 ~ 64 Byte。

### updateFriendNoteText[⬆](#api)

更新用户备注信息。

#### 示例

```js
JMessage.updateFriendNoteText({ username: 'username', appKey: 'appKey', noteText: 'noteName' },
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
 )
```

#### 参数说明

- username: 好友的用户名。
- appKey: 好友所属应用的 AppKey，如果为空默认为当前应用。
- noteText: 备注名。长度要求为 0 ~ 250 Byte。


## 事件监听

### 消息事件

#### addReceiveMessageListener[⬆](#api)

添加消息事件的监听。

##### 示例

```javascript
var listener = (message) => {
  // 收到的消息会返回一个消息对象. 对象字段可以参考对象说明
}

JMessage.addReceiveMessageListener(listener) // 添加监听
JMessage.removeReceiveMessageListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

#### addReceiveChatRoomMsgListener[⬆](#api)

添加聊天室消息事件的监听。

##### 示例

```javascript
var listener = ([message]) => {
  // 收到的消息会返回一个消息列表，列表元素为消息对象. 对象字段可以参考对象说明
}

JMessage.addReceiveChatRoomMsgListene(listener) // 添加监听
JMessage.removeReceiveChatRoomMsgListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```
####  addSyncOfflineMessageListener[⬆](#api)

同步离线消息事件监听。

##### 示例

```javascript
var listener = (result) => {
  // 回调参数 result = {'conversation': {}, 'messageArray': []}，返回离线消息
}

JMessage.addSyncOfflineMessageListener(listener) // 添加监听
JMessage.removeSyncOfflineMessageListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- result
  - conversation：离线消息所在的会话
  - messageArray：指定会话中的离线消息

####  addReceiptMessageListener[⬆](#api)

已读消息回执事件监听。

##### 示例

```javascript
var listener = (result) => {
  // 回调参数 result = {'receiptResult': {}}，返回已读消息回执结果}
# 
JMessage.addReceiptMessageListener(listener) // 添加监听
JMessage.removeReceiptMessageListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- result
  - receiptResult：已读消息回执结果
      - serverMessageId：未回执数被改变的消息的serverMsgId
      - unReceiptCount：未回执数被改变的消息的当前未发送已读回执的人数
      - unReceiptMTime：获取未回执数被改变的消息的未回执人数变更时间
      
#### addSyncRoamingMessageListener[⬆](#api)

同步漫游消息事件监听。

##### 示例

```javascript
var listener = (result) => {
  // 回调参数 result = {'conversation': {}}
}

JMessage.addSyncRoamingMessageListener(listener) // 添加监听
JMessage.removeSyncRoamingMessageListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- result
  - conversation：漫游消息所在的会话。



####  addMessageRetractListener[⬆](#api)

消息撤回事件监听。

##### 示例

```javascript
var listener = (event) => { }

JMessage.addMessageRetractListener(listener) // 添加监听
JMessage.removeMessageRetractListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- event
  - conversation: 会话对象
  - retractedMessage：被撤回的消息对象



#### addClickMessageNotificationListener[⬆](#api)

点击消息通知回调（Android Only，iOS 端可以使用 jpush-react-native 插件的，监听点击推送的事件）。

##### 示例

```javascript
var listener = (message) => { }

JMessage.addClickMessageNotificationListener(listener) // 添加监听
JMessage.removeClickMessageNotificationListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- [message](./Models.md)：直接返回消息对象

### 好友事件

####  addContactNotifyListener[⬆](#api)

好友相关通知事件。

##### 示例

```javascript
var listener = (event) => {
  // 回调参数 event 为好友事件
}

JMessage.addContactNotifyListener(listener) // 添加监听
JMessage.removeContactNotifyListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- event
  - type：'invite_received' / 'invite_accepted' / 'invite_declined' / 'contact_deleted'
  - reason：事件发生的理由，该字段由对方发起请求时所填，对方如果未填则返回默认字符串。
  - fromUsername： 事件发送者的 username。
  - fromUserAppKey： 事件发送者的 AppKey。


### 登录状态事件

#### addLoginStateChangedListener[⬆](#api)

登录状态变更事件，例如在其他设备登录把当前设备挤出，会触发这个事件。

##### 示例

```javascript
var listener = (event) => { }

JMessage.addLoginStateChangedListener(listener) // 添加监听
JMessage.removeMessageRetractListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数

- event
  - type:  'user_password_change' / 'user_logout' / 'user_deleted' / 'user_login_status_unexpected'


#### addUploadProgressListener[⬆](#api)

发送文件（图片、文件）进度回调，该回调会回调多次。

##### 示例

```javascript
var listener = (result) => { }

JMessage.addUploadProgressListener(listener) // 添加监听
JMessage.removeUploadProgressListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数说明

- result
  - messageId：消息 id。
  - progress：上传进度，从 0-1 float 类型。

### 群组事件

#### addReceiveApplyJoinGroupApprovalListener[⬆](#api)

监听接收入群申请事件

##### 示例

```javascript
var listener = (result) => { }

JMessage.addReceiveApplyJoinGroupApprovalListener(listener) // 添加监听
JMessage.removeReceiveApplyJoinGroupApprovalListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数说明

- event
  - eventId (string)：消息 id。
  - groupId (string)：申请入群的 groudId。
  - isInitiativeApply (boolean)：是否是用户主动申请入群，YES：主动申请加入，NO：被邀请加入
  - sendApplyUser ([{UserInfo}])：发送申请的用户
  - reason (string)：入群原因

#### addReceiveGroupAdminRejectListener[⬆](#api)

监听管理员拒绝入群申请事件

##### 示例

```javascript
var listener = (result) => { }

JMessage.addReceiveGroupAdminRejectListener(listener) // 添加监听
JMessage.removeReceiveGroupAdminRejectListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数说明

- result
  - eventId (string): 消息 id。
  - rejectReason (string): 拒绝原因。
  - groupManager ({UserInfo}): 操作的管理员


#### addReceiveGroupAdminApprovalListener[⬆](#api)

监听管理员同意入群申请事件

##### 示例

```javascript
var listener = (result) => { }

JMessage.addReceiveGroupAdminApprovalListener(listener) // 添加监听
JMessage.removeReceiveGroupAdminApprovalListener(listener) // 移除监听(一般在 componentWillUnmount 中调用)
```

##### 回调参数说明

- result
  - isAgreeApply (boolean): 管理员是否同意申请，YES：同意，NO：拒绝.
  - applyEventID (string): 申请入群事件的事件 id.
  - groupId (string): 群 gid.
  - groupAdmin {GroupInfo}: 操作的管理员.
  - users [{UserInfo}]: 申请或被邀请加入群的用户，即：实际入群的用户

