import { NextPage } from "next";
import React from "react";

type Props = {
  childLabel: string;
};

// React.FC型を付与すると children?: React.ReactNode が自動的に付与される
const ChildComponent: React.FC = (props) => <div>{props.children}</div>;

const Parent: React.FC<Props> = (props) => (
  <ChildComponent>{props.childLabel}</ChildComponent>
);

const Component: NextPage = () => <Parent childLabel={"Child Label!!!"} />;
export default Component;
