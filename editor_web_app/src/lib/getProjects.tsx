import React from 'react'

export async function getProjects() : Promise<Project[]> {
    const res = await fetch('/api/projects', {
        method: 'GET',
    })

    // USE ZOD HERE
    const data : Project[] = await res.json()
    
    return data

}
