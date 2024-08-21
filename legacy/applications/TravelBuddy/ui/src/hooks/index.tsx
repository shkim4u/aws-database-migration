import {useEffect} from "react";

// export const useInfiniteScroll = ({
//     root = null,
//     target = null,
//     onIntersect: number = 1.0,
//     threshold = 1.0,
//     rootMargin = '0px',
// }) => {
//     useEffect(() => {
//         const observer = new IntersectionObserver(onIntersect, {
//             root,
//             rootMargin,
//             threshold
//         });
//
//         if (!target) {
//             return;
//         }
//
//         observer.observe(target);
//
//         return () => {
//             observer.unobserve(target);
//         };
//     }, [target, rootMargin, onIntersect, threshold]);
// };
