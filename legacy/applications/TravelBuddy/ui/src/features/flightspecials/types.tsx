// Define the hotelspecial type.
import {State} from "../../utils/TypeUtils";

export type FlightSpeical = {
    id: number;
    header: string;
    body: string;
    cost: number;
    expiryDate: Date;
    origin: string;
    originCode: string;
    destination: string;
    destinationCode: string;
}

// Define hotelspecial state.
export type FlightSpecialState = {
    flightSpecials: State<FlightSpeical[], Error>;
}
