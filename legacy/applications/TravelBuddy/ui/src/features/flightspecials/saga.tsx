import {select, call, put, takeLatest} from "redux-saga/effects";
import {flightSpecialsAction, flightSpecialsSelector} from "./slice";
import {getFlightSpecials} from "../../api";

export function* handleFlightSpecialsLoad(): any {
    const {loadSuccess, loadFail} = flightSpecialsAction;

    try {
        const page = yield select(flightSpecialsSelector.page);
        const previousFlightSpecials = yield select(flightSpecialsSelector.flightSpecials);
        const nextPage = page + 1;

        const newFlightSpecials = yield call(getFlightSpecials, nextPage);
        console.log(`newFlightSpecials: ${newFlightSpecials}`);

        let payload: any = {
            // [2023-09-19] Just return with a fresh new list.
            // flightSpecials: previousFlightSpecials.concat(newFlightSpecials),
            flightSpecials: newFlightSpecials,
            nextPage
        };
        console.log(`flightSpecials payload: ${payload}`);

        yield put(
            loadSuccess(payload)
        );
    } catch (err: any) {
        yield put(loadFail(err));
    }
}

export function* watchFlightSpecials() {
    const {load, loadMore} = flightSpecialsAction;

    yield takeLatest(load, handleFlightSpecialsLoad);
    yield takeLatest(loadMore, handleFlightSpecialsLoad);
}
