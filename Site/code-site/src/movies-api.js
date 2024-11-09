export const API_URL = 'http://movies-api';

export function getAllMovies(urlSearchParams, abortController) {
    console.log(urlSearchParams);
    if (!(urlSearchParams instanceof URLSearchParams)) {
        return Promise.reject(new Error("un type URLSearchParams attendu"));
    }
    if (abortController){
        return fetch(`${API_URL}/movies?${urlSearchParams.toString()}`,
        {signal:abortController.signal})
    .then(extractCollectionAndPagination);
    }
    return fetch(`${API_URL}/movies?${urlSearchParams.toString()}`)
        .then(extractCollectionAndPagination);
}

export function posterUrl(imagePath,size='original')
{
    return `${API_URL}${imagePath}/${size}`;
}

export function extractPaginationFromHeaders(response)
{
    const obj = {}
    obj.current= parseInt(response.headers.get('Pagination-Current-Page'));
    obj.last= parseInt(response.headers.get('Pagination-Last-Page'));
    return obj;
}

export function extractCollectionAndPagination(response)
{
    return response.json().then(
        (collection)=>{return {collection:collection,pagination:extractPaginationFromHeaders(response)}}
    )
}