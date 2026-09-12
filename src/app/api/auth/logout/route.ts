import {NextResponse} from "next/server";import {SESSION_COOKIE} from "@/lib/security";
export async function POST(req:Request){const origin=new URL(req.url).origin;const res=NextResponse.redirect(new URL("/",origin),303);res.cookies.set(SESSION_COOKIE,"",{httpOnly:true,sameSite:"lax",secure:process.env.NODE_ENV==="production",path:"/",maxAge:0});return res;}
