import Link from 'next/link'
export default function Navbar(){return(<nav className="bg-gray-800 text-white p-2 flex space-x-4 fixed top-0 w-full"><Link href="/leaderboard">Leaderboard</Link><Link href="/play">Gioca</Link><Link href="/online">Giocatori Online</Link><Link href="/">Crea</Link><Link href="/login">Accedi</Link><Link href="/profile">Profilo</Link></nav>)}
