import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storify/blocs/blocs.dart';
import 'package:storify/models/playlist.dart';
import 'package:storify/models/track.dart';
import 'package:storify/services/firebase_db.dart';
import 'package:storify/services/spotify_api.dart';
import 'package:storify/widgets/_common/custom_rounded_button.dart';
import 'package:storify/widgets/_common/custom_toast.dart';
import 'package:storify/widgets/edit_story_page/edit_story_page.dart';
import 'package:storify/widgets/player_page/player_carousel.dart';
import 'package:storify/widgets/player_page/player_page_app_bar.dart';
import 'package:storify/widgets/player_page/player_page_error.dart';
import 'package:storify/widgets/player_page/player_page_loading.dart';
import 'package:storify/widgets/player_page/player_play_button.dart';
import 'package:storify/widgets/player_page/player_progress_bar.dart';
import 'package:storify/widgets/player_page/player_track_info.dart';
import 'package:storify/constants/values.dart' as Constants;

class PlayerPage extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<PlayerPage> {
  PlayerTracksBloc _playerTracksBloc;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _playerTracksBloc = BlocProvider.of<PlayerTracksBloc>(context);
  }

  void _handleTrackChanged(int index) {
    _controller.animateTo(0,
        duration: Constants.scrollResetDuration, curve: Curves.ease);
    _playerTracksBloc.add(PlayerTracksTrackSelected(selectedTrackIndex: index));
  }

  void _onEditOrAddPressed(
      String storyText, Track currentTrack, Playlist playlist) {
    EditStoryPage.show(context,
        track: currentTrack,
        originalStoryText: storyText,
        onStoryTextEdited: _handleEditStoryText);
  }

  Future<void> _onPlayButtonTapped(String playlistId, String trackId) async {
    try {
      await SpotifyApi.play(playlistId: playlistId, trackId: trackId);
    } on NoActiveDeviceFoundException catch (_) {
      CustomToast.showTextToast(
          text: 'Play any track in Spotify app \nto activate this feature',
          toastType: ToastType.warning);
    } on PremiumRequiredException catch (_) {
      CustomToast.showTextToast(
          text: 'You must be a Spotify premium user',
          toastType: ToastType.error);
    }
  }

  Future<void> _handleEditStoryText(String newStoryText) async {
    _playerTracksBloc.add(PlayerTrackStoryTextEdited(newStoryText));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerTracksBloc, PlayerTracksState>(
        builder: (context, state) {
      if (state is PlayerTracksInitial) {
        return PlayerPageLoading(
          playlist: state.playlist,
        );
      }
      if (state is PlayerTracksFailure) {
        return PlayerPageError(
          playlist: state.playlist,
        );
      }

      if (state is PlayerTracksSuccess) {
        return Stack(
          children: [
            Image.network(
              state.currentTrack.albumImageUrl,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
              child: Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: PlayerPageAppBar(playlist: state.playlist),
                body: _buildContent(state),
              ),
            )
          ],
        );
      }

      return Container();
    });
  }

  Widget _buildContent(PlayerTracksSuccess state) {
    final playlist = state.playlist;
    final currentTrack = state.currentTrack;
    final artistImageUrl = state.currentTrackArtistImageUrl;
    final tracks = state.tracks;
    final storyText = state.storyText ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 80.0, bottom: 36.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          PlayerTrackInfo(
            storyText: storyText,
            artistImageUrl: artistImageUrl,
            currentTrack: currentTrack,
            controller: _controller,
          ),
          Column(children: [
            Column(children: [
              SizedBox(
                height: 8.0,
              ),
              CustomRoundedButton(
                size: ButtonSize.small,
                buttonText: storyText == '' ? 'ADD A STORY' : 'EDIT YOUR STORY',
                onPressed: () =>
                    _onEditOrAddPressed(storyText, currentTrack, playlist),
              ),
              SizedBox(
                height: 16.0,
              )
            ]),
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                PlayerCarousel(
                  tracks: tracks,
                  onPageChanged: _handleTrackChanged,
                  onPlayButtonTap: () =>
                      _onPlayButtonTapped(playlist.id, currentTrack.id),
                ),
                IgnorePointer(
                  child: PlayerProgressBar(
                    totalValue: 360,
                    initialValue: 270,
                    size: 72.0,
                    innerWidget: PlayerPlayButton(
                      isPlaying: false,
                    ),
                  ),
                ),
              ],
            )
          ]),
        ],
      ),
    );
  }
}
