import * as React from "react";
// import { NextPage } from "next";
import Link from "next/link";
import Layout from "../components/mylayout";

type PostProps = {
  title: string;
};

const PostLink = ({ title }: PostProps) => (
  <li>
    <Link href={`/post?title=${title}`}>
      <a>{title}</a>
    </Link>
  </li>
);

const Index = () => (
  <Layout>
    <h1>My blog</h1>
    <ul>
      <PostLink title="Hello Next.js" />
      <PostLink title="Learn Next.js is awesome" />
      <PostLink title="Deploy apps with Zeit" />
    </ul>
  </Layout>
);

export default Index;
