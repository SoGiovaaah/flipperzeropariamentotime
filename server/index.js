const express=require('express')
const cors=require('cors')
const cookieParser=require('cookie-parser')
const {PrismaClient}=require('@prisma/client')
const bcrypt=require('bcrypt')
const jwt=require('jsonwebtoken')
const {Server}=require('socket.io')
const http=require('http')
require('dotenv').config({path:'../.env'})
const prisma=new PrismaClient()
const app=express()
app.use(cors({origin:true,credentials:true}))
app.use(express.json())
app.use(cookieParser())
const server=http.createServer(app)
const io=new Server(server,{cors:{origin:true}})
const authenticate=async(req,res,next)=>{
  const token=req.cookies.token
  if(!token)return res.sendStatus(401)
  try{const data=jwt.verify(token,process.env.JWT_SECRET);req.user=data;next()}catch{res.sendStatus(401)}
}
app.post('/api/register',async(req,res)=>{
  const {username,password,confirm}=req.body
  if(!username||!password||password!==confirm)return res.sendStatus(400)
  const hash=await bcrypt.hash(password,10)
  const user=await prisma.user.create({data:{username,password:hash}})
  res.json({id:user.id})
})
app.post('/api/login',async(req,res)=>{
  const {username,password}=req.body
  const user=await prisma.user.findUnique({where:{username}})
  if(!user)return res.sendStatus(401)
  const ok=await bcrypt.compare(password,user.password)
  if(!ok)return res.sendStatus(401)
  const token=jwt.sign({id:user.id},process.env.JWT_SECRET,{expiresIn:'15m'})
  const refresh=jwt.sign({id:user.id},process.env.JWT_SECRET,{expiresIn:'7d'})
  await prisma.session.create({data:{token:refresh,userId:user.id}})
  res.cookie('token',refresh,{httpOnly:true})
  res.json({token})
})
app.get('/api/profile',authenticate,async(req,res)=>{
  const user=await prisma.user.findUnique({where:{id:req.user.id},include:{stats:true,games:true}})
  res.json(user)
})
app.get('/api/leaderboard',async(req,res)=>{
  const page=parseInt(req.query.page)||1
  const take=20
  const skip=(page-1)*take
  const users=await prisma.user.findMany({skip,take,include:{stats:true}})
  res.json(users)
})
io.on('connection',socket=>{
  socket.on('online',async id=>{await prisma.session.create({data:{token:socket.id,userId:id}});io.emit('count',io.engine.clientsCount)})
  socket.on('disconnect',async()=>{await prisma.session.deleteMany({where:{token:socket.id}});io.emit('count',io.engine.clientsCount)})
})
const port=3001
server.listen(port)
