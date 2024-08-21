export type State<T, E = any> = {
    isLoading: boolean;
    data: T | null;
    error: E | null;
    page: number;
}

export const state = {
    initial: <T, E = any>(intialData?: T): State<T, E> => ({
        isLoading: false,
        data: intialData || null,
        error: null,
        page: 0
    }),
};
