import { NextPage } from "next";
let n: number = 3;
n = 5;

const arr: number[] = [1, 2, 3];

interface User {
  name: string;
  age?: number;
}

const jane: User = { name: "Jane", age: 27 };

const add = (n: number, m: number): number => n + m;
function subtr(n: number, m: number): number {
  return n - m;
}

const Page: NextPage = () => (
  <h1>
    Hello! {jane.name}, {add(5, 3)}
  </h1>
);
export default Page;
