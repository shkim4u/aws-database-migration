import React from 'react';
import './App.css';
import {Routes, Route} from "react-router-dom";
import Carousel from "./components/layout/carousel/Carousel";
import SpecialsData from "./components/layout/specialsdata/SpecialsData";
import Main from "./components/layout/main/Main";

function App() {
    return (
        <Routes>
            <Route path="/" element={
                <>
                    <Carousel />
                    <SpecialsData />
                    <Main />
                </>}
            />
        </Routes>
    );
}

export default App;
