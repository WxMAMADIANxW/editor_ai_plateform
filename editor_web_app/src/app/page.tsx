'use client'
import Image from 'next/image'
import { Inter } from 'next/font/google'
import Link from 'next/link'
const inter = Inter({ subsets: ['latin'] })
import {getVideosFromGCSFolder} from '@/lib/gcsHelper'
import useSWR from 'swr'
import VideoPlayer from '@/components/VideoPlayer'
import { useEffect, useState } from 'react'


interface Video {
  id: string;
  name: string;
  thumbnailUrl: string;
  url: string;
}


export default async function Home() {

  const bucketName = 'video-intel-edai';
  const folderName = 'folder1';

  // const playlist1 = await getVideosFromGCSFolder(bucketName, folderName);

  // const playlist = [
  //   {
  //     id: '1',
  //     name: 'Main Video',
  //     thumbnailUrl: 'https://th.bing.com/th/id/OIP.EF_rH_CGlInjFiT_D71OjAAAAA?pid=ImgDet&rs=1',
  //     url: 'https://storage.cloud.google.com/video-intel-edai/A001_C064_09224Y_001.mp4',
  //   },
  //   {
  //     id: '2',
  //     name: 'Video 2',
  //     thumbnailUrl: 'https://th.bing.com/th/id/OIP.EF_rH_CGlInjFiT_D71OjAAAAA?pid=ImgDet&rs=1',
  //     url: 'https://storage.cloud.google.com/video-intel-edai/AdobeStock_116640093_Video_WM.mp4',
  //   },
  //   {
  //     id: '3',
  //     name: 'Video 3',
  //     thumbnailUrl: 'https://th.bing.com/th/id/OIP.EF_rH_CGlInjFiT_D71OjAAAAA?pid=ImgDet&rs=1',
  //     url: 'https://storage.cloud.google.com/video-intel-edai/FogTL.mp4',
  //   },
  //   // Add more videos to the playlist as needed
  // ];


  const [playlist, setPlaylist] = useState<Video[]>([]);

  useEffect(() => {
    const fetchVideos = async () => {
      const fetchedVideos = await getVideosFromGCSFolder(bucketName, folderName);
      setPlaylist(fetchedVideos);
    };

    fetchVideos();
  }, []);


  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
  
      <div>
        {playlist.length > 0 ? (
          <VideoPlayer video={playlist[0]} playlist={playlist} />
        ) : (
          <p>Loading videos...</p>
        )}
        
      </div>
      

    </main>
    
  )
}
