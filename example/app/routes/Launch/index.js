'use strict';

import React from 'react';
import ReactNative from 'react-native';
import JMessage from 'jmessage-react-plugin';
import Translations from '../../resource/Translations'

const {
    View,
    Text,
    TouchableHighlight,
    StyleSheet,
    Alert,
  } = ReactNative;

  export default class Home extends React.Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
        const { navigate } = this.props.navigation;
        var params = {
              'appkey':"e58a32cb3e4469ebf31867e5",
              'isOpenMessageRoaming': true,
              'isProduction': false
             }
        JMessage.init(params)
        JMessage.getMyInfo((myInfo) => {
            if (myInfo.username) {
                navigate('Home')
                // navigate('MainPage')
                // navigate('ConversationList')
            } else {
                navigate('Login')

                // navigate('Chat')
            }
        })
        JMessage.addSyncOfflineMessageListener((message) => {
            console.log("JS onSyncOffline:"+JSON.stringify(message));
        })

      }

    render() {
        return ( <View ></View> )
    }
  }
