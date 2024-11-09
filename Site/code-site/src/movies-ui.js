import {getAllMovies, posterUrl} from "./movies-api";
let controller;

export function createMovieElt(movieData)
{
    const titre = movieData.title;
    const artiElt = document.createElement("article");
    artiElt.className = "movie-item";
    const divElt = document.createElement("div");
    divElt.className = "movie-item__info";
    const titElt = document.createElement("div");
    titElt.className = "movie-item__title";
    const imElt = document.createElement("img");
    imElt.className = 'movie-item__poster'

    titElt.innerHTML=titre;
    imElt.alt=`poster of \'${titre}\'`;
    imElt.src= posterUrl(`${movieData.poster}`,'medium');
    divElt.appendChild(titElt);
    artiElt.appendChild(divElt);
    artiElt.appendChild(imElt);
    return artiElt;
}

export function updateMoviesElt(page = 1)
{
    setLoading();
    const params = new URLSearchParams();
    params.append("page",`${page}`);
    appendSortToQuery(params);

    if (controller){
        controller.abort();
    }
    controller = new AbortController;
    const tab = getAllMovies(params,controller);
    const arti = document.querySelector(".movies-list");
    tab.then((data)=> {
        emptyElt(arti);
        data.collection.forEach((movie)=>{
            arti.appendChild(createMovieElt(movie));
        });
        updatePaginationElt(data.pagination);
    });
}

export function createPaginationButtonElt(materialIcon, isDisabled, page)
{
    const but = document.createElement("button");
    const icone = document.createElement("span");
    icone.className="material-symbols-outlined";
    icone.innerHTML=materialIcon;
    but.disabled=isDisabled;
    but.type="button";
    but.className="button";
    but.formAction=`/${page}`;
    but.appendChild(icone);
    but.addEventListener("click", ()=>{updateMoviesElt(page)});

    return but;
}

export function emptyElt(elt)
{
    while (elt.hasChildNodes()){
        elt.removeChild(elt.firstChild)
    }
}

export function updatePaginationElt(pagination)
{
    if(pagination.last >1){
        const but1 = createPaginationButtonElt('first_page',pagination.current===1,1);
        const but2 = createPaginationButtonElt('navigate_before',pagination.current===1, pagination.current-1);
        const but3 = createPaginationButtonElt('navigate_next',pagination.current===pagination.last,pagination.current+1);
        const but4 = createPaginationButtonElt('last_page',pagination.current===pagination.last,pagination.last);
        const pagi = document.createElement("span");
        pagi.className="pagination__info";
        pagi.innerHTML= `${pagination.current}/${pagination.last}`;

        const navi = document.querySelector("nav.pagination");
        navi.appendChild(but1);
        navi.appendChild(but2);
        navi.appendChild(pagi);
        navi.appendChild(but3);
        navi.appendChild(but4);
    }
}
export function setLoading()
{
    const pagi = document.querySelector("nav.pagination");
    emptyElt(pagi);
    const load = document.createElement("article");
    load.className="loading";
    load.innerHTML="Loading..."
    document.querySelector("article.movies-list").appendChild(load);
}

export function appendSortToQuery(urlSearchParams)
{
    const tri = document.querySelector("input[name='sort']:checked");
    if (tri!=null){
        return urlSearchParams.append(tri.value,"asc");
    }
}

export function setSortButtonsEltsEvents()
{
    const tab = document.querySelector("fieldset.sort");
    tab.addEventListener("change",()=>{updateMoviesElt()})
}