import {combineReducers, configureStore} from "@reduxjs/toolkit";
import logger from "redux-logger";
import {batchedSubscribe} from "redux-batched-subscribe";
import createSagaMiddleware from "redux-saga";
import {debounce} from "lodash";
import {all} from "redux-saga/effects";
import {watchHotelSpecials} from "../features/hotelspecials/saga";
import {HOTELSPECIALS, hotelSpecialsReducer} from "../features/hotelspecials/slice";
import {FLIGHTSPECIALS, flightSpecialsReducer} from "../features/flightspecials/slice";
import {watchFlightSpecials} from "../features/flightspecials/saga";

export const rootReducer = combineReducers({
    [FLIGHTSPECIALS]: flightSpecialsReducer,
    [HOTELSPECIALS]: hotelSpecialsReducer,
})

const sagaMiddleware = createSagaMiddleware();
const debounceNotify = debounce(notify => notify());

export function* rootSaga() {
    yield all([
        watchFlightSpecials(),
        watchHotelSpecials(),
    ])
}

const createStore = () => {
    /*
     * Redux DevTools를 통해 State 변화를 추적할 수 있도록 설정.
     * 운영에서는 보안을 고려하여 비활성화.
     */
    // See: https://freestrokes.tistory.com/161
    const store = configureStore({
        reducer: rootReducer,
        middleware : (getDefaultMiddleware) => getDefaultMiddleware().concat(logger).concat(sagaMiddleware),
        devTools: process.env.NODE_ENV !== 'production',
        enhancers: [batchedSubscribe(debounceNotify)],
    });
    sagaMiddleware.run(rootSaga);
    return store;
}

export default createStore;
