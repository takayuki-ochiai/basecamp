import React from "react";
// withRouterはNext.jsのルーターをプロパティとして注入するもの
// import { withRouter } from "next/router";
// withRouterによって渡されるルーターのプロパティの型定義
import { WithRouterProps } from "next/dist/client/with-router";
import Layout from "../components/mylayout";
import { NextPage, NextPageContext } from "next";

type Props = {
  title: string;
};

const Page = ({ title }: Props) => (
  <Layout>
    <h1>{title}</h1>
    <p>This is the blog post content.</p>
  </Layout>
);

Page.getInitialProps = async ({ query: { title } }: NextPageContext) => {
  return { title };
};

export default Page;
