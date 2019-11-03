import React, { useEffect, useRef, useState } from "react";
import Router from "next/router";
import * as firebase from "firebase";
import { FirebaseContext, UserContext } from "../contexts";
import clientCredentials from "../../../config/credentials/app/client";
import axios from "axios";

const FirebaseApp: React.FC = ({ children }) => {
  const [currentUser, setUser] = useState<firebase.User | null>(null);
  const [
    credential,
    setCredential
  ] = useState<firebase.auth.UserCredential | null>(null);

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
    const unsubscribe = auth.onAuthStateChanged(async firebaseUser => {
      if (firebaseUser !== null && currentUser === null) {
        firebaseUser
          .getIdToken()
          .then(idToken => {
            return axios.post("/api/login", { idToken });
          })
          .then(res => {
            setUser(firebaseUser);
          });
      }

      if (firebaseUser === null && currentUser !== null) {
        // 認証情報が空になったらStateのuser情報をnullにする
        return axios.post("/api/logout").then(() => {
          setUser(null);
          // ログアウトしたらトップ画面に戻る
          Router.push("/");
        });
      }
    });
    return unsubscribe;
  }, [currentUser]);

  return (
    <FirebaseContext.Provider value={{ auth }}>
      <UserContext.Provider
        value={{ user: currentUser, credential, setCredential }}
      >
        {children}
      </UserContext.Provider>
    </FirebaseContext.Provider>
  );
};

export default FirebaseApp;
