import React from "react";
import { NextPage, NextPageContext } from "next";

type Props = {
  title: string;
};

const Page = ({ title }: Props) => (
  <>
    <h1>{title}</h1>
    <p>This is the blog post content.</p>
  </>
);

Page.getInitialProps = async ({ query: { title } }: NextPageContext) => {
  return { title };
};

export default Page;
