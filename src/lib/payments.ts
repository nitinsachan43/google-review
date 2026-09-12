import { verifyWebhook } from "./security";
export interface PaymentProvider { verifyWebhook(body:string,signature:string|null):boolean; }
export class RazorpayProvider implements PaymentProvider { constructor(private secret=process.env.RAZORPAY_WEBHOOK_SECRET||""){} verifyWebhook(body:string,signature:string|null){ return verifyWebhook(body,signature,this.secret); } }
export class StripeProvider implements PaymentProvider { verifyWebhook(){ return false; } }
