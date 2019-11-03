import React, { useCallback, useContext } from "react";
import App, { AppContext } from "next/app";

// このレイヤーでログイン状態を管理する
import FirebaseApp from "../components/FirebaseApp";
import Link from "next/link";
import * as firebase from "firebase";

import { UserContext, UserDispatchContext, setUser } from "../contexts/user";
import axios from "axios";
import Router from "next/router";

const layoutStyle = {
  margin: 20,
  padding: 20,
  border: "1px solid #DDD"
};

const linkStyle = {
  marginRight: 15
};

const Header = () => {
  const userContext = useContext(UserContext);
  const dispatch = useContext(UserDispatchContext);
  const user = userContext.user;

  const handleLogout = useCallback(() => {
    firebase
      .auth()
      .signOut()
      .then(() => {
        return axios.post("/api/logout");
      })
      .then(() => {
        dispatch(setUser(null));
        Router.push("/");
      });
  }, []);

  // ログイン状態の時だけログアウトボタンを表示する
  return (
    <div>{user !== null && <button onClick={handleLogout}>Logout</button>}</div>
  );
};

const Links = () => {
  const userContext = useContext(UserContext);
  const user = userContext.user;
  return (
    <>
      <Link href="/">
        <a style={linkStyle}>Home</a>
      </Link>
      {user === null && (
        <Link href="/login">
          <a style={linkStyle}>Login</a>
        </Link>
      )}
      <Link href="/childs">
        <a style={linkStyle}>Childs</a>
      </Link>
      <Link href="/about">
        <a style={linkStyle}>About</a>
      </Link>
    </>
  );
};

export default class extends App {
  static async getInitialProps({ Component, ctx }: AppContext) {
    let pageProps = {};
    if (Component.getInitialProps) {
      pageProps = await Component.getInitialProps(ctx);
    }
    return { pageProps };
  }

  render() {
    const { Component, pageProps } = this.props;
    return (
      <FirebaseApp>
        <Header />
        <div style={layoutStyle}>
          <Links />
          <Component {...pageProps} />
        </div>
      </FirebaseApp>
    );
  }
}
