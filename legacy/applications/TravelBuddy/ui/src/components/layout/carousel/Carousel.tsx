import {Component} from "react";
import {Link} from "react-router-dom";

class Carousel extends Component {
    render() {
        return (
            <>
                {/*Carousel*/}
                <div id="myCarousel" className="carousel slide" data-ride="carousel">
                    {/*// <!-- Indicators -->*/}
                    <ol className="carousel-indicators">
                        <li data-target="#myCarousel" data-slide-to="0" className="active"></li>
                        <li data-target="#myCarousel" data-slide-to="1"></li>
                        <li data-target="#myCarousel" data-slide-to="2"></li>
                    </ol>
                    <div className="carousel-inner" role="listbox">
                        <div className="item active">
                            <img className="first-slide" src="resources/images/IMG_0721.JPG"
                                 alt="First slide" />
                                <div className="container">
                                    <div className="carousel-caption">
                                        <h1 className="dymo">
                                            Red Hot<br />destinations
                                        </h1>
                                        <br />
                                            <p className="dymo">Discover the best Hawaii has to offer with
                                                this all inclusive 28 day tour</p>
                                            <p>
                                                <a className="btn btn-lg btn-primary button-gap" href="#"
                                                   role="button">Find out more</a>
                                            </p>
                                    </div>
                                </div>
                        </div>
                        <div className="item">
                            <img className="second-slide" src="resources/images/IMG_2199.JPG"
                                 alt="Second slide" />
                                <div className="container">
                                    <div className="carousel-caption">
                                        <h1 className="dymo">
                                            Alpaca<br />your bags!
                                        </h1>
                                        <br />
                                            <p className="dymo">
                                                You're off to South America on a 21 day adventure,<br />taking
                                                in all the best Peru has to offer
                                            </p>
                                            <p>
                                                <a className="btn btn-lg btn-primary button-gap" href="#"
                                                   role="button">Tell me more</a>
                                            </p>
                                    </div>
                                </div>
                        </div>
                        <div className="item">
                            <img className="third-slide" src="resources/images/IMG_2428.JPG"
                                 alt="Third slide" />
                                <div className="container">
                                    <div className="carousel-caption">
                                        <h1 className="dymo">
                                            Discover<br />Argentina
                                        </h1>
                                        <br />
                                            <p className="dymo">
                                                From Buenos Aires to the Iguazu Falls,<br />Argentina will
                                                surprise and delight.
                                            </p>
                                            <p>
                                                <a className="btn btn-lg btn-primary button-gap" href="#"
                                                   role="button">Discover Argentina</a>
                                            </p>
                                    </div>
                                </div>
                        </div>
                    </div>
                    <a className="left carousel-control" href="#myCarousel" role="button"
                       data-slide="prev"> <span className="glyphicon glyphicon-chevron-left"
                                                aria-hidden="true"></span> <span className="sr-only">Previous</span>
                    </a> <a className="right carousel-control" href="#myCarousel" role="button"
                            data-slide="next"> <span
                    className="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                    <span className="sr-only">Next</span>
                </a>
                </div>
            </>
        );
    }
}

export default Carousel;
