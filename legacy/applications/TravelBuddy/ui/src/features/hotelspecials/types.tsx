// Define the hotelspecial type.
import {State} from "../../utils/TypeUtils";

export type HotelSpeical = {
    id: number;
    hotel: string;
    description: string;
    location: string;
    cost: number;
    expiryDate: Date;
}

// Define hotelspecial state.
export type HotelSpecialState = {
    hotelSpecials: State<HotelSpeical[], Error>;
}
