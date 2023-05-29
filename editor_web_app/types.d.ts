type Project = {
    id: string,
    name: string,
    description: string,
    gcs_bucket : string;
    result_gcs_folder: string;
    raw_files_gcs_folder : string;
    list_of_videos: Video[],
    created_at: string,
    updated_at: string,
}

type User = {
    id: number,
    name: string,
    email: string,
    list_of_projects: Project[],
    created_at: string
}

type Video = {
    id: string,
    name: string,
    description: string,
    status: VideoStatus,
    link_of_video: string,
    project_id: string,
    created_at: string
}