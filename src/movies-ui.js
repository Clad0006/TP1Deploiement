import {getAllMovies} from "./movies-api";

export function createMovieElt(movieData)
{
    const artiElt = document.createElement("article");
    artiElt.className = "movie-item";
    const divElt = document.createElement("div");
    divElt.className = "movie-item__info";
    const titElt = document.createElement("div");
    titElt.className = "movie-item__title";

    titElt.innerHTML=`${movieData.title}`;
    divElt.appendChild(titElt);
    artiElt.appendChild(divElt);
    return artiElt;
}

export function updateMoviesElt()
{
    const tab = getAllMovies();
    const arti = document.querySelector(".movies-list")
    tab.then((data)=> {data.forEach((movie)=>{
        arti.appendChild(createMovieElt(movie))
    })})
}