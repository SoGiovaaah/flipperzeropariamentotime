import Link from 'next/link'
export default function Home(){return(<div className="min-h-screen flex flex-col items-center justify-center text-white bg-gray-900"><h1 className="text-3xl">Welcome</h1><nav className="space-x-4"><Link href="/login">Login</Link><Link href="/register">Register</Link></nav></div>)}
