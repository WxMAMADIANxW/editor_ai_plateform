import React, { useState } from 'react';
import ReactPlayer from 'react-player';
import '../styles/VideoPlayer.css';


interface Video {
  id: string;
  name: string;
  thumbnailUrl: string;
  url: string;
}

interface VideoPlayerProps {
  video: Video;
  playlist: Video[];
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({ video, playlist }) => {
  const [currentVideo, setCurrentVideo] = useState(video);

  const handleThumbnailClick = (clickedVideo: Video) => {
    setCurrentVideo(clickedVideo);
  };

  return (
    <div className="video-player-container">
      <div className="video-player">
        <ReactPlayer url={currentVideo.url} controls={true} width="100%" height="100%" />
      </div>
      <div className="video-list">
        <h3>Playlist</h3>
        <ul>
          {playlist.map((item) => (
            <li key={item.id} onClick={() => handleThumbnailClick(item)}>
              <img src={item.thumbnailUrl} alt={item.name} />
              <span>{item.name}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default VideoPlayer;
