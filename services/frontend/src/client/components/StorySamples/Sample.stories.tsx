import React from "react";
import { storiesOf } from "@storybook/react";

type Props = {
  title: string;
};

const Sample = ({ title }: Props) => (
  <>
    <h1>{title}</h1>
  </>
);

storiesOf("Welcome", module).add("to Storybook", () => (
  <Sample title={"hoge"} />
));
