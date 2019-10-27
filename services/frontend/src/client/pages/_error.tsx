import React from "react";
import { NextPageContext } from "next";
import Head from "next/head";
type Props = {
  title: string;
  errorCode: number;
};

const Error = ({ title, errorCode }: Props) => (
  <>
    <Head>
      <title>{title}</title>
    </Head>
    {errorCode}
  </>
);

Error.getInitialProps = async ({ res }: NextPageContext) => {
  return {
    title: `Error: ${res!.statusCode}`,
    errorCode: res!.statusCode
  };
};

export default Error;
