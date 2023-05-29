import React from 'react'

export async function createProject(name : string, description ?: string) {
    const res = await fetch('/api/projects', {
        method: 'POST',
        body: JSON.stringify({name : name , description : description})
    })

    // USE ZOD HERE
    const message = await res.json()

    return message
}
