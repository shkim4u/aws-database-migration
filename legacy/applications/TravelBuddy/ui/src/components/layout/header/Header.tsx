import { Component } from "react";
import {Link} from "react-router-dom";

class Header extends Component {
    render() {
        return (
            <>
                {/*NAVBAR*/}
                <div className="navbar-wrapper">
                    <div className="container">

                        <nav className="navbar navbar-inverse navbar-static-top">
                            <div className="container">
                                <div className="navbar-header">
                                    <button type="button" className="navbar-toggle collapsed"
                                            data-toggle="collapse" data-target="#navbar" aria-expanded="false"
                                            aria-controls="navbar">
                                        <span className="sr-only">Toggle navigation</span> <span
                                        className="icon-bar"></span> <span className="icon-bar"></span> <span
                                        className="icon-bar"></span>
                                    </button>
                                    <a className="navbar-brand" href="#">TravelBuddy</a>
                                </div>
                                <div id="navbar" className="navbar-collapse collapse">
                                    <ul className="nav navbar-nav">
                                        <li className="active"><a href="#">Home</a></li>
                                        <li><a href="#contact">Contact</a></li>
                                        <li className="dropdown"><a href="#" className="dropdown-toggle"
                                                                    data-toggle="dropdown" role="button" aria-haspopup="true"
                                                                    aria-expanded="false">My Activity <span className="caret"></span></a>
                                            <ul className="dropdown-menu">
                                                <li><a href="#">Make booking</a></li>
                                                <li><a href="#">Advanced search</a></li>
                                                <li><a href="#">My activity statement</a></li>
                                                <li role="separator" className="divider"></li>
                                                <li className="dropdown-header">Shopping cart</li>
                                                <li><a href="#">Show cart</a></li>
                                                <li><a href="#">Buy all in cart</a></li>
                                            </ul></li>
                                    </ul>
                                </div>
                            </div>
                        </nav>

                    </div>
                </div>
            </>
        );
    }
}

export default Header;
