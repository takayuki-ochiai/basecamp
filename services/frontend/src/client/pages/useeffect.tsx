import React, { useCallback, useEffect, useState } from "react";
import { NextPage } from "next";

const LIMIT = 60;

const Timer: React.FC = () => {
  const [timeLeft, setTimeLeft] = useState(LIMIT);
  const reset = useCallback(() => {
    setTimeLeft(LIMIT);
  }, []);

  const tick = useCallback(() => {
    setTimeLeft((prev) => (prev === 0 ? LIMIT : prev - 1));
  }, []);

  // 第一引数の関数がコンポーネントの初回レンダリング直前に実行される
  // 第二引数が何もない時はレンダリングのたびに第一引数の関数が実行される
  // 第二引数に配列がある時は、配列の内容が変わった時だけ第一引数の関数が実行される
  //  第二引数に空配列が渡された時は第一引数の関数がコンポーネントの初回レンダリング時のみ実行される
  //  第一引数の関数の戻り値の関数はアンマウント時に実行される
  useEffect(() => {
    // 1秒ごとにtick関数を実行する。
    const timerId = setInterval(tick, 1000);

    return () => clearInterval(timerId);
  }, []);

  return (
    <>
      <header>
        <h1>タイマー</h1>
        <div>{timeLeft}</div>
        <button onClick={reset}>リセットボタンよ</button>
      </header>
    </>
  );
};

const Component: NextPage = () => <Timer />;
export default Component;
