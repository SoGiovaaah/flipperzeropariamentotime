import {motion} from 'framer-motion'
export default function Play(){return(<div className="min-h-screen bg-gray-900 flex items-center justify-center"><motion.div initial={{scale:0}} animate={{scale:1}} className="bg-gray-800 p-4 text-white">Play</motion.div></div>)}
