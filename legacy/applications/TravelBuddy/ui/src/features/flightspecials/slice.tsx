import {createSelector, createSlice, nanoid, PayloadAction} from "@reduxjs/toolkit";
import {FlightSpecialState} from "./types";
import {state} from "../../utils/TypeUtils";

export const initialState: FlightSpecialState = {
    flightSpecials: state.initial([])
}

const reducers = {
    load: (state: FlightSpecialState) => {
        state.flightSpecials.isLoading = true;
    },
    loadMore: (state: FlightSpecialState) => {
        return state;
    },
    // loadSuccess: (state: { isLoading: boolean; flightSpecials: any; page: any; }, {payload: {flightSpecials, nextPage}}: any) => {
    loadSuccess: (state: FlightSpecialState, {payload: {flightSpecials, nextPage}}: any) => {
        state.flightSpecials.isLoading = false;
        state.flightSpecials.data = flightSpecials;
        console.log(`[loadSuccess] flightSpecials: ${flightSpecials}`);
        state.flightSpecials.page = nextPage;
    },
    // loadFail: (state: { isLoading: boolean; error: any; }, {payload: error}: any) => {
    loadFail: (state: FlightSpecialState, {payload: error}: any) => {
        state.flightSpecials.isLoading = false;
        state.flightSpecials.error = error;
    }
}

const slice = createSlice({
    name: 'FlightSpecials',
    initialState: initialState,
    reducers: reducers
});

const selectLoadingState = createSelector(
    (state: FlightSpecialState) => state.flightSpecials.isLoading,
    (isLoading) => isLoading
);

const selectFlightSpecials = createSelector(
    (state: FlightSpecialState) => state.flightSpecials.data,
    (flightSpecials) => flightSpecials
);

const selectError = createSelector(
    (state: FlightSpecialState) => state.flightSpecials.error,
    (error) => error
);

const selectPage = createSelector(
    (state: FlightSpecialState) => state.flightSpecials.page,
    (page) => page
)

const selectAllState = createSelector(
    selectLoadingState,
    selectFlightSpecials,
    selectError,
    (isLoading, flightSpecials, error) => {
        return {isLoading, flightSpecials, error};
    }
)

export const flightSpecialsSelector = {
    isLoading: (state: { [x: string]: FlightSpecialState; }) => selectLoadingState(state[FLIGHTSPECIALS]),
    flightSpecials: (state: { [x: string]: FlightSpecialState; }) => selectFlightSpecials(state[FLIGHTSPECIALS]),
    error: (state: { [x: string]: FlightSpecialState; }) => selectError(state[FLIGHTSPECIALS]),
    all: (state: { [x: string]: FlightSpecialState; }) => selectAllState(state[FLIGHTSPECIALS]),
    page: (state: { [x: string]: FlightSpecialState; }) => selectPage(state[FLIGHTSPECIALS]),
}

export const FLIGHTSPECIALS = slice.name;
export const flightSpecialsReducer = slice.reducer;
export const flightSpecialsAction = slice.actions;
