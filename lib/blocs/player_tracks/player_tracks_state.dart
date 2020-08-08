import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:storify/models/playlist.dart';
import 'package:storify/models/track.dart';

abstract class PlayerTracksState extends Equatable {
  PlayerTracksState({@required this.playlist});
  final Playlist playlist;

  @override
  List<Object> get props => [playlist];
}

class PlayerTracksInitial extends PlayerTracksState {
  PlayerTracksInitial(Playlist playlist) : super(playlist: playlist);
}

class PlayerTracksFailure extends PlayerTracksState {
  PlayerTracksFailure(Playlist playlist) : super(playlist: playlist);
}

class PlayerTracksSuccess extends PlayerTracksState {
  final List<Track> tracks;
  final Track currentTrack;
  final Playlist playlist;
  final String currentTrackArtistImageUrl;
  final String storyText;

  PlayerTracksSuccess({
    @required this.playlist,
    @required this.tracks,
    @required this.currentTrack,
    this.currentTrackArtistImageUrl = '',
    this.storyText,
  }) : super(playlist: playlist);

  PlayerTracksSuccess copyWith(
          {List<Track> tracks,
          Playlist playlist,
          Track currentTrack,
          String currentTrackArtistImageUrl,
          String storyText}) =>
      PlayerTracksSuccess(
          tracks: tracks ?? this.tracks,
          playlist: playlist ?? this.playlist,
          currentTrack: currentTrack ?? this.currentTrack,
          currentTrackArtistImageUrl:
              currentTrackArtistImageUrl ?? this.currentTrackArtistImageUrl,
          storyText: storyText ?? this.storyText);

  @override
  List<Object> get props =>
      [playlist, currentTrack, currentTrackArtistImageUrl, tracks, storyText];
}
