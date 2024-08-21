import {Component} from "react";

class Main extends Component {
    render() {
        return (
            <>
                <div className="container marketing">
                    {/* Three columns of text below the carousel. */}
                    <div className="row">
                        <div className="col-lg-4">
                            <img className="img-circle" src="resources/images/IMG_0721.JPG"
                                 alt="Generic placeholder image" width="140" height="140" />
                                <h2>Hawaii</h2>
                                <p>Great Deals on Flights &amp; Hotels. Book a Package to
                                    Hawaii. Spa Holidays, Family Holidays, Luxury Holidays, Very Cheap
                                    Holidays, All Inclusive Holidays.</p>
                                <p>
                                    <a className="btn btn-default" href="#" role="button">I want to go!  &raquo;</a>
                                </p>
                        </div>
                        {/*/.col-lg-4*/}
                        <div className="col-lg-4">
                            <img className="img-circle" src="resources/images/IMG_0485.JPG"
                                 alt="Generic placeholder image" width="140" height="140" />
                                <h2>Egypt</h2>
                                <p>Duis mollis, est non commodo luctus, nisi erat porttitor
                                    ligula, eget lacinia odio sem nec elit. Cras mattis consectetur
                                    purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo,
                                    tortor mauris condimentum nibh.</p>
                                <p>
                                    <a className="btn btn-default" href="#" role="button">Sounds awesome!  &raquo;</a>
                                </p>
                        </div>
                        {/*/.col-lg-4*/}
                        <div className="col-lg-4">
                            <img className="img-circle" src="resources/images/IMG_1838.JPG"
                                 alt="Generic placeholder image" width="140" height="140" />
                                <h2>New York</h2>
                                <p>Donec sed odio dui. Cras justo odio, dapibus ac facilisis in,
                                    egestas eget quam. Vestibulum id ligula porta felis euismod semper.
                                    Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum
                                    nibh, ut fermentum massa justo sit amet risus.</p>
                                <p>
                                    <a className="btn btn-default" href="#" role="button">Book me, already!  &raquo;</a>
                                </p>
                        </div>
                        {/*/.col-lg-4*/}
                    </div>
                    {/*/.row*/}

                    {/*START THE FEATURETTES*/}

                    <hr className="featurette-divider" />

                        <div className="row featurette">
                            <div className="col-md-7">
                                <h2 className="featurette-heading">
                                    Lady Liberty Awaits. <span className="text-muted">New York, New York!.</span>
                                </h2>
                                <p className="lead">Donec ullamcorper nulla non metus auctor
                                    fringilla. Vestibulum id ligula porta felis euismod semper.
                                    Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                    Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor
                                    fringilla. Vestibulum id ligula porta felis euismod semper.
                                    Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                    Fusce dapibus, tellus ac cursus commodo.</p>
                            </div>
                            <div className="col-md-5">
                                <img className="featurette-image img-responsive center-block"
                                     src="resources/images/IMG_1838.JPG" />
                            </div>
                        </div>

                        <hr className="featurette-divider" />

                            <div className="row featurette">
                                <div className="col-md-7 col-md-push-5">
                                    <h2 className="featurette-heading">
                                        Natural Wonders. <span className="text-muted">Hawaii at its very best.</span>
                                    </h2>
                                    <p className="lead">Donec ullamcorper nulla non metus auctor
                                        fringilla. Vestibulum id ligula porta felis euismod semper.
                                        Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                        Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor
                                        fringilla. Vestibulum id ligula porta felis euismod semper.
                                        Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                        Fusce dapibus, tellus ac cursus commodo.</p>
                                </div>
                                <div className="col-md-5 col-md-pull-7">
                                    <img className="featurette-image img-responsive center-block"
                                         src="resources/images/IMG_0721.JPG" />
                                </div>
                            </div>

                            <hr className="featurette-divider" />

                                <div className="row featurette">
                                    <div className="col-md-7">
                                        <h2 className="featurette-heading">
                                            Simply Unforgettable. <span className="text-muted">Period.</span>
                                        </h2>
                                        <p className="lead">Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor
                                            fringilla. Vestibulum id ligula porta felis euismod semper.
                                            Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                            Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor
                                            fringilla. Vestibulum id ligula porta felis euismod semper.
                                            Praesent commodo cursus magna, vel scelerisque nisl consectetur.
                                            Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor
                                            fringilla. Vestibulum id ligula porta felis euismod semper.</p>
                                    </div>
                                    <div className="col-md-5">
                                        <img className="featurette-image img-responsive center-block"
                                             src="resources/images/IMG_0485.JPG" />
                                    </div>
                                </div>

                                <hr className="featurette-divider" />

                                {/*/END THE FEATURETTES*/}

                                {/*<img style="margin-bottom:20px" src="qrcodegen/150/AWS%20DevAx!" width=150 height=150>*/}
                </div>
            </>
        )
    }
}

export default Main;
