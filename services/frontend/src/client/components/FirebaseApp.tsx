import React, { useEffect, useReducer } from "react";
import Router from "next/router";
import * as firebase from "firebase";
import {
  UserContext,
  UserDispatchContext,
  userReducer,
  setUser,
} from "../contexts/user";
import { FirebaseContext } from "../contexts/firebase";
import clientCredentials from "../../../config/credentials/app/client";
import axios from "axios";

const FirebaseApp: React.FC = ({ children }) => {
  const [userState, dispatch] = useReducer(userReducer, {
    user: null,
  });

  const currentUser = userState.user;

  let auth: firebase.auth.Auth | null = null;
  useEffect(() => {
    // 初めてマウントされた時だけinitializeする
    firebase.initializeApp(clientCredentials.fireBase);
  }, []);

  // currentUserの状態が変わったらオブザービングを再設定する
  // currentUserの状態によってfirebaseで管理している認証状態が変わった時にログイン・ログアウトAPIにリクエストを送るかどうかが変わってくるため
  useEffect(() => {
    auth = firebase.auth();
    if (auth == null) return;
    // onAuthStateChangedは自分の返り値でオブザービングの解除関数を返すのでuseEffectの返り値にする
    // onAuthStateChangedはサインインとサインアウトのときのみ発火する
    // 実際にはSSRのたびに初期化されて呼ばれる
    const unsubscribe = auth.onAuthStateChanged(async (firebaseUser) => {
      dispatch(setUser(firebaseUser));
      if (firebaseUser === null && currentUser !== null) {
        // 認証情報が空になったらStateのuser情報をnullにする
        return axios.post("/api/logout").then(() => {
          // ログアウトしたらトップ画面に戻る
          Router.push("/");
        });
      }
    });
    return unsubscribe;
  }, [currentUser]);

  return (
    <FirebaseContext.Provider value={{ auth }}>
      <UserContext.Provider value={userState}>
        <UserDispatchContext.Provider value={dispatch}>
          {children}
        </UserDispatchContext.Provider>
      </UserContext.Provider>
    </FirebaseContext.Provider>
  );
};

export default FirebaseApp;
