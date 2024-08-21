import React from "react";
import {BrowserRouter as Router, Route} from "react-router-dom";
import App from "./App";
import Header from "./components/layout/header/Header";
import {Provider} from "react-redux";
import createStore from "./store";


/**
 * Redux Store 설정 - 로컬 및 배포 분리
 */
const store = createStore();

const Root = () => {
    return (
        <Router>
            <Provider store={store}>
                <Header />
                <App />
            </Provider>
        </Router>
    )
}

export default Root;
