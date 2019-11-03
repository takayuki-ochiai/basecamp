import * as firebase from "firebase";
import { createContext, Dispatch } from "react";
import { User } from "../models/user";

const SetUser = "user/SetUser" as const;
export const setUser = (user: firebase.User | null) => ({
  type: SetUser,
  payload: { user }
});
type Actions = ReturnType<typeof setUser>;

export function userReducer(state: UserState, action: Actions) {
  switch (action.type) {
    case SetUser: {
      return {
        user: action.payload.user
      };
    }
    default: {
      return state;
    }
  }
}

export type UserState = {
  // user: User | null;
  user: firebase.User | null;
};

export const UserContext = createContext<UserState>(null as any);
export const UserDispatchContext = createContext<Dispatch<Actions>>(
  null as any
);
