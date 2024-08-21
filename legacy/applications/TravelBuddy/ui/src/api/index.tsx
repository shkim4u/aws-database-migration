import {AppConfig} from "../index";

// const getFlightSpecials = (page = 1) => {
//     const requestOptions = {
//         method: "GET",
//         headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json"
//         },
//     };
//     const url = `${AppConfig.api_endpoint_url_prefix}/flightspecials`;
//     return fetch(url, requestOptions)
//         .then(res => res.json())
//         .catch(err => {
//             throw err;
//         });
// }


const getFlightSpecials = async (page = 1) => {
    const requestOptions = {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
    };
    const url = `${AppConfig.flightspecials_api_endpoint_url}`;
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

// const getHotelSpecials = (page = 1) => {
//     const requestOptions = {
//         method: "GET",
//         headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json"
//         },
//     };
//     const url = `${AppConfig.api_endpoint_url_prefix}/hotelspecials`;
//     return fetch(url, requestOptions)
//         .then(res => res.json())
//         .catch(err => {
//             throw err;
//         });
//
//     /**
//      * Predefined example return.
//      */
//     // return [
//     //     {
//     //         "id": 8,
//     //         "hotel": "Hotel Sandra",
//     //         "description": "Minimum stay two nights",
//     //         "cost": 365,
//     //         "expiryDate": 1694333989162,
//     //         "location": "Cairo"
//     //     },
//     //     {
//     //         "id": 7,
//     //         "hotel": "Sophmore Suites",
//     //         "description": "Maximum 2 people per room",
//     //         "cost": 341,
//     //         "expiryDate": 1694336012905,
//     //         "location": "London"
//     //     },
//     //     {
//     //         "id": 11,
//     //         "hotel": "EasyStay Apartments",
//     //         "description": "Minimum stay one week",
//     //         "cost": 988,
//     //         "expiryDate": 1694336992235,
//     //         "location": "Melbourne"
//     //     },
//     //     {
//     //         "id": 5,
//     //         "hotel": "Classic Hotel",
//     //         "description": "Includes breakfast",
//     //         "cost": 264,
//     //         "expiryDate": 1694338453360,
//     //         "location": "Dallas"
//     //     },
//     //     {
//     //         "id": 6,
//     //         "hotel": "Groundhog Suites",
//     //         "description": "Internet access included",
//     //         "cost": 851,
//     //         "expiryDate": 1694339012470,
//     //         "location": "Florida"
//     //     },
//     //     {
//     //         "id": 3,
//     //         "hotel": "Studio City",
//     //         "description": "Minimum stay one week",
//     //         "cost": 52,
//     //         "expiryDate": 1694341707647,
//     //         "location": "Los Angeles"
//     //     },
//     //     {
//     //         "id": 1,
//     //         "hotel": "Sommerset Hotel",
//     //         "description": "Minimum stay 3 nights",
//     //         "cost": 909,
//     //         "expiryDate": 1694342371600,
//     //         "location": "Sydney"
//     //     },
//     //     {
//     //         "id": 9,
//     //         "hotel": "Apartamentos de Nestor",
//     //         "description": "Pool and spa access included",
//     //         "cost": 428,
//     //         "expiryDate": 1694342534133,
//     //         "location": "Madrid"
//     //     },
//     //     {
//     //         "id": 10,
//     //         "hotel": "Kangaroo Hotel",
//     //         "description": "Maximum 2 people per room",
//     //         "cost": 383,
//     //         "expiryDate": 1694343102275,
//     //         "location": "Manchester"
//     //     },
//     //     {
//     //         "id": 4,
//     //         "hotel": "Le Fleur Hotel",
//     //         "description": "Not available weekends",
//     //         "cost": 747,
//     //         "expiryDate": 1694348050841,
//     //         "location": "Los Angeles"
//     //     },
//     //     {
//     //         "id": 2,
//     //         "hotel": "Freedmom Apartments",
//     //         "description": "Pets allowed!",
//     //         "cost": 88,
//     //         "expiryDate": 1694351694518,
//     //         "location": "Sydney"
//     //     }
//     // ];
// };

export {getFlightSpecials, getHotelSpecials};
