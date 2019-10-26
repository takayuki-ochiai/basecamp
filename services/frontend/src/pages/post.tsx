// withRouterはNext.jsのルーターをプロパティとして注入するもの
import { withRouter } from "next/router";
// withRouterによって渡されるルーターのプロパティの型定義
import { WithRouterProps } from "next/dist/client/with-router";
import Layout from "../components/mylayout";

const Page = withRouter((props: WithRouterProps) => (
  <Layout>
    <h1>{props.router.query.title}</h1>
    <p>This is the blog post content.</p>
  </Layout>
));

export default Page;
