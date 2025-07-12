import {useEffect,useState} from 'react'
import {io} from 'socket.io-client'
export default function Online(){const[count,setCount]=useState(0);useEffect(()=>{const s=io('http://localhost:3001');s.on('count',(c:number)=>setCount(c));return()=>{s.disconnect()}},[]);return(<div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">Players online:{count}</div>)}
