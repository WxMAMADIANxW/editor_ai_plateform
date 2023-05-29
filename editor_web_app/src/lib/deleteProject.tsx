import React from 'react'

export async function deleteProject(id : string) {
    const res = await fetch('/api/projects', {
        method: 'DELETE',
        body: JSON.stringify({id})
    })

    // USE ZOD HERE
    const message = await res.json()

    return message
}
