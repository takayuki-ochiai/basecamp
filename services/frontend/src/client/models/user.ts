export type User = {
  id?: string;
  screenName: string;
  displayName: string | null;
  description: string | null;
  photoUrl: string | null;
  provider: string;
  providerUid: string;
};

export const blankUser: User = {
  screenName: "",
  displayName: null,
  description: null,
  photoUrl: null,
  provider: "google",
  providerUid: "",
};
