import React from "react";
import { storiesOf } from "@storybook/react";
import { action } from "@storybook/addon-actions";
import { linkTo } from "@storybook/addon-links";
import { Button, Welcome } from "@storybook/react/demo";

type Props = {
  title: string;
};

const Sample = ({ title }: Props) => (
  <>
    <h1>{title}</h1>
  </>
);

export default {
  title: "showSample",
};

export const showSample = () => (
  <Sample title="なんかいい感じのコンポーネント" />
);
