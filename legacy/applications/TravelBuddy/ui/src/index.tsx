import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';
import Root from "./Root";
import * as Config from './config.json'

interface Dictionary<T> {[key: string]: T;}
const env: Dictionary<string> = Object.values(Config)[0];

console.log(`env: ${env}`);

export const AppConfig = {
    api_endpoint_url_prefix: env.api_endpoint_url_prefix
}

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  // <React.StrictMode>
    <Root />
  // </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
