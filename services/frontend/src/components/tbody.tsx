import * as React from "react";
import { Rows } from "../data";
import TR from "./tr";

type Props = {
  rows: Rows;
};

const Component: React.FC<Props> = ({ rows }) => (
  <tbody>
    {rows.map(row => (
      <TR key={row.id} {...row} />
    ))}
  </tbody>
);

export default Component;
