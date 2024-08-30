import {AppConfig} from "../index";

const getFlightSpecials = async (page = 1) => {
    const requestOptions = {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
    };
    const url = `${AppConfig.api_endpoint_url_prefix}/flightspecials`;
    try {
        const res = await fetch(url, requestOptions);
        return await res.json();
    } catch (err) {
        throw err;
    }
}

const getHotelSpecials = async (page = 1) => {
    const requestOptions = {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
    };
    const url = `${AppConfig.api_endpoint_url_prefix}/hotelspecials`;
    try {
        const res = await fetch(url, requestOptions);
        return await res.json();
    } catch (err) {
        throw err;
    }
}

export {getFlightSpecials, getHotelSpecials};
