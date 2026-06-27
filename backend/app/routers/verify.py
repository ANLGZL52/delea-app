# app/routers/verify.py
import json
import os
import time
import urllib.request
from typing import Any, Optional

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/verify", tags=["verify"])


class VerifyPurchaseRequest(BaseModel):
    """Android: purchase_token = Google Play purchase token. iOS: receipt / JWS string."""

    purchase_token: str
    product_id: str
    package_name: str = "com.delea.app"
    device_id: Optional[str] = None
    platform: str = "android"  # "android" | "ios"


def _get_android_publisher():
    """Get Android Publisher API client. Returns None if not configured."""
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        creds_json = os.getenv("GOOGLE_SERVICE_ACCOUNT_JSON")

        if creds_path and os.path.exists(creds_path):
            credentials = service_account.Credentials.from_service_account_file(
                creds_path,
                scopes=["https://www.googleapis.com/auth/androidpublisher"],
            )
        elif creds_json:
            info = json.loads(creds_json)
            credentials = service_account.Credentials.from_service_account_info(
                info,
                scopes=["https://www.googleapis.com/auth/androidpublisher"],
            )
        else:
            return None

        return build("androidpublisher", "v3", credentials=credentials)
    except Exception:
        return None


def _verify_apple_receipt(receipt_b64: str, product_id: str) -> tuple[bool, str, dict[str, Any], bool]:
    """
    Legacy App Store verifyReceipt. StoreKit 2 ayrı JWS doğrulaması ister (bu endpoint desteklemez).
    Dönüş: (ok, reason, extra, evaluated).
    `evaluated=True` => Apple'a gerçekten ulaşıldı ve kesin bir yanıt alındı (aktif değil/iptal/iade).
    `evaluated=False` => doğrulama YAPILAMADI (secret yok, JWS, ağ hatası) => istemci mağaza onayına güvenip
    cömert fallback uygulamalı; gerçek bir ret değildir.
    Dönen ek alan: expires_at_ms (varsa).
    """
    secret = os.getenv("APPLE_SHARED_SECRET")
    if not secret:
        return False, "APPLE_SHARED_SECRET not set", {}, False

    if receipt_b64.strip().startswith("eyJ"):
        return False, "StoreKit 2 JWS received; set up App Store Server API verification or test with older receipt", {}, False

    payload = {
        "receipt-data": receipt_b64,
        "password": secret,
        "exclude-old-transactions": True,
    }
    body = json.dumps(payload).encode("utf-8")

    def _post_receipt(url: str) -> dict[str, Any]:
        req = urllib.request.Request(  # noqa: S310
            url,
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=45) as resp:  # noqa: S310
            return json.loads(resp.read().decode("utf-8"))

    def _find_active(data: dict[str, Any]) -> Optional[int]:
        now_ms = int(time.time() * 1000)
        latest = data.get("latest_receipt_info")
        if isinstance(latest, list) and latest:
            for ent in latest:
                if ent.get("product_id") == product_id:
                    exp = ent.get("expires_date_ms")
                    if exp and int(exp) > now_ms:
                        return int(exp)
        return None

    try:
        data = _post_receipt("https://buy.itunes.apple.com/verifyReceipt")
    except Exception as e:
        # Apple'a ulaşılamadı => doğrulama yapılamadı (evaluated=False).
        return False, str(e), {}, False

    if data.get("status") == 21007:
        try:
            data = _post_receipt("https://sandbox.itunes.apple.com/verifyReceipt")
        except Exception as e:
            return False, f"sandbox: {e}", {}, False

    if data.get("status") != 0:
        # Apple kesin yanıt verdi: makbuz geçersiz/işlenemedi (evaluated=True).
        return False, f"Apple status {data.get('status')}", {}, True

    exp = _find_active(data)
    if exp is not None:
        return True, "ok", {"expires_at_ms": exp}, True
    # Apple yanıt verdi ama bu ürün için aktif abonelik yok (evaluated=True).
    return False, "No active subscription for this product_id in receipt", {}, True


@router.post("/purchase")
async def verify_purchase(req: VerifyPurchaseRequest):
    """
    Doğrula: Android = Google Play **abonelik** (purchases.subscriptions.get);
    iOS = App Store **verifyReceipt** (APPLE_SHARED_SECRET gerekir).
    """
    plat = (req.platform or "android").lower().strip()

    if plat == "ios":
        ok, reason, extra, evaluated = _verify_apple_receipt(req.purchase_token, req.product_id)
        if not ok:
            return {"verified": False, "evaluated": evaluated, "reason": reason}

        from app.database import async_session_maker
        if async_session_maker:
            from app.models import Purchase
            from datetime import datetime

            async with async_session_maker() as session:
                purchase = Purchase(
                    device_id=req.device_id,
                    purchase_token=req.purchase_token[:2000],  # uzun JWS/ makbuz kes
                    product_id=req.product_id,
                    package_name=req.package_name or "com.delea.app",
                    order_id=None,
                    verified_at=datetime.utcnow(),
                )
                try:
                    session.add(purchase)
                    await session.commit()
                except Exception:
                    await session.rollback()
        return {"verified": True, "evaluated": True, **extra}

    # --- Android: abonelik ---
    android = _get_android_publisher()
    if not android:
        # Doğrulama yapılamadı (kimlik yok) => evaluated=False => istemci cömert fallback.
        return {
            "verified": False,
            "evaluated": False,
            "reason": "Server not configured for purchase verification (GOOGLE_APPLICATION_CREDENTIALS)",
        }

    try:
        result: dict[str, Any] = (
            android.purchases()
            .subscriptions()
            .get(
                packageName=req.package_name,
                subscriptionId=req.product_id,
                token=req.purchase_token,
            )
            .execute()
        )
    except Exception as e:
        # Play API'ye ulaşılamadı => doğrulama yapılamadı => evaluated=False.
        return {"verified": False, "evaluated": False, "reason": str(e)}

    # paymentState: 0=Pending, 1=Received, 2=Free trial, 3=PayRev pending (ertelenmiş)
    now_ms = int(time.time() * 1000)
    expiry_ms = 0
    if result.get("expiryTimeMillis") is not None:
        try:
            expiry_ms = int(result["expiryTimeMillis"])
        except (TypeError, ValueError):
            pass

    ps_raw = result.get("paymentState")
    try:
        payment_state = int(ps_raw) if ps_raw is not None else -1
    except (TypeError, ValueError):
        payment_state = -1

    # Buraya kadar Play API kesin yanıt verdi => evaluated=True.
    if expiry_ms and expiry_ms < now_ms:
        return {"verified": False, "evaluated": True, "reason": "Subscription expired"}

    if payment_state == 0:
        return {"verified": False, "evaluated": True, "reason": "Payment pending"}

    if expiry_ms and expiry_ms >= now_ms:
        # Ödeme alındı döneminde: süre ileri — paymentState boş/uyumsuz olsa bile kabul
        pass
    elif payment_state in (1, 2, 3):
        pass
    else:
        return {
            "verified": False,
            "evaluated": True,
            "reason": f"Unrecognized paymentState {payment_state} and no valid expiry",
        }

    extra: dict[str, Any] = {}
    if expiry_ms:
        extra["expires_at_ms"] = expiry_ms

    from app.database import async_session_maker
    if async_session_maker:
        from app.models import Purchase
        from datetime import datetime

        async with async_session_maker() as session:
            purchase = Purchase(
                device_id=req.device_id,
                purchase_token=req.purchase_token,
                product_id=req.product_id,
                package_name=req.package_name,
                order_id=result.get("orderId"),
                verified_at=datetime.utcnow(),
            )
            try:
                session.add(purchase)
                await session.commit()
            except Exception:
                await session.rollback()
                # Duplicate token is OK

    return {"verified": True, "evaluated": True, **extra}
