import { NextResponse } from 'next/server'
import React from 'react'

export default async function getHello()  {
  
    const res = await fetch('/api/hello', {
        method: 'GET',
    })

    const data = await res.json()

    console.log(data)
}
