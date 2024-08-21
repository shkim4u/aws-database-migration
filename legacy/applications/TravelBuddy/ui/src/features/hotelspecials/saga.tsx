import {select, call, put, takeLatest} from "redux-saga/effects";
import {hotelSpecialsAction, hotelSpecialsSelector} from "./slice";
import {getHotelSpecials} from "../../api";

export function* handleHotelSpecialsLoad(): any {
    const {loadSuccess, loadFail} = hotelSpecialsAction;

    try {
        const page = yield select(hotelSpecialsSelector.page);
        const previousHotelSpecials = yield select(hotelSpecialsSelector.hotelSpecials);
        const nextPage = page + 1;

        const newHotelSpecials = yield call(getHotelSpecials, nextPage);
        console.log(`newHotelSpecials: ${newHotelSpecials}`);

        let payload: any = {
            // [2023-09-19] Just return with a fresh new list.
            // hotelSpecials: previousHotelSpecials.concat(newHotelSpecials),
            hotelSpecials: newHotelSpecials,
            nextPage
        };
        console.log(`hotelSpecials payload: ${payload}`);

        yield put(
            loadSuccess(payload)
        );
    } catch (err: any) {
        yield put(loadFail(err));
    }
}

export function* watchHotelSpecials() {
    const {load, loadMore} = hotelSpecialsAction;

    yield takeLatest(load, handleHotelSpecialsLoad);
    yield takeLatest(loadMore, handleHotelSpecialsLoad);
}
