import {getAllMovies, posterUrl} from "./movies-api";

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

export function updateMoviesElt()
{
    const tab = getAllMovies();
    const arti = document.querySelector(".movies-list");
    tab.then((data)=> {data.collection.forEach((movie)=>{
        arti.appendChild(createMovieElt(movie))
    })})
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
    but.addEventListener("click", updateMoviesElt);

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