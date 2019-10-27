import React from "react";
// import { NextPage } from "next";
import Link from "next/link";

type PostProps = {
  id: string;
  title: string;
};

const PostLink = ({ id, title }: PostProps) => (
  <li>
    <Link as={`/p/${id}`} href={`/post?title=${title}`}>
      <a>{title}</a>
    </Link>
  </li>
);

const Index = () => (
  <>
    <h1>My blog</h1>
    <ul>
      <PostLink id="hello-nextjs" title="Hello Next.js" />
      <PostLink id="learn-nextjs" title="Learn Next.js is awesome" />
      <PostLink id="deploy-nextjs" title="Deploy apps with Zeit" />
    </ul>
  </>
);

export default Index;
