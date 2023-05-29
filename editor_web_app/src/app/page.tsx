'use client'
import Image from 'next/image'
import { Inter } from 'next/font/google'
import Link from 'next/link'
import getHello from '@/lib/getHello'

const inter = Inter({ subsets: ['latin'] })

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1>Editor AI</h1>
      <button  onClick={getHello}>Get HELLO</button>
    </main>
  )
}
