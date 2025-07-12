import useSWR from 'swr'
const fetcher=(u:string)=>fetch(u,{credentials:'include'}).then(r=>r.json())
export default function Profile(){const{data}=useSWR('http://localhost:3001/api/profile',fetcher);if(!data)return null;return(<div className="min-h-screen bg-gray-900 text-white p-4"><h1 className="text-xl">{data.username}</h1><div className="mt-4">Games:{data.games.length}</div></div>)}
