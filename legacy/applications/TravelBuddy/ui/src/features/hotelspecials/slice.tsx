import {createSelector, createSlice, nanoid, PayloadAction} from "@reduxjs/toolkit";
import {HotelSpecialState} from "./types";
import {state} from "../../utils/TypeUtils";

export const initialState: HotelSpecialState = {
    hotelSpecials: state.initial([])
}

const reducers = {
    load: (state: HotelSpecialState) => {
        state.hotelSpecials.isLoading = true;
    },
    loadMore: (state: HotelSpecialState) => {
        return state;
    },
    // loadSuccess: (state: { isLoading: boolean; hotelSpecials: any; page: any; }, {payload: {hotelSpecials, nextPage}}: any) => {
    loadSuccess: (state: HotelSpecialState, {payload: {hotelSpecials, nextPage}}: any) => {
        state.hotelSpecials.isLoading = false;
        state.hotelSpecials.data = hotelSpecials;
        console.log(`[loadSuccess] hotelSpecials: ${hotelSpecials}`);
        state.hotelSpecials.page = nextPage;
    },
    // loadFail: (state: { isLoading: boolean; error: any; }, {payload: error}: any) => {
    loadFail: (state: HotelSpecialState, {payload: error}: any) => {
        state.hotelSpecials.isLoading = false;
        state.hotelSpecials.error = error;
    }
}

const slice = createSlice({
    name: 'HotelSpecials',
    initialState: initialState,
    reducers: reducers
});

const selectLoadingState = createSelector(
    (state: HotelSpecialState) => state.hotelSpecials.isLoading,
    (isLoading) => isLoading
);

const selectHotelSpecials = createSelector(
    (state: HotelSpecialState) => state.hotelSpecials.data,
    (hotelSpecials) => hotelSpecials
);

const selectError = createSelector(
    (state: HotelSpecialState) => state.hotelSpecials.error,
    (error) => error
);

const selectPage = createSelector(
    (state: HotelSpecialState) => state.hotelSpecials.page,
    (page) => page
)

const selectAllState = createSelector(
    selectLoadingState,
    selectHotelSpecials,
    selectError,
    (isLoading, hotelSpecials, error) => {
        return {isLoading, hotelSpecials, error};
    }
)

export const hotelSpecialsSelector = {
    isLoading: (state: { [x: string]: HotelSpecialState; }) => selectLoadingState(state[HOTELSPECIALS]),
    hotelSpecials: (state: { [x: string]: HotelSpecialState; }) => selectHotelSpecials(state[HOTELSPECIALS]),
    error: (state: { [x: string]: HotelSpecialState; }) => selectError(state[HOTELSPECIALS]),
    all: (state: { [x: string]: HotelSpecialState; }) => selectAllState(state[HOTELSPECIALS]),
    page: (state: { [x: string]: HotelSpecialState; }) => selectPage(state[HOTELSPECIALS]),
}

export const HOTELSPECIALS = slice.name;
export const hotelSpecialsReducer = slice.reducer;
export const hotelSpecialsAction = slice.actions;
