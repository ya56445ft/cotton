from fastapi import FastAPI, Request, Response
import base64
# فرض بر این است که متدهای اصلی CottenDNS در پروژه وارد شده‌اند
# from cotten_dns import process_dns_query, load_config

app = FastAPI()

@app.get("/dns-query")
@app.post("/dns-query")
async def doh_handler(request: Request):
    dns_wire_format = None
    
    if request.method == "GET":
        dns_b64 = request.query_params.get("dns")
        if dns_b64:
            # پدینگ Base64 URL-safe
            padding = '=' * (-len(dns_b64) % 4)
            dns_wire_format = base64.urlsafe_b64decode(dns_b64 + padding)
    elif request.method == "POST":
        dns_wire_format = await request.body()
        
    if not dns_wire_format:
        return Response(status_code=400, content="Bad Request: Missing DNS query payload")

    # -------------------------------------------------------------
    # منطق پردازش CottenDNS را اینجا فراخوانی کنید
    # response_payload = process_dns_query(dns_wire_format)
    # -------------------------------------------------------------
    response_payload = dns_wire_format # نمونه تست/جایگزین

    return Response(
        content=response_payload,
        media_type="application/dns-message"
    )
