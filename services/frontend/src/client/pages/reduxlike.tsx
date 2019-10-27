import React, { useReducer, useContext, Dispatch, ReactElement } from "react";
import { NextPage } from "next";

type CounterState = {
  count: number;
};
const initialState: CounterState = { count: 0 };

// action typeとActionCreatorを同時に準備する
const Increment = "Increment" as const;
const increment = () => ({ type: Increment });

const Reset = "Reset" as const;
const reset = () => ({ type: Reset });

const Decrement = "Decrement" as const;
const decrement = () => ({ type: Decrement });

type Actions = ReturnType<typeof increment | typeof decrement | typeof reset>;

function reducer(state: CounterState, action: Actions): CounterState {
  switch (action.type) {
    case Reset: {
      return initialState;
    }
    case Increment: {
      return { count: state.count + 1 };
    }
    case Decrement: {
      return { count: state.count - 1 };
    }
    default: {
      return state;
    }
  }
}

const CounterContext = React.createContext<CounterState>(null as any);
const DispatchContext = React.createContext<Dispatch<Actions>>(null as any);

const Counter: React.FC = () => {
  const state = useContext(CounterContext);
  const dispatch = useContext(DispatchContext);
  return (
    <div>
      Count: {state.count}
      <button onClick={() => dispatch(reset())}>Reset</button>
      <button onClick={() => dispatch(increment())}>+</button>
      <button onClick={() => dispatch(decrement())}>-</button>
    </div>
  );
};

type AppProp = { initialCount: number };
const App = ({ initialCount }: AppProp) => {
  const [state, dispatch] = useReducer(reducer, { count: initialCount });
  return (
    <CounterContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        <Counter />
      </DispatchContext.Provider>
    </CounterContext.Provider>
  );
};

const Component: NextPage = () => <App initialCount={0} />;

export default Component;
