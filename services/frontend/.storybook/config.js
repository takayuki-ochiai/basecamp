import { configure, addDecorator } from "@storybook/react";
import { withInfo } from "@storybook/addon-info";
import { withKnobs } from "@storybook/addon-knobs";
import requireContext from "require-context.macro";

addDecorator(withInfo);
addDecorator(withKnobs);
const req = requireContext(
  "../src/client/components",
  true,
  /.(story|stories).tsx$/
);
configure(req, module);
