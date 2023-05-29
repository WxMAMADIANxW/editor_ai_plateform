import { NextResponse } from "next/server";

const DATA_SOURCE_URL : string = process.env.DATA_SOURCE_URL as string;

export async function GET() {
    const res = await fetch(DATA_SOURCE_URL)

    const projects : Project[] = await res.json()

    return NextResponse.json(projects , {status: 201})
}


export async function DELETE(request: Request){
    const { id }: Partial<Project> = await request.json()

    if(!id) return NextResponse.json({error: "id is required"}, {status: 400})

    const res = await fetch(`${DATA_SOURCE_URL}/${id}`, {
        method: "DELETE",
        headers: {
            "Content-Type": "application/json"
        }

    })
    
    return NextResponse.json({message: `Project ${id} deleted`}, {status: 201}) 
}


export async function POST(request: Request){
    const { name, description }: Partial<Project> = await request.json()

    if(!name) return NextResponse.json({error: "name is required"}, {status: 400})

    const res = await fetch(DATA_SOURCE_URL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({name, description})
    })

    const project : Project = await res.json()

    return NextResponse.json(project, {status: 201})

}




