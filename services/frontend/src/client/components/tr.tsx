import * as React from "react";
import { Row } from "../../data";

const Component: React.FC<Row> = props => (
  <tr>
    <th>{props.age}</th>
    {props.answers.map((answser, i) => {
      if (answser === null) return <td key={i}>-</td>;
      return <td key={i}>{`${answser * 100}%`}</td>;
    })}
  </tr>
);

export default Component;
