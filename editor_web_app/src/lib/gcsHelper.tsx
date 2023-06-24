import { Storage } from '@google-cloud/storage';

let storage: any;

interface Video {
  id: string;
  name: string;
  thumbnailUrl: string;
  url: string;
}

if (typeof window === 'undefined') {
  // Code will only execute on the server-side
  const { Storage } = require('@google-cloud/storage');
  storage = new Storage({
    keyFilename: '/editor-ai-390116-7e728d50b86d.json',
  });
} else {
  // Code will execute on the client-side
  storage = null; // or any other fallback behavior you need
}

export async function getVideosFromGCSFolder(
  bucketName: string,
  folderName: string
): Promise<Video[]> {
  if (!storage) {
    console.log(storage);
    console.error('Cannot use Google Cloud Storage on the client-side.');
    return [];
  }

  try {
    const bucket = storage.bucket(bucketName);
    const [files] = await bucket.getFiles({ prefix: folderName });

    const videos: Video[] = files.map((file: any) => {
      const name = file.name;
      const url = `https://storage.googleapis.com/${bucketName}/${name}`;
      const id = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
      const thumbnailUrl =
        'https://th.bing.com/th/id/OIP.EF_rH_CGlInjFiT_D71OjAAAAA?pid=ImgDet&rs=1';
      return { id, name, thumbnailUrl, url };
    });

    return videos;
  } catch (error) {
    console.error('Error retrieving videos from Google Cloud Storage:', error);
    return [];
  }
}
