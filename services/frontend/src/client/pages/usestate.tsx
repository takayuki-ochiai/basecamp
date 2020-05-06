import React, { useCallback, useState } from "react";
import { NextPage } from "next";

let tmpIncrement: () => void;
let tmpDecrement: () => void;

const Counter: React.FC = () => {
  const [count, setCount] = useState(0);

  // countが変わったらコールバック用関数を作り直す。
  // 状態が変わるたびになんどもコールバック関数を作り直すことになるのでパフォーマンス上よろしくない
  // const increment = useCallback(() => {
  //   setCount(count + 1);
  // }, [count]);
  //
  // const decremnt = useCallback(() => {
  //   setCount(count - 1);
  // }, [count]);

  // 一回作ったら再生成しない
  const increment = useCallback(() => {
    // 前の状態を受け取って次の状態を返却する関数を登録しておけば、ハンドラ関数の再生成はいらなくなる！
    setCount((prev) => prev + 1);
  }, []);
  if (tmpIncrement !== increment) {
    console.log("increment が生成された！");
  }
  tmpIncrement = increment;

  // あえてレンダリングのたびに何度も再生成する書き方に
  const decrement = () => setCount((prev) => prev - 1);
  if (tmpDecrement !== decrement) {
    console.log("decrement が生成された！");
  }

  return (
    <div>
      <h1>カウンター</h1>
      <h3>{count}</h3>
      <button onClick={increment}>+1</button>
      <button onClick={decrement}>-1</button>
    </div>
  );
};

const Component: NextPage = () => <Counter />;
export default Component;
