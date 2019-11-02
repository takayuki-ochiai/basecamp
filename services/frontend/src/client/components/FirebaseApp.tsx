import React, { useEffect, useRef, useState } from "react";
import Router from "next/router";
import * as firebase from "firebase";
import { FirebaseContext, UserContext } from "../contexts";
import clientCredentials from "../../credentials/client";
import axios from "axios";

const FirebaseApp: React.FC = ({ children }) => {
  const [user, setUser] = useState<firebase.User | null>(null);
  const [
    credential,
    setCredential
  ] = useState<firebase.auth.UserCredential | null>(null);

  let auth: firebase.auth.Auth | null = null;
  useEffect(() => {
    // 初回にしかinitializeしないようにする
    firebase.initializeApp(clientCredentials);
    // firebase.auth().setPersistence(firebase.auth.Auth.Persistence.NONE);
    auth = firebase.auth();
    // onAuthStateChangedは自分の返り値でオブザービングの解除関数を返すのでuseEffectの返り値にする
    const unsubscribe = auth.onAuthStateChanged(async firebaseUser => {
      if (firebaseUser) {
        firebaseUser
          .getIdToken()
          .then(idToken => {
            return axios.post("/api/login", { idToken });
          })
          .then(res => {
            setUser(firebaseUser);
          });
      } else {
        // 認証情報が空になったらStateのuser情報をnullにする
        return axios.post("/api/logout").then(() => {
          setUser(null);
          // ログアウトしたらトップ画面に戻る
          // Router.push("/login");
        });
      }
    });
    return unsubscribe;
  }, []);

  return (
    <FirebaseContext.Provider value={{ auth }}>
      <UserContext.Provider value={{ user, credential, setCredential }}>
        {children}
      </UserContext.Provider>
    </FirebaseContext.Provider>
  );
};

export default FirebaseApp;
