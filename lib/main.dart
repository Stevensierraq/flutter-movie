import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import './models/movieModel.dart';
import './movieDetails.dart';

const baseUrl = "https://api.themoviedb.org/3/movie/";
const baseImageUrl = "https://image.tmdb.org/t/p/";
const apiKey = "4f4846ab4165aad14048b187825932cc";

const nowPlayingMoviesUrl = "${baseUrl}now_playing?api_key=$apiKey";
const upcomingUrl = "${baseUrl}upcoming?api_key=$apiKey";
const popularUrl = "${baseUrl}popular?api_key=$apiKey";
const topRateUrl = "${baseUrl}top_rated?api_key=$apiKey";

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Movie App",
    theme: ThemeData.dark(),
    home: MyMovieApp(),
  )
);

class MyMovieApp extends StatefulWidget{
  @override
  _MyMovieApp createState() => new _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp>{
  Movie nowPlayingMovies;
  Movie upcomingMovies;
  Movie popularMovies;
  Movie topRateMovies;
  int heroTag = 0;
  int _currentIndex = 0;

  // Widget will mount
  @override
  void initState(){
    super.initState();
    _fetchMovies(nowPlayingMoviesUrl, "now_playing");
    _fetchMovies(upcomingUrl, "upcoming");
    _fetchMovies(popularUrl, "popular");
    _fetchMovies(topRateUrl, "top_rate");
  }

  void _fetchMovies(String url, String movies) async {
    var response = await http.get(url);
    var decodeJson = await jsonDecode(response.body);
    switch (movies) {
      case 'now_playing':
        setState(() => nowPlayingMovies = Movie.fromJson(decodeJson));
        break;
      case 'upcoming':
        setState(() => upcomingMovies = Movie.fromJson(decodeJson));
        break;
      case 'popular':
        setState(() => popularMovies = Movie.fromJson(decodeJson));
        break;
      case 'top_rate':
        setState(() => topRateMovies = Movie.fromJson(decodeJson));
        break;
      default:
        null;
    }


  }

  Widget _builCarouselSlider() => CarouselSlider(
    items:
        nowPlayingMovies == null ?
        <Widget>[
          Center(
            child: CircularProgressIndicator(),
          )
        ]
        :nowPlayingMovies.results.map((movieItem) =>
          _buildMovieItem(movieItem)
        ).toList(),
    autoPlay: false,
    height: 240.0,
    viewportFraction: 0.5,
  );

  Widget _buildMovieItem(Results movieItem){
    heroTag += 1;
    movieItem.heroTag = heroTag;

    return Material(
      elevation: 15.0,
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MovieDetail(movie: movieItem)
            )
          );
        },
        child: Hero(
          tag: heroTag,
          child: Image.network("${baseImageUrl}w342${movieItem.posterPath}", fit: BoxFit.cover,),
        ),
      ),
    );
  }

  Widget _buildMovieListItem(Results movieItem) => Material(
    child: Container(
      width: 128.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4.0),
            child: _buildMovieItem(movieItem),
          ),
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Padding(
              padding: EdgeInsets.only(left: 6.0, top: 2.0),
              child: Text(
                movieItem.title,
                style: TextStyle(fontSize: 8.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
                DateFormat('yyyy').format(DateTime.parse(movieItem.releaseDate)),
                style: TextStyle(fontSize: 8.0)
            )
          )
        ],
      )
    )
  );

  Widget _buildMoviesListView(Movie movie, String movieListTitle) => Container(
    // ignore: return_of_invalid_type
    height: 260.0,
    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.4)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 7.0, bottom: 7.0),
          child: Text(movieListTitle,
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400]
                        )
                      ),
                    ),
        Flexible(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: movie == null? <Widget>[
                Center(child: CircularProgressIndicator())]
                : movie.results.map((movieItem) => Padding(
                  padding: EdgeInsets.only(left: 6.0, right: 2.0),
                  child: _buildMovieListItem(movieItem)
                )).toList(),
              )
        ),
      ],
    ),
  );

  @override
  // TODO: implement widget
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
            "MOVIES APP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold
            )
        ),
        centerTitle: true,
      ),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
            return <Widget>[
              SliverAppBar(
                title:
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          'Now Playing',
                            style:
                              TextStyle(color: Colors.grey[400]
                            )
                      ),
                    ),
                  ),
                expandedHeight: 290.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: <Widget>[
                      Container(
                        child: Image.network("https://image.tmdb.org/t/p/w500/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg",
                            fit: BoxFit.cover,
                            width: 1000.0,
                            colorBlendMode: BlendMode.dstATop,
                            color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: Column(
                          children: <Widget>[
                            _builCarouselSlider()
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
            ];
          },
          body: ListView(
            children: <Widget>[
              _buildMoviesListView(upcomingMovies, 'COMING SOON'),
              _buildMoviesListView(popularMovies, 'POPULAR'),
              _buildMoviesListView(topRateMovies, 'TOP RATE'),
            ],
          )
         ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          fixedColor: Colors.redAccent[200],
          onTap: (int index){
            setState(() => _currentIndex = index );
          },
          items: [
           BottomNavigationBarItem(
             icon: Icon(Icons.local_movies),
             title: Text('All Movies'),
           ),
           BottomNavigationBarItem(
             icon: Icon(Icons.tag_faces),
             title: Text('Tickets')
           ),
           BottomNavigationBarItem(
               icon: Icon(Icons.person),
               title: Text('Account')
           )
        ]
      )
    );
    // ignore: unexpected_token
  }
}