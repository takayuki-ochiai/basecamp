import React from "react";
import { Head, Main, NextScript } from "next/document";
import Link from "next/link";

const layoutStyle = {
  margin: 20,
  padding: 20,
  border: "1px solid #DDD"
};

const linkStyle = {
  marginRight: 15
};

const Layout = () => (
  <html>
    <Head></Head>
    <body>
      <div style={layoutStyle}>
        <Link href="/">
          <a style={linkStyle}>Home</a>
        </Link>
        <Link href="/about">
          <a style={linkStyle}>About</a>
        </Link>
        <Main />
      </div>
      <NextScript />
    </body>
  </html>
);
export default Layout;
