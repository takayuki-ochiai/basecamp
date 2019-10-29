import React, { useEffect, useRef, useState } from "react";
import * as firebase from "firebase";
import "firebase/auth";
import { User } from "../models/user";
import { FirebaseContext, UserContext } from "../contexts";

const FirebaseApp: React.FC = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [
    credential,
    setCredential
  ] = useState<firebase.auth.UserCredential | null>(null);

  const counterRef = useRef(0);
  const auth = firebase.auth();

  // onAuthStateChangedは自分の返り値でオブザービングの解除関数を返すのでuseEffectの返り値にする
  const unsubscribe = auth.onAuthStateChanged(async firebaseUser => {
    // TODO: デバッグ用なのであとで消す
    console.log("call onAuthStateChanged callback!!!");
    console.log(firebaseUser);
    if (firebaseUser) {
      // 認証情報が入ってきた場合、認証情報からユーザー情報を組み立ててStateにセットする
      if (counterRef.current === 1 && credential) {
        // TODO: ユーザー情報をパースするところは別関数にしたい
        // TODO: そもそもユーザー情報として保持する内容の精査をしたい
        const id = firebaseUser.uid;
        const { displayName } = firebaseUser;
        const photoUrl = firebaseUser.photoURL;
        const provider = firebaseUser.providerData[0];
        let providerUid = "";
        let screenName = "";

        let description = "";
        if (credential.additionalUserInfo) {
          if (credential.additionalUserInfo.username) {
            screenName = credential.additionalUserInfo.username;
          }
          if (credential.additionalUserInfo.profile) {
            providerUid = (credential.additionalUserInfo.profile as any).id_str;
            description =
              (credential.additionalUserInfo.profile as any).description || "";
          }
        }
        if (!providerUid || !screenName || !provider) {
          throw new Error("Invalid credential information.");
        }

        const theUser: User = {
          id,
          screenName,
          displayName,
          description,
          photoUrl,
          providerUid,
          provider: provider.providerId
        };
        setUser(theUser);
      }
    } else {
      // 認証情報が空になったらStateのuser情報をnullにする
      setUser(null);
    }
  });

  useEffect(() => {
    // 再レンダリングが発生しても初回にしかユーザー情報を設定しないようにする
    if (credential) counterRef.current += 1;

    return unsubscribe;
  });
  return (
    <FirebaseContext.Provider value={{ auth }}>
      <UserContext.Provider value={{ user, credential, setCredential }}>
        {children}
      </UserContext.Provider>
    </FirebaseContext.Provider>
  );
};
export default FirebaseApp;
