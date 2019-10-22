import { NextPage } from "next";
import { rows } from "../data";
import THead from "../components/thead";
import TBody from "../components/tbody";

const Component: NextPage = () => (
  <div>
    <h1>健康に関する調査</h1>
    <table>
      <THead />
      <TBody rows={rows} />
    </table>
  </div>
);
export default Component;
