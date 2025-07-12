import useSWR from 'swr'
const fetcher=(u:string)=>fetch(u).then(r=>r.json())
export default function Leaderboard(){const{data}=useSWR('http://localhost:3001/api/leaderboard',fetcher);if(!data)return null;return(<div className="min-h-screen bg-gray-900 text-white p-4"><h1 className="text-xl">Leaderboard</h1><ul>{data.map((u:any)=><li key={u.id}>{u.username}</li>)}</ul></div>)}
